import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Button that has an icon, title label and value label.
class OptionButton extends StatelessWidget {
  /// Create a new [OptionButton] by providing values for all properties.
  OptionButton({
    @required this.imageAssetName,
    @required this.title,
    @required this.value,
    @required this.onTapped,
  });

  /// The name of the [Image] asset to display for the icon.
  final String imageAssetName;

  /// The title text.
  final String title;

  /// The value text.
  final String value;

  /// The callback executed when the button is clicked
  final VoidCallback onTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  child: Image.asset(
                    imageAssetName,
                    color: const Color(0xAAFFFFFF),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0x99ffffff),
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        color: const Color(0xffffffff),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          highlightColor: const Color(0x11FFFFFF),
          splashColor: const Color(0x33FFFFFF),
          onTap: onTapped,
        ),
      ),
    );
  }
}
