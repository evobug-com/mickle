class ErrorItem {
  final String title;
  final String message;
  final DateTime time = DateTime.now();

  ErrorItem(this.title, this.message);

  @override
  String toString() {
    return "$time\n$title\n$message";
  }
}
