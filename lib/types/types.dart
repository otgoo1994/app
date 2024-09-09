class Login {
  final String result;
  final Map<String, dynamic>? id;

  Login({required this.result, this.id});

  // Factory constructor to create a User from JSON
  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      result       : json['result'],
      id           : json['id']
    );
  }
}


class KioskContentList {
  final String? result;
  final List<dynamic> photos;
  final List<dynamic> videos;

  KioskContentList({
    this.result,
    required this.photos,
    required this.videos,
  });

  factory KioskContentList.fromJson(Map<String, dynamic> json) {
    return KioskContentList(
      result              : json['result'],
      photos              : json['photos'],
      videos              : json['videos'],
    );
  }
}

class KioskContent {
  final int id;
  final String name;
  final String created_at;
  final String end_at;
  final int userId;
  final int active;
  final String extn;
  final String description;
  final int? second;

  KioskContent({
    required this.id,
    required this.name,
    required this.created_at,
    required this.end_at,
    required this.userId,
    required this.active,
    required this.extn,
    required this.description,
    this.second,
  });


  factory KioskContent.fromJson(Map<String, dynamic> json) {
    return KioskContent(
      id                  : json['id'],
      name                : json['name'],
      created_at          : json['created_at'],
      end_at              : json['end_at'],
      userId              : json['userId'],
      active              : json['active'],
      extn                : json['extn'],
      description         : json['description'],
      second              : json['second']
    );
  }
}