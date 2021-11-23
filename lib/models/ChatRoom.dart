class ChatRoom {
  int id = 0;
  String name = '';

  ChatRoom(id) {
    this.id = id;
    this.name = "Chat room " + (id + 1).toString();
  }
}