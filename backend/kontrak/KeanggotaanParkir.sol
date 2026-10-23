// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title KeanggotaanParkir
 * @dev Kontrak Pintar untuk Manajemen Token Keanggotaan ParkSmart (4 Jenis Kartu).
 * Mengelola penerbitan token keanggotaan berbasis dompet Web3 (Sepolia Testnet),
 * mencocokkan alamat dompet pengguna dengan kode hash keanggotaan (member_hash_code).
 */
contract KeanggotaanParkir {
    // Alamat administrator / pemilik kontrak
    address public pemilik;

    // Struktur data untuk setiap kartu keanggotaan pengguna
    struct KartuMember {
        uint256 idToken;
        string tier;            // 'regular', 'silver', 'gold', 'platinum'
        string kodeHash;        // Hash unik kartu (member_hash_code)
        uint256 waktuPenerbitan;
        bool aktif;
    }

    // Counter ID token keanggotaan
    uint256 private _totalTokenCounter;

    // Pemetaan: alamat dompet pengguna => array kartu member yang dimiliki (bisa 1, 2, 3, atau 4 kartu)
    mapping(address => KartuMember[]) private _kartuPengguna;

    // Pemetaan: kode hash kartu => apakah sudah pernah diterbitkan (mencegah duplikasi hash)
    mapping(string => bool) private _hashTerdaftar;

    // Pemetaan: alamat dompet => status keanggotaan aktif global
    mapping(address => bool) public statusKeanggotaan;

    // Event saat kartu keanggotaan berhasil diterbitkan ke blockchain
    event KeanggotaanDiterbitkan(
        address indexed alamatPengguna,
        uint256 indexed idToken,
        string tier,
        string kodeHash,
        uint256 waktu
    );

    // Event saat status kartu diperbarui
    event StatusKeanggotaanDiperbarui(
        address indexed alamatPengguna,
        bool statusAktif
    );

    modifier hanyaPemilik() {
        require(msg.sender == pemilik, "Hanya pemilik kontrak yang berhak melakukan tindakan ini");
        _;
    }

    constructor() {
        pemilik = msg.sender;
    }

    /**
     * @notice Menerbitkan kartu keanggotaan baru untuk alamat dompet pengguna
     * @param pengguna Alamat dompet Web3 pengguna
     * @param tier Jenis kartu ('regular', 'silver', 'gold', 'platinum')
     * @param memberHashCode Kode hash unik kartu (sinkron dengan database ParkSmart)
     */
    function terbitkanKeanggotaan(
        address pengguna,
        string memory tier,
        string memory memberHashCode
    ) external hanyaPemilik returns (uint256) {
        require(pengguna != address(0), "Alamat pengguna tidak valid");
        require(bytes(memberHashCode).length > 0, "Kode hash tidak boleh kosong");
        require(!_hashTerdaftar[memberHashCode], "Kode hash kartu sudah terdaftar di blockchain");

        // Validasi agar pengguna tidak memiliki tier ganda yang sama
        KartuMember[] storage daftar = _kartuPengguna[pengguna];
        for (uint256 i = 0; i < daftar.length; i++) {
            require(
                keccak256(bytes(daftar[i].tier)) != keccak256(bytes(tier)),
                "Pengguna sudah memiliki kartu untuk tier ini"
            );
        }

        _totalTokenCounter++;
        uint256 idBaru = _totalTokenCounter;

        // Tambahkan kartu ke array milik pengguna
        _kartuPengguna[pengguna].push(
            KartuMember({
                idToken: idBaru,
                tier: tier,
                kodeHash: memberHashCode,
                waktuPenerbitan: block.timestamp,
                aktif: true
            })
        );

        _hashTerdaftar[memberHashCode] = true;
        statusKeanggotaan[pengguna] = true;

        emit KeanggotaanDiterbitkan(pengguna, idBaru, tier, memberHashCode, block.timestamp);
        emit StatusKeanggotaanDiperbarui(pengguna, true);

        return idBaru;
      }

    /**
     * @notice Mengambil jumlah kartu yang dimiliki oleh suatu alamat dompet
     */
    function hitungKartuPengguna(address pengguna) external view returns (uint256) {
        return _kartuPengguna[pengguna].length;
    }

    /**
     * @notice Mengambil seluruh daftar kartu yang dimiliki oleh suatu alamat dompet
     */
    function dapatkanDaftarKartu(address pengguna) external view returns (KartuMember[] memory) {
        return _kartuPengguna[pengguna];
    }

    /**
     * @notice Memvalidasi apakah kode hash tertentu sah dan aktif di blockchain
     */
    function validasiHash(string memory memberHashCode) external view returns (bool) {
        return _hashTerdaftar[memberHashCode];
    }

    /**
     * @notice Mengecek apakah dompet pengguna memiliki keanggotaan aktif
     */
    function cekStatusKeanggotaan(address pengguna) external view returns (bool) {
        return statusKeanggotaan[pengguna];
    }

    /**
     * @notice Total seluruh token keanggotaan yang telah diterbitkan
     */
    function totalTokenDiterbitkan() external view returns (uint256) {
        return _totalTokenCounter;
    }
}
