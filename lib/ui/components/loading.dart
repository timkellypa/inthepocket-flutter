import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({String text = 'Loading...'}) : _text = text;

  final String _text;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircularProgressIndicator(),
            Text(_text,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }
}
