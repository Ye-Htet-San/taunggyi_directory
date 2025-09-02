import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String userName;
  final String userAvatar;

  const UserAvatar({
    super.key,
    required this.userName,
    required this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    if (userAvatar.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(userAvatar),
      );
    } else {
      String initials = _getInitials(userName);
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.blueAccent,
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
