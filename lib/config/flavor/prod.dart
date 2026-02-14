import 'flavor_config.dart';
import 'package:mineai/main.dart' as app;

Future<void> main() async {
  FlavorConfig.appFlavor = Flavor.prod;
  await app.main();
}
