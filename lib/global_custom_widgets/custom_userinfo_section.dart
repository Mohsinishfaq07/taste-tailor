// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class UserInfoSection extends StatelessWidget {
  UserInfoSection({super.key, required this.image});
  String image;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
            radius: 32,
            child: ClipOval(
                child: image == ""
                    ? const Icon(
                        Icons.person,
                        size: 30,
                      )
                    : Image.network(
                        image,
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                      ))),
      ],
    );
  }
}
