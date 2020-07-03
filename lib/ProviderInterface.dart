abstract class ProviderInterface {
  String name;
  String publicUrl;
  String url;

  Future<String> fetchData();
}
