import 'package:flutter/material.dart';

class TagWidget extends StatelessWidget {
  const TagWidget({
    Key? key,
    required this.emoji,
    required this.label,
    required this.width
  }) : super(key: key);

  final emoji;
  final label;
  final double width;

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
                    fontSize: 8,
                    color: Colors.purple,
                    fontFamily: 'Nunito'
                )
            )
        ),
      ),
      decoration: BoxDecoration(
        color: Color(0xfff7f6fb),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
