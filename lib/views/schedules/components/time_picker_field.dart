import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class TimePickerField extends StatefulWidget {

  final Function(TimeOfDay timeOfDay) onTimePicked;
  final String hint;
  final String helpText;
  final DateTime value;
  final bool enabled;

  TimePickerField({ this.onTimePicked, this.hint, this.helpText, this.value, this.enabled });

  @override
  _TimePickerFieldState createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<TimePickerField> {

  String selectedTime;

  @override
  void initState() {
    super.initState();

    if(widget.value != null){
      selectedTime = '${widget.hint}: ${ widget.value.hour.toString().padLeft(2, '0')}:${ widget.value.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      child: Container(
        height: 53,
        margin: EdgeInsets.only(top: 12),
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[500],
            style: BorderStyle.solid,
            width: 1.0,
          ),
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(child: Text(selectedTime != null ? selectedTime :widget.hint, style: TextStyle(fontSize: 14 ,color: selectedTime != null ? Colors.green[500] : Colors.grey[500]))),
      ),
    );
  }

  Future<TimeOfDay> getSelectedTime({ String helpText }){
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: helpText,
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
            buttonTheme: ButtonThemeData(
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryColor,
              ),
            ),
          ),
          child: child,
        );
      },
    );
  }
}
