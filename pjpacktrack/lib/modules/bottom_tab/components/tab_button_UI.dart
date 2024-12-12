import 'package:flutter/material.dart';
import 'package:pjpacktrack/constants/text_styles.dart';
import 'package:pjpacktrack/constants/themes.dart';

class TabButtonUI extends StatelessWidget {
  final IconData icon;
  final Function()? onTap;
  final bool isSelected;
  final String text;
  final double iconSize; // Kích thước icon
  final double fontSize; // Kích thước chữ

  const TabButtonUI({
    Key? key,
    this.onTap,
    required this.icon,
    required this.isSelected,
    required this.text,
    this.iconSize = 20, // Mặc định 20
    this.fontSize = 10, // Mặc định 12
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? AppTheme.primaryColor : AppTheme.secondaryTextColor;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Theme.of(context).primaryColor.withOpacity(0.2),
          onTap: onTap,
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 4,
              ),
              SizedBox(
                width: 40,
                height: 32,
                child: Icon(
                  icon,
                  size: iconSize,
                  color: color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyles(context).getDescriptionStyle().copyWith(
                          color: color,
                        ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
