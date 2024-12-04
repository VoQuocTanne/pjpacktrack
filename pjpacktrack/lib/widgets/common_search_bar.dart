import 'package:flutter/material.dart';

class CommonSearchBar extends StatelessWidget {
  final String? text;
  final bool enabled, ishsow;
  final double height;
  final IconData? iconData;
  final Function(String)? onChanged;  // Callback to handle search input

  const CommonSearchBar({
    Key? key,
    this.text,
    this.enabled = false,
    this.height = 48,
    this.iconData,
    this.ishsow = true,
    this.onChanged,  // Callback for search input
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: SizedBox(
        height: height,
        child: Center(
          child: Row(
            children: <Widget>[
              ishsow == true
                  ? Icon(
                      iconData,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    )
                  : const SizedBox(),
              ishsow == true
                  ? const SizedBox(width: 8)
                  : const SizedBox(),
              Expanded(
                child: TextField(
                  maxLines: 1,
                  enabled: enabled,
                  onChanged: onChanged,  // Trigger search when text changes
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0),
                    errorText: null,
                    border: InputBorder.none,
                    hintText: text,
                    hintStyle: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
