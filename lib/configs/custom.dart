class CustomJson {
  static const String banner = "assets/customJson/bannerImages.json";
  

  ///Singleton factory
  static final CustomJson _instance = CustomJson._internal();

  factory CustomJson() {
    return _instance;
  }

  CustomJson._internal();
}
