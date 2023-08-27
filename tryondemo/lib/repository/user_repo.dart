import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String user_id;
  var user_uuid;

  final String user_pw;

  User({
    required this.user_id,
    required this.user_uuid,
    required this.user_pw,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        user_id: json['user_id'],
        user_uuid: json['user_uuid'],
        user_pw: json['user_pw'],
      );

  Map<String, dynamic> toJson() => {
        'user_id': user_id,
        'user_uuid': user_uuid,
        'user_pw': user_pw,
      };

  @override
  List<Object?> get props => [
        user_id,
      ];
}
