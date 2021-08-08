abstract class MainProvider {
  String _name;
  String _publicUrl;
  String _url;
  String _logo;

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get logo => _logo;

  set logo(String value) {
    _logo = value;
  }

  String get publicUrl => _publicUrl;

  set publicUrl(String value) {
    _publicUrl = value;
  }

  String get url => _url;

  set url(String value) {
    _url = value;
  }
}
