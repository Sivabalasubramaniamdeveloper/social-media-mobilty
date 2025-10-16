enum Flavor { dev, prod, sit }

class FlavorConfig {
  static Flavor? appFlavor;

  static String get title {
    switch (appFlavor) {
      default:
        return 'Example App';
    }
  }

  static bool get isDevelopment {
    switch (appFlavor) {
      default:
        return false;
    }
  }
}
