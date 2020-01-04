import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
            border: Border(
          top: BorderSide(color: Colors.grey, width: 0.3),
        )),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.indigoAccent,
                size: 28,
              ),
              onPressed: () {
                //just re-pull UI for testing purposes
              },
            ),
          ],
        ),
      ),
    );
  }
}
