class StatusSvgProvider {
  static final Map<String, String> _statusSvgMap = {
    'GİRMEK': 'assets/images/vector/entered-garage.svg',
    'SORUN GİDERME': 'assets/images/vector/note.svg',
    'BAŞLANGIÇ': 'assets/images/vector/play.svg',
    'DURAKLAT': 'assets/images/vector/pause.svg',
    'İŞ BİTTİ': 'assets/images/vector/finish-flag.svg',
  };

  static String? getSvgPath(String status) {
    return _statusSvgMap[status];
  }
}
