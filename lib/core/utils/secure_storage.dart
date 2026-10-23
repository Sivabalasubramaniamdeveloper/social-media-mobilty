import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CustomSecureStorage {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
      synchronizable: false,
    ),
  );

  // Writes a key-value pair securely
  Future<void> writeSecureData(String key, String value) async {
    await secureStorage.write(key: key, value: value);
  }

  // Reads the value for the given key
  Future<String?> readSecureData(String key) async {
    return await secureStorage.read(key: key);
  }

  // Deletes the value for the given key
  Future<void> deleteSecureData(String key) async {
    await secureStorage.delete(key: key);
  }

  // Deletes all stored secure data
  Future<void> deleteAllSecureData() async {
    await secureStorage.deleteAll();
  }
}
