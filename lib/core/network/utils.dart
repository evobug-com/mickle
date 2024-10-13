
import '../database.dart';

List<String> parseMessageMentions(String message, {required Database database}) {
  // Parse message mentions
  List<String> rawMentions = RegExp(r'@(\w+)').allMatches(message).map((e) => e.group(1)).where((e) => e != null).toList().cast();

  // Replace mention with user id
  List<String> mentions = rawMentions.map((e) {
    return database.users.firstWhereOrNull((element) => element.displayName == e)?.id;
  }).where((e) => e != null).toList().cast();


  return mentions;
}