import 'package:busapp/shared/network/local_network.dart';

class UserModel {
  final int id;
  final String customId;
  final String firstName;
  final String lastName;
  final String email;
  final Balance balance;
  final String token;
  final String image;

  UserModel({
    required this.id,
    required this.customId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.balance,
    required this.token,
    required this.image,

  });

  // Add this copyWith method
  UserModel copyWith({
    int? id,
    String? customId,
    String? firstName,
    String? lastName,
    String? email,
    Balance? balance,
    String? token,
    String? image,
  }) {
    return UserModel(
      id: id ?? this.id,
      customId: customId ?? this.customId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      balance: balance ?? this.balance,
      token: token ?? this.token,
      image: image ?? this.image,
    );
  }
  @override
  String toString() {
    return 'UserModel(id: $id, name: $firstName $lastName, email: $email, image: $image, token: $token)';
  }
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final user = data['user'] ?? {};
    final balance = user['balance'] ?? {};

    return UserModel(
      id: (user['id'] as int?) ?? 0,
      customId: (user['custom_id'] as String?) ?? '',
      firstName: (user['first_name'] as String?) ?? '',
      lastName: (user['last_name'] as String?) ?? '',
      email: (user['email'] as String?) ?? '',
      balance: Balance(
        id: (balance['id'] as int?) ?? 0,
        points: (balance['points'] as int?) ?? 0,
        userId: (balance['user_id'] as String?) ?? '',
      ),
      token: (data['token'] as String?) ?? '',
      image: (data['user']['image'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'data': {
          'user': {
            'id': id,
            'custom_id': customId,
            'first_name': firstName,
            'last_name': lastName,
            'email': email,
            'balance': balance.toJson(),
            'image': image,
          },
          'token': token,
        },
      };

  // You can keep this method or replace it with copyWith
  UserModel updateBalance(int newPoints) {
    return copyWith(
      balance: balance.copyWith(points: newPoints),
    );
  }
}

class Balance {
  final int id;
  final int points;
  final String userId;

  Balance({
    required this.id,
    required this.points,
    required this.userId,
  });

  // Add this copyWith method
  Balance copyWith({
    int? id,
    int? points,
    String? userId,
  }) {
    return Balance(
      id: id ?? this.id,
      points: points ?? this.points,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'points': points,
    'user_id': userId,
  };

  
}


















/*
class UserModel {
  final int id;
  final String customId;
  final String firstName;
  final String email;
  final Balance balance;
  final String token;

  UserModel({
    required this.id,
    required this.customId,
    required this.firstName,
    required this.email,
    required this.balance,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final user = data['user'] ?? {};
    final balance = user['balance'] ?? {};

    return UserModel(
      id: (user['id'] as int?) ?? 0,
      customId: (user['custom_id'] as String?) ?? '',
      firstName: (user['first_name'] as String?) ?? '',
      email: (user['email'] as String?) ?? '',
      balance: Balance(
        id: (balance['id'] as int?) ?? 0,
        points: (balance['points'] as int?) ?? 0,
        userId: (balance['user_id'] as String?) ?? '',
      ),
      token: (data['token'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'data': {
          'user': {
            'id': id,
            'custom_id': customId,
            'first_name': firstName,
            'email': email,
            'balance': balance.toJson(),
          },
          'token': token,
        },
      };

  // Method to update the user's balance only
  UserModel updateBalance(int newPoints) {
    // Return a new UserModel instance with the updated balance
    return UserModel(
      id: id, // Keep other fields unchanged
      customId: customId,
      firstName: firstName,
      email: email,
      balance: Balance(
        id: balance.id,
        points: newPoints, // Update the points value only
        userId: balance.userId,
      ),
      token: token,
    );
  }
}


class Balance {
  final int id;
  final int points;
  final String userId;

  Balance({
    required this.id,
    required this.points,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'points': points,
        'user_id': userId,
      };
}
*/

