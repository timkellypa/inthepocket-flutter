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

  final DateFormat format = DateFormat('yyyy-MM-dd HH:mm');
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      IconButton(
        icon: const Icon(Icons.calendar_month),
        onPressed: () => {
          DatePicker.showDatePicker(
            context,
            onChanged:(DateTime time) {
              _controller.text = time.toString();
            },
          )
        }
      ),
    ]);
  }
}
