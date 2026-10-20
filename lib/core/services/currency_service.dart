import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;
  final String flag;
  final int decimals;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
    this.decimals = 2,
  });
}

class CurrencyService extends ChangeNotifier {
  static final CurrencyService instance = CurrencyService._internal();

  CurrencyService._internal();

  static const String _prefsCurrencyKey = 'selected_currency_code';
  static const String _prefsConversionEnabledKey = 'currency_conversion_enabled';
  static const String _prefsRatesKey = 'cached_currency_rates';
  static const String _prefsLastUpdatedKey = 'currency_last_updated';

  // Supported Currencies
  static const Map<String, CurrencyInfo> supportedCurrencies = {
    'IDR': CurrencyInfo(
      code: 'IDR',
      name: 'Rupiah Indonesia',
      symbol: 'Rp',
      flag: '🇮🇩',
      decimals: 0,
    ),
    'USD': CurrencyInfo(
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
      flag: '🇺🇸',
      decimals: 2,
    ),
    'EUR': CurrencyInfo(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      flag: '🇪🇺',
      decimals: 2,
    ),
    'SGD': CurrencyInfo(
      code: 'SGD',
      name: 'Singapore Dollar',
      symbol: 'S\$',
      flag: '🇸🇬',
      decimals: 2,
    ),
    'MYR': CurrencyInfo(
      code: 'MYR',
      name: 'Ringgit Malaysia',
      symbol: 'RM',
      flag: '🇲🇾',
      decimals: 2,
    ),
    'JPY': CurrencyInfo(
      code: 'JPY',
      name: 'Japanese Yen',
      symbol: '¥',
      flag: '🇯🇵',
      decimals: 0,
    ),
  };

  bool _isConversionEnabled = false;
  String _currentCurrency = 'IDR';
  Map<String, double> _rates = {
    'IDR': 1.0,
    'USD': 0.0000558,
    'EUR': 0.0000501,
    'SGD': 0.0000714,
    'MYR': 0.000228,
    'JPY': 0.00883,
  };
  DateTime? _lastUpdated;
  bool _isLoading = false;

  bool get isConversionEnabled => _isConversionEnabled;
  String get currentCurrency => _isConversionEnabled ? _currentCurrency : 'IDR';
  CurrencyInfo get currentInfo =>
      supportedCurrencies[currentCurrency] ?? supportedCurrencies['IDR']!;
  Map<String, double> get rates => _rates;
  DateTime? get lastUpdated => _lastUpdated;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isConversionEnabled = prefs.getBool(_prefsConversionEnabledKey) ?? false;
    _currentCurrency = prefs.getString(_prefsCurrencyKey) ?? 'IDR';

    final cachedRates = prefs.getString(_prefsRatesKey);
    if (cachedRates != null) {
      try {
        final decoded = jsonDecode(cachedRates) as Map<String, dynamic>;
        _rates = decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
      } catch (_) {}
    }

    final lastUpdatedStr = prefs.getString(_prefsLastUpdatedKey);
    if (lastUpdatedStr != null) {
      _lastUpdated = DateTime.tryParse(lastUpdatedStr);
    }

    notifyListeners();

    // Fetch live rates asynchronously
    fetchLatestRates();
  }

  Future<bool> fetchLatestRates() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/IDR'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['result'] == 'success' && data['rates'] != null) {
          final newRatesRaw = data['rates'] as Map<String, dynamic>;
          final Map<String, double> parsedRates = {};

          for (final code in supportedCurrencies.keys) {
            if (newRatesRaw.containsKey(code)) {
              parsedRates[code] = (newRatesRaw[code] as num).toDouble();
            } else if (_rates.containsKey(code)) {
              parsedRates[code] = _rates[code]!;
            }
          }
          parsedRates['IDR'] = 1.0;

          _rates = parsedRates;
          _lastUpdated = DateTime.now();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_prefsRatesKey, jsonEncode(_rates));
          await prefs.setString(
              _prefsLastUpdatedKey, _lastUpdated!.toIso8601String());

          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch real-time currency rates: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> toggleConversion(bool enabled) async {
    _isConversionEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsConversionEnabledKey, enabled);
  }

  Future<void> setCurrency(String code) async {
    if (!supportedCurrencies.containsKey(code)) return;
    _currentCurrency = code;
    _isConversionEnabled = (code != 'IDR');
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsCurrencyKey, code);
    await prefs.setBool(_prefsConversionEnabledKey, _isConversionEnabled);
  }

  /// Convert amount from IDR base to target currency purely on the UI display
  double convert(num amountInIdr, [String? targetCurrency]) {
    if (!_isConversionEnabled) return amountInIdr.toDouble();
    final code = targetCurrency ?? _currentCurrency;
    if (code == 'IDR') return amountInIdr.toDouble();
    final rate = _rates[code] ?? 1.0;
    return amountInIdr.toDouble() * rate;
  }

  /// Format an amount in IDR into the active currency string
  String format(num amountInIdr, {bool includeCode = false}) {
    final info = currentInfo;
    final converted = convert(amountInIdr);

    if (info.code == 'IDR') {
      final formatted = amountInIdr.round().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
          );
      return includeCode ? 'Rp $formatted IDR' : 'Rp $formatted';
    }

    // Number formatting for other currencies
    String numStr;
    if (info.decimals == 0) {
      numStr = converted.round().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
          );
    } else {
      final fixed = converted.toStringAsFixed(info.decimals);
      final parts = fixed.split('.');
      final whole = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
      numStr = '$whole.${parts[1]}';
    }

    if (includeCode) {
      return '${info.symbol} $numStr ${info.code}';
    }
    return '${info.symbol} $numStr';
  }

  /// Returns exchange rate string relative to 1 unit of target currency
  String getRateString(String targetCode) {
    if (targetCode == 'IDR') return '1 IDR = Rp 1';
    final rate = _rates[targetCode];
    if (rate == null || rate == 0) return '-';
    final idrPerUnit = 1.0 / rate;
    final formatted = idrPerUnit.round().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    final targetInfo = supportedCurrencies[targetCode];
    final sym = targetInfo?.symbol ?? targetCode;
    return '1 $targetCode ($sym) ≈ Rp $formatted';
  }
}
