enum Flavor { dev, prod, uat }

class FlavorConfig {
  static Flavor? appFlavor;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'MINE AI DEV';
      case Flavor.prod:
        return 'MINE AI PROD';
      case Flavor.uat:
        return 'MINE AI UAT';
      default:
        return 'MINE AI';
    }
  }

  static bool get isDevelopment {
    switch (appFlavor) {
      case Flavor.dev:
        return true;
      case Flavor.prod:
        return false;
      case Flavor.uat:
        return true;
      default:
        return false;
    }
  }

  static bool get isMINEAI {
    switch (appFlavor) {
      case Flavor.dev:
        return true;
      case Flavor.prod:
        return true;
      case Flavor.uat:
        return true;
      default:
        return true;
    }
  }
}
