import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
// For changing the language

class DateTimeControl extends StatefulWidget {
  const DateTimeControl(this._controller);

  final TextEditingController _controller;

  @override
  State<StatefulWidget> createState() {
    return DateTimeControlState(controller: _controller);
  }
}

class DateTimeControlState extends State<DateTimeControl> {
  DateTimeControlState({required TextEditingController controller}) {
    _controller = controller;
  }

  late TextEditingController _controller;

  static DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      TextField(
        controller: _controller,
        onTap: () {
          DateTime initialDate;
          try {
            initialDate = dateFormat.parse(_controller.text);
          } on FormatException {
            initialDate = DateTime.now();
          }
          DatePicker.showDatePicker(
            currentTime: initialDate,
            context,
            onConfirm: (DateTime date) {
              _controller.text = dateFormat.format(date);
            },
          );
        },
      ),
    ]);
  }
}
