class MessageModel {
  final String id;
  final String senderId;
  final String message;
  final bool isMe;
  final String time;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.message,
    required this.isMe,
    required this.time,
  });
}
