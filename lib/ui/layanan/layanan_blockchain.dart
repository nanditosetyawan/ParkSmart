import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';

/// Layanan penghubung antara aplikasi mobile Flutter dan jaringan Blockchain Ethereum (Sepolia Testnet).
/// Bertugas melakukan verifikasi token keanggotaan dan mencocokkan kode hash (member_hash_code) pengguna.
class LayananBlockchain {
  LayananBlockchain._();
  static final LayananBlockchain instance = LayananBlockchain._();

  // 1. Alamat RPC Jaringan Uji Sepolia (Infura / Alchemy / RPC Publik)
  // 1. Alamat RPC Jaringan Uji Sepolia (Infura / Alchemy / RPC Publik)
  static String get urlRpc {
    final envUrl = dotenv.env['SEPOLIA_RPC_URL'];
    if (envUrl != null && envUrl.isNotEmpty && !envUrl.contains('ID_PROYEK_ANDA')) {
      return envUrl;
    }
    // Fallback otomatis ke RPC publik Sepolia gratis yang aktif
    return 'https://ethereum-sepolia-rpc.publicnode.com';
  }

  // 2. Klien Web3 untuk koneksi HTTP JSON-RPC
  late final Web3Client klienWeb3;

  // 3. Alamat Kontrak Pintar KeanggotaanParkir yang telah diunggah ke Sepolia
  // Ganti nilai default ini dengan Contract Address yang Anda peroleh setelah deploy di Remix IDE
  static String get alamatKontrakHex =>
      dotenv.env['SEPOLIA_CONTRACT_ADDRESS'] ??
      '0x58aC0937fCbc73993d5e391212d18fe0e2851a81';

  EthereumAddress get alamatKontrak => EthereumAddress.fromHex(alamatKontrakHex);

  // Status inisialisasi koneksi
  bool _terinisialisasi = false;
  bool get terinisialisasi => _terinisialisasi;

  String? _loadedAbiString;

  /// Inisialisasi modul koneksi Web3
  void inisialisasi() {
    if (_terinisialisasi) return;
    try {
      final httpClient = http.Client();
      klienWeb3 = Web3Client(urlRpc, httpClient);
      _terinisialisasi = true;
      debugPrint('[LayananBlockchain] Berhasil terhubung ke RPC Sepolia: $urlRpc');
    } catch (e) {
      debugPrint('[LayananBlockchain] Gagal inisialisasi koneksi Web3: $e');
    }
  }

  /// Memuat ABI dari berkas assets/abi_keanggotaan.json dengan fallback ke ABI statis
  Future<String> _ambilAbiKontrak() async {
    if (_loadedAbiString != null && _loadedAbiString!.isNotEmpty) {
      return _loadedAbiString!;
    }
    try {
      _loadedAbiString = await rootBundle.loadString('assets/abi_keanggotaan.json');
      return _loadedAbiString!;
    } catch (e) {
      debugPrint('[LayananBlockchain] Load asset ABI warning, fallback to default ABI: $e');
      return _kontrakAbiFallback;
    }
  }

  /// ABI Statis Cadangan (Fallback)
  static const String _kontrakAbiFallback = '''[
    {"inputs":[{"internalType":"address","name":"pengguna","type":"address"},{"internalType":"string","name":"tier","type":"string"},{"internalType":"string","name":"memberHashCode","type":"string"}],"name":"terbitkanKeanggotaan","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},
    {"inputs":[{"internalType":"address","name":"pengguna","type":"address"}],"name":"cekStatusKeanggotaan","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},
    {"inputs":[{"internalType":"string","name":"memberHashCode","type":"string"}],"name":"validasiHash","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},
    {"inputs":[{"internalType":"address","name":"pengguna","type":"address"}],"name":"hitungKartuPengguna","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},
    {"inputs":[{"internalType":"address","name":"pengguna","type":"address"}],"name":"dapatkanDaftarKartu","outputs":[{"components":[{"internalType":"uint256","name":"idToken","type":"uint256"},{"internalType":"string","name":"tier","type":"string"},{"internalType":"string","name":"kodeHash","type":"string"},{"internalType":"uint256","name":"waktuPenerbitan","type":"uint256"},{"internalType":"bool","name":"aktif","type":"bool"}],"internalType":"struct KeanggotaanParkir.KartuMember[]","name":"","type":"tuple[]"}],"stateMutability":"view","type":"function"}
  ]''';

  /// Memverifikasi status keanggotaan pengguna langsung dari Smart Contract di blockchain
  Future<bool> cekStatusKeanggotaan(String alamatDompetPengguna) async {
    try {
      inisialisasi();
      final abi = await _ambilAbiKontrak();
      final contract = DeployedContract(
        ContractAbi.fromJson(abi, 'KeanggotaanParkir'),
        alamatKontrak,
      );

      final fungsiCek = contract.function('cekStatusKeanggotaan');
      final targetAddress = EthereumAddress.fromHex(alamatDompetPengguna);

      final hasil = await klienWeb3.call(
        contract: contract,
        function: fungsiCek,
        params: [targetAddress],
      );

      if (hasil.isNotEmpty && hasil.first is bool) {
        return hasil.first as bool;
      }
    } catch (e) {
      debugPrint('[LayananBlockchain] Error cekStatusKeanggotaan: $e');
    }
    return false;
  }

  /// Memvalidasi apakah kode hash kartu (member_hash_code) terdaftar di blockchain
  Future<bool> validasiKodeHash(String memberHashCode) async {
    try {
      inisialisasi();
      final abi = await _ambilAbiKontrak();
      final contract = DeployedContract(
        ContractAbi.fromJson(abi, 'KeanggotaanParkir'),
        alamatKontrak,
      );

      final fungsiValidasi = contract.function('validasiHash');
      final hasil = await klienWeb3.call(
        contract: contract,
        function: fungsiValidasi,
        params: [memberHashCode],
      );

      if (hasil.isNotEmpty && hasil.first is bool) {
        return hasil.first as bool;
      }
    } catch (e) {
      debugPrint('[LayananBlockchain] Error validasiKodeHash: $e');
    }
    return false;
  }

  /// Mengambil daftar kartu yang dimiliki oleh pengguna dari blockchain (1 s/d 4 kartu)
  Future<List<Map<String, dynamic>>> ambilDaftarKartuPengguna(String alamatDompetPengguna) async {
    final List<Map<String, dynamic>> daftarKartu = [];
    try {
      inisialisasi();
      final abi = await _ambilAbiKontrak();
      final contract = DeployedContract(
        ContractAbi.fromJson(abi, 'KeanggotaanParkir'),
        alamatKontrak,
      );

      final fungsiDaftar = contract.function('dapatkanDaftarKartu');
      final targetAddress = EthereumAddress.fromHex(alamatDompetPengguna);

      final hasil = await klienWeb3.call(
        contract: contract,
        function: fungsiDaftar,
        params: [targetAddress],
      );

      if (hasil.isNotEmpty && hasil.first is List) {
        final listData = hasil.first as List;
        for (final item in listData) {
          if (item is List && item.length >= 5) {
            daftarKartu.add({
              'idToken': item[0].toString(),
              'tier': item[1].toString(),
              'kodeHash': item[2].toString(),
              'waktu': DateTime.fromMillisecondsSinceEpoch(
                ((item[3] as BigInt).toInt()) * 1000,
              ),
              'aktif': item[4] as bool,
            });
          }
        }
      }
    } catch (e) {
      debugPrint('[LayananBlockchain] Error ambilDaftarKartuPengguna: $e');
    }
    return daftarKartu;
  }
}
