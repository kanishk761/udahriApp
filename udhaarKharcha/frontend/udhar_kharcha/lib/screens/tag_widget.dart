import 'package:flutter/material.dart';

class TagWidget extends StatelessWidget {
  TagWidget({
    Key? key,
    required this.emoji,
    required this.label,
    required this.width,
    this.color
  }) : super(key: key);

  final emoji;
  final label;
  final double width;
  int? color;

  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 20,
      child: Center(
        child: RichText(
            overflow: TextOverflow.fade,
            softWrap: false,
            text: TextSpan(
                text: '${emoji} ${label}',
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.purple,
                    fontFamily: 'Nunito'
                )
            )
        ),
      ),
      decoration: BoxDecoration(
        color: color == null ? Color(0xfff7f6fb) : Color(color!) ,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
