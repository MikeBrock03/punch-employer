import 'package:flutter/material.dart';
import '../../../helpers/app_localizations.dart';
import 'time_picker_field.dart';

class ClockFields extends StatefulWidget {

  final GlobalKey<ScaffoldState> globalScaffoldKey;
  final bool submitSt;
  final DateTime now;
  DateTime dayInTime;
  DateTime dayOutTime;
  final String weekName;
  final int type;
  final String id;
  final Function() onAddTimeField;
  final Function(Widget instance) onRemoveTimeField;
  final Function(String id, DateTime time, int type) onSelect;
  final int index;

  ClockFields({ this.globalScaffoldKey, this.submitSt, this.now,
                this.dayInTime, this.dayOutTime, this.weekName,
                this.onAddTimeField, this.onRemoveTimeField,
                this.type, this.id, this.onSelect, this.index});

  @override
  _ClockFieldsState createState() => _ClockFieldsState();
}

class _ClockFieldsState extends State<ClockFields> {

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        Expanded(
          child: TimePickerField(
            enabled: widget.submitSt,
            onTimePicked: (time){
              setState(() {
                if(time != null){
                  widget.dayInTime = DateTime(widget.now.year, widget.now.month, widget.now.day, time.hour, time.minute);
                  widget.onSelect(widget.id, DateTime(widget.now.year, widget.now.month, widget.now.day, time.hour, time.minute), 1);
                }else{
                  widget.dayInTime = null;
                  widget.onSelect(widget.id, null, 1);
                }
              });
            },
            value: widget.dayInTime,
            hint: AppLocalizations.of(context).translate('clock_id'),
            helpText: '${AppLocalizations.of(context).translate(widget.weekName)} ${AppLocalizations.of(context).translate('clock_id')} time',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: TimePickerField(
            enabled: widget.submitSt,
            onTimePicked: (time){
              setState(() {
                if(time != null){
                  widget.dayOutTime = DateTime(widget.now.year, widget.now.month, widget.now.day, time.hour, time.minute);
                  widget.onSelect(widget.id, DateTime(widget.now.year, widget.now.month, widget.now.day, time.hour, time.minute), 2);
                }else{
                  widget.dayOutTime = null;
                  widget.onSelect(widget.id, null, 2);
                }
              });
            },
            value: widget.dayOutTime,
            hint: AppLocalizations.of(context).translate('clock_out'),
            helpText: '${AppLocalizations.of(context).translate(widget.weekName)} ${AppLocalizations.of(context).translate('clock_out')} time',
          ),
        ),
      ],
    );
  }
}