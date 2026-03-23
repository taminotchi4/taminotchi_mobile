class AppValidators {
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username kiritilishi shart';
    }
    
    if (value.length < 3) {
      return 'Kamida 3 ta belgi bo\'lishi kerak';
    }
    
    if (value.length > 20) {
      return 'Ko\'pi bilan 20 ta belgi bo\'lishi kerak';
    }
    
    // Must start with a letter
    if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
      return 'Faqat harf bilan boshlanishi kerak';
    }
    
    // Only letters, numbers and _
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Faqat harf, raqam va _ qatnashishi mumkin';
    }
    
    // _ only in middle (not at the end)
    if (value.endsWith('_')) {
      return '_ belgisi oxirida kelishi mumkin emas';
    }
    
    return null;
  }
}
