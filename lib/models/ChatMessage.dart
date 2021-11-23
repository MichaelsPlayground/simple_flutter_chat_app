class ChatMessage {
  String message = "";
  String type = "";
  DateTime date = new DateTime.now();

  ChatMessage(message, type, DateTime readTimeStamp) {
    this.message = message;
    this.type = type;
    date = DateTime.now();
  }

  String? get nickname => null;
}
