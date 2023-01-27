class ChattingUsersModel {
  late String createdAt;
  late String image;
  late String lastActive;
  late String about;
  late String name;
  late bool isOnline;
  late String id;
  late String pushToken;
  late String email;
  ChattingUsersModel({
    required this.createdAt,
    required this.image,
    required this.lastActive,
    required this.about,
    required this.name,
    required this.isOnline,
    required this.id,
    required this.pushToken,
    required this.email,
  });

  static String keyCreatedAt = 'createdAt';
  static String keyImage = 'image';
  static String keyLastActive = 'lastActive';
  static String keyAbout = 'about';
  static String keyName = 'name';
  static String keyIsOnline = 'isOnline';
  static String keyId = 'id';
  static String keyEmail = 'email';
  static String keyPushToken = 'pushToken';

  Map<String, dynamic> toJson() {
    return {
      keyCreatedAt: createdAt,
      keyName: name,
      keyAbout: about,
      keyImage: image,
      keyId: id,
      keyLastActive: lastActive,
      keyIsOnline: isOnline,
      keyPushToken: pushToken,
      keyEmail: email
    };
  }

  ChattingUsersModel.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    image = json['image'];
    lastActive = json['lastActive'];
    about = json['about'];
    name = json['name'];
    isOnline = json['isOnline'];
    id = json['id'];
    email = json['email'];
    pushToken = json['pushToken'];
  }
}
