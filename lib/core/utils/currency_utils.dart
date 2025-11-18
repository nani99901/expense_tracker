class CurrencyUtils {
  static const String defaultCode = 'INR';

  static const Map<String, String> codeToSymbol = {
    'INR': '₹',
    'USD': '4',
    'IDR': 'Rp',
    'JPY': '¥',
    'RUB': '₽',
    'EUR': '€',
    'WON': '₩',
  };

  static const Map<String, String> labelToCode = {
    'India (INR)': 'INR',
    'United States (USD)': 'USD',
    'Indonesia (IDR)': 'IDR',
    'Japan (JPY)': 'JPY',
    'Russia (RUB)': 'RUB',
    'Germany (EUR)': 'EUR',
    'Korea (WON)': 'WON',
  };

  static const Map<String, String> codeToLabel = {
    'INR': 'India (INR)',
    'USD': 'United States (USD)',
    'IDR': 'Indonesia (IDR)',
    'JPY': 'Japan (JPY)',
    'RUB': 'Russia (RUB)',
    'EUR': 'Germany (EUR)',
    'WON': 'Korea (WON)',
  };

  static String symbolForCode(String? code) {
    return codeToSymbol[code] ?? codeToSymbol[defaultCode] ?? '₹';
  }

  static String codeForLabel(String label) {
    return labelToCode[label] ?? defaultCode;
  }

  static String labelForCode(String? code) {
    if (code == null) return codeToLabel[defaultCode] ?? 'India (INR)';
    return codeToLabel[code] ?? codeToLabel[defaultCode] ?? 'India (INR)';
  }
}
