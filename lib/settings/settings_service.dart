import '../widgets/dialogs.dart';
import '../models.dart';
import 'tools.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  ConfigFileHander configFileHander = ConfigFileHander('jsons/');

  ///Loads the User's preferred settings from local or remote storage.
  Future<Settings> settings() async => configFileHander.readSettings();

  /// Saves the User's preferred settings to local or remote storage.
  Future<bool> updateSettings(Settings settings) async {
    final bool success = await configFileHander.writeSettings(settings);
    if (!success) {
      resultDialog('Save Settings', false);
    }
    return success;
  }

  /// Saves the User's preferred webCrawler settings to local or remote storage.
  Future<bool> updateWebCrawlerSettings(
      WebCrawlerSettings webCrawlerSettings) async {
    final bool success =
        await configFileHander.writeWebCrawlerSettings(webCrawlerSettings);
    if (!success) {
      resultDialog('Save webCrawler Settings', false);
    }
    return success;
  }
}
