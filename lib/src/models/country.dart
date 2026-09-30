class Country {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });

  /// Pays par défaut : Côte d'Ivoire (+225)
  static const Country defaultCountry = Country(
    name: "Côte d'Ivoire",
    code: "CI",
    dialCode: "+225",
    flag: "🇨🇮",
  );

  /// Formate le numéro complet en concaténant l'indicatif et le numéro saisi
  static String formatFullPhone(Country country, String rawNumber) {
    final clean = rawNumber.trim().replaceAll(RegExp(r'[\s\-]'), '');
    if (clean.startsWith('+')) {
      return clean;
    }
    return '${country.dialCode}$clean';
  }

  /// Liste complète des pays prioritaires et internationaux
  static const List<Country> allCountries = [
    Country(name: "Côte d'Ivoire", code: "CI", dialCode: "+225", flag: "🇨🇮"),
    Country(name: "Bénin", code: "BJ", dialCode: "+229", flag: "🇧🇯"),
    Country(name: "Burkina Faso", code: "BF", dialCode: "+226", flag: "🇧🇫"),
    Country(name: "Cameroun", code: "CM", dialCode: "+237", flag: "🇨🇲"),
    Country(name: "Congo (Brazzaville)", code: "CG", dialCode: "+242", flag: "🇨🇬"),
    Country(name: "RD Congo (Kinshasa)", code: "CD", dialCode: "+243", flag: "🇨🇩"),
    Country(name: "France", code: "FR", dialCode: "+33", flag: "🇫🇷"),
    Country(name: "Gabon", code: "GA", dialCode: "+241", flag: "🇬🇦"),
    Country(name: "Ghana", code: "GH", dialCode: "+233", flag: "🇬🇭"),
    Country(name: "Guinée", code: "GN", dialCode: "+224", flag: "🇬🇳"),
    Country(name: "Mali", code: "ML", dialCode: "+223", flag: "🇲🇱"),
    Country(name: "Niger", code: "NE", dialCode: "+227", flag: "🇳🇪"),
    Country(name: "Nigeria", code: "NG", dialCode: "+234", flag: "🇳🇬"),
    Country(name: "Sénégal", code: "SN", dialCode: "+221", flag: "🇸🇳"),
    Country(name: "Togo", code: "TG", dialCode: "+228", flag: "🇹🇬"),
    Country(name: "Tchad", code: "TD", dialCode: "+235", flag: "🇹🇩"),
    Country(name: "Centrafrique", code: "CF", dialCode: "+236", flag: "🇨🇫"),
    Country(name: "Guinée Équatoriale", code: "GQ", dialCode: "+240", flag: "🇬🇶"),
    Country(name: "Maroc", code: "MA", dialCode: "+212", flag: "🇲🇦"),
    Country(name: "Algérie", code: "DZ", dialCode: "+213", flag: "🇩🇿"),
    Country(name: "Tunisie", code: "TN", dialCode: "+216", flag: "🇹🇳"),
    Country(name: "Belgique", code: "BE", dialCode: "+32", flag: "🇧🇪"),
    Country(name: "Suisse", code: "CH", dialCode: "+41", flag: "🇨🇭"),
    Country(name: "Canada", code: "CA", dialCode: "+1", flag: "🇨🇦"),
    Country(name: "États-Unis", code: "US", dialCode: "+1", flag: "🇺🇸"),
    Country(name: "Royaume-Uni", code: "GB", dialCode: "+44", flag: "🇬🇧"),
    Country(name: "Italie", code: "IT", dialCode: "+39", flag: "🇮🇹"),
    Country(name: "Espagne", code: "ES", dialCode: "+34", flag: "🇪🇸"),
    Country(name: "Allemagne", code: "DE", dialCode: "+49", flag: "🇩🇪"),
    Country(name: "Portugal", code: "PT", dialCode: "+351", flag: "🇵🇹"),
    Country(name: "Madagascar", code: "MG", dialCode: "+261", flag: "🇲🇬"),
    Country(name: "Haïti", code: "HT", dialCode: "+509", flag: "🇭🇹"),
    Country(name: "Rwanda", code: "RW", dialCode: "+250", flag: "🇷🇼"),
    Country(name: "Burundi", code: "BI", dialCode: "+257", flag: "🇧🇮"),
    Country(name: "Mauritanie", code: "MR", dialCode: "+222", flag: "🇲🇷"),
    Country(name: "Comores", code: "KM", dialCode: "+269", flag: "🇰🇲"),
    Country(name: "Liberia", code: "LR", dialCode: "+231", flag: "🇱🇷"),
    Country(name: "Sierra Leone", code: "SL", dialCode: "+232", flag: "🇸🇱"),
    Country(name: "Angola", code: "AO", dialCode: "+244", flag: "🇦🇴"),
    Country(name: "Cap-Vert", code: "CV", dialCode: "+238", flag: "🇨🇻"),
    Country(name: "Guinée-Bissau", code: "GW", dialCode: "+245", flag: "🇬🇼"),
    Country(name: "Éthiopie", code: "ET", dialCode: "+251", flag: "🇪🇹"),
    Country(name: "Kenya", code: "KE", dialCode: "+254", flag: "🇰🇪"),
    Country(name: "Tanzanie", code: "TZ", dialCode: "+255", flag: "🇹🇿"),
    Country(name: "Ouganda", code: "UG", dialCode: "+256", flag: "🇺🇬"),
    Country(name: "Afrique du Sud", code: "ZA", dialCode: "+27", flag: "🇿🇦"),
    Country(name: "Égypte", code: "EG", dialCode: "+20", flag: "🇪🇬"),
    Country(name: "Brésil", code: "BR", dialCode: "+55", flag: "🇧🇷"),
    Country(name: "Chine", code: "CN", dialCode: "+86", flag: "🇨🇳"),
    Country(name: "Inde", code: "IN", dialCode: "+91", flag: "🇮🇳"),
    Country(name: "Émirats Arabes Unis", code: "AE", dialCode: "+971", flag: "🇦🇪"),
    Country(name: "Arabie Saoudite", code: "SA", dialCode: "+966", flag: "🇸🇦"),
    Country(name: "Liban", code: "LB", dialCode: "+961", flag: "🇱🇧"),
    Country(name: "Turquie", code: "TR", dialCode: "+90", flag: "🇹🇷"),
    Country(name: "Pays-Bas", code: "NL", dialCode: "+31", flag: "🇳🇱"),
    Country(name: "Luxembourg", code: "LU", dialCode: "+352", flag: "🇱🇺"),
  ];
}
