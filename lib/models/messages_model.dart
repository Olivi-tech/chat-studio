class MessagesModel {
  MessagesModel({
    required this.toId,
    required this.msg,
    required this.type,
    required this.sent,
    required this.fromId,
    required this.read,
  });
  late final String toId;
  late final String msg;
  late final Type type;
  late final String sent;
  late final String fromId;
  late final String read;

  MessagesModel.fromJson(Map<String, dynamic> json) {
    toId = json['toId'];
    msg = json['msg'];
    type = json['type'] == Type.image.name ? Type.image : Type.text;
    sent = json['sent'];
    fromId = json['fromId'];
    read = json['read'];
  }
  static final String keyToId = 'toId';
  static final String keyMsg = 'msg';
  static final String keyType = 'type';
  static final String keySent = 'sent';
  static final String keyFromId = 'fromId';
  static final String keyRead = 'read';

  Map<String, dynamic> toJson() {
    return {
      keyToId: toId,
      keyMsg: msg,
      keyType: type.name,
      keySent: sent,
      keyFromId: fromId,
      keyRead: read,
    };
  }
}

enum Type { image, text }
