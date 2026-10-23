import 'flavor_config.dart';
import 'package:mineai/main.dart' as app;

Future<void> main() async {
  FlavorConfig.appFlavor = Flavor.uat;
  await app.main();
}
