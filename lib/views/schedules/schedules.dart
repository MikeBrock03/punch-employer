import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:punch_app/models/clock_field_model.dart';
import '../../helpers/fading_edge_scrollview.dart';
import '../../helpers/app_localizations.dart';
import '../../models/user_model.dart';
import 'components/clock_fields.dart';
import 'components/time_picker_field.dart';

class Schedules extends StatefulWidget {

  UserModel intern;
  String from;
  Schedules({ this.intern, this.from });

  @override
  _SchedulesState createState() => _SchedulesState();
}

class _SchedulesState extends State<Schedules> {

  final _globalScaffoldKey = GlobalKey<ScaffoldState>();

  DateTime satInTime, satOutTime, sunInTime, sunOutTime, monInTime, monOutTime,
      tusInTime, tusOutTime, wedInTime, wedOutTime, thiInTime, thiOutTime,
      friInTime, friOutTime;

  List<ClockFieldModel> sunModelList = [];
  List<ClockFieldModel> monModelList = [];
  List<ClockFieldModel> tusModelList = [];
  List<ClockFieldModel> wedModelList = [];
  List<ClockFieldModel> thiModelList = [];
  List<ClockFieldModel> friModelList = [];
  List<ClockFieldModel> satModelList = [];

  @override
  void initState() {
    super.initState();

    if(widget.intern != null){

      Iterable sunSchedules = widget.intern.schedules['sun'];
      sunSchedules.forEach((element) {
        sunModelList.add(
            ClockFieldModel(day: 'sunday', clockIn: element['clockIn'] != null ? DateTime.parse(element['clockIn'].toDate().toString()) : null, clockOut: element['clockOut'] != null ? DateTime.parse(element['clockOut'].toDate().toString()) : null)
        );
      });

      Iterable monSchedules = widget.intern.schedules['mon'];
      monSchedules.forEach((element) {
        monModelList.add(
            ClockFieldModel(day: 'monday', clockIn: element['clockIn'] != null ? DateTime.parse(element['clockIn'].toDate().toString()) : null, clockOut: element['clockOut'] != null ? DateTime.parse(element['clockOut'].toDate().toString()) : null)
        );
      });

      Iterable tueSchedules = widget.intern.schedules['tue'];
      tueSchedules.forEach((element) {
        tusModelList.add(
            ClockFieldModel(day: 'tuesday', clockIn: element['clockIn'] != null ? DateTime.parse(element['clockIn'].toDate().toString()) : null, clockOut: element['clockOut'] != null ? DateTime.parse(element['clockOut'].toDate().toString()) : null)
        );
      });

      Iterable wedSchedules = widget.intern.schedules['wed'];
      wedSchedules.forEach((element) {
        wedModelList.add(
            ClockFieldModel(day: 'wednesday', clockIn: element['clockIn'] != null ? DateTime.parse(element['clockIn'].toDate().toString()) : null, clockOut: element['clockOut'] != null ? DateTime.parse(element['clockOut'].toDate().toString()) : null)
        );
      });

      Iterable thuSchedules = widget.intern.schedules['thu'];
      thuSchedules.forEach((element) {
        thiModelList.add(
            ClockFieldModel(day: 'thursday', clockIn: element['clockIn'] != null ? DateTime.parse(element['clockIn'].toDate().toString()) : null, clockOut: element['clockOut'] != null ? DateTime.parse(element['clockOut'].toDate().toString()) : null)
        );
      });

      Iterable friSchedules = widget.intern.schedules['fri'];
      friSchedules.forEach((element) {
        friModelList.add(
            ClockFieldModel(day: 'friday', clockIn: element['clockIn'] != null ? DateTime.parse(element['clockIn'].toDate().toString()) : null, clockOut: element['clockOut'] != null ? DateTime.parse(element['clockOut'].toDate().toString()) : null)
        );
      });

      Iterable satSchedules = widget.intern.schedules['sat'];
      satSchedules.forEach((element) {
        satModelList.add(
            ClockFieldModel(day: 'saturday', clockIn: element['clockIn'] != null ? DateTime.parse(element['clockIn'].toDate().toString()) : null, clockOut: element['clockOut'] != null ? DateTime.parse(element['clockOut'].toDate().toString()) : null)
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _globalScaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('schedules'), style: TextStyle(fontSize: 18)),
        centerTitle: true,
        brightness: Brightness.dark,
      ),
      backgroundColor: Colors.white,
      body: clocksDetailBody(),
    );
  }

  Widget clocksDetailBody(){

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Hero(
              tag: widget.from+widget.intern.uID,
              child: Container(
                  width: 130,
                  height: 130,
                  margin: EdgeInsets.only(top: 50),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(600),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: widget.intern.imageURL != null && widget.intern.imageURL != '' ? ClipRRect(
                    borderRadius: BorderRadius.circular(600),
                    child: CachedNetworkImage(
                      placeholder:(context, url) => Container(color: Colors.grey[200]),
                      imageUrl: widget.intern.imageURL,
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                    ),
                  ) : ClipRRect(borderRadius: BorderRadius.circular(600), child: Container(padding: EdgeInsets.all(5) ,color: Colors.grey[200], child: Center(child: Text(widget.intern.firstName, style: TextStyle(fontSize: 13, color: Colors.grey[500], decoration: TextDecoration.none), textAlign: TextAlign.center))))
              ),
            ),
          ),

          SizedBox(height: 20),
          Text('${widget.intern.firstName} ${widget.intern.lastName}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          SizedBox(height: 20),
          Divider(),
          SizedBox(height: 20),
          Expanded(
            child: FadingEdgeScrollView.fromListView(
              child: ListView(
                  controller: ScrollController(),
                  physics: BouncingScrollPhysics(),
                  children: [

                    FadeIn(
                      child: Column(
                          children: [
                            Form(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[

                                    SizedBox(height: 5),

                                    Center(child: Text(AppLocalizations.of(context).translate('schedules'), style: TextStyle(fontSize: 18 ,color: Colors.grey[600], fontWeight: FontWeight.bold))),

                                    SizedBox(height: 30),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(AppLocalizations.of(context).translate('sunday'), style: TextStyle(fontSize: 16 ,color: Colors.grey[600], fontWeight: FontWeight.normal)),
                                    ),

                                    ...getClockFields('sunday', sunModelList),

                                    SizedBox(height: 30),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(AppLocalizations.of(context).translate('monday'), style: TextStyle(fontSize: 16 ,color: Colors.grey[600], fontWeight: FontWeight.normal)),
                                    ),

                                    ...getClockFields('monday', monModelList),

                                    SizedBox(height: 30),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(AppLocalizations.of(context).translate('tuesday'), style: TextStyle(fontSize: 16 ,color: Colors.grey[600], fontWeight: FontWeight.normal)),
                                    ),

                                    ...getClockFields('tuesday', tusModelList),

                                    SizedBox(height: 30),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(AppLocalizations.of(context).translate('wednesday'), style: TextStyle(fontSize: 16 ,color: Colors.grey[600], fontWeight: FontWeight.normal)),
                                    ),

                                    ...getClockFields('wednesday', wedModelList),

                                    SizedBox(height: 30),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(AppLocalizations.of(context).translate('thursday'), style: TextStyle(fontSize: 16 ,color: Colors.grey[600], fontWeight: FontWeight.normal)),
                                    ),

                                    ...getClockFields('thursday', thiModelList),

                                    SizedBox(height: 30),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(AppLocalizations.of(context).translate('friday'), style: TextStyle(fontSize: 16 ,color: Colors.grey[600], fontWeight: FontWeight.normal)),
                                    ),

                                    ...getClockFields('friday', friModelList),

                                    SizedBox(height: 30),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(AppLocalizations.of(context).translate('saturday'), style: TextStyle(fontSize: 16 ,color: Colors.grey[600], fontWeight: FontWeight.normal)),
                                    ),

                                    ...getClockFields('saturday', satModelList),
                                    SizedBox(height: 50),
                                  ],
                                ),
                              ),
                            )
                          ]
                      ),
                    )
                  ]
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> getClockFields(String day, List<ClockFieldModel> modelList){
    List<Widget> fieldList = [];
    for(int i=0; i<modelList.length; i++){
      fieldList.add(
          GestureDetector(
            key: UniqueKey(),
            child: ClockFields(
              globalScaffoldKey: _globalScaffoldKey,
              weekName: modelList[i].day,
              dayInTime: modelList[i].clockIn,
              dayOutTime: modelList[i].clockOut,
              type: i == 0 ? 1 : 2,
            ),
          )
      );
    }
    return fieldList;
  }
}