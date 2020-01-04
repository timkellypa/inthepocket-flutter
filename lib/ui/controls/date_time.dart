import 'package:flutter/widgets.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
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
  DateTimeControlState({TextEditingController controller}) {
    _controller = controller;
  }

  TextEditingController _controller;

  final DateFormat format = DateFormat('yyyy-MM-dd HH:mm');
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      DateTimeField(
        format: format,
        controller: _controller,
        onShowPicker: (BuildContext context, DateTime currentValue) async {
          final DateTime date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
          if (date != null) {
            final TimeOfDay time = await showTimePicker(
              context: context,
              initialTime:
                  TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );
            return DateTimeField.combine(date, time);
          } else {
            return currentValue;
          }
        },
      ),
    ]);
  }
}
