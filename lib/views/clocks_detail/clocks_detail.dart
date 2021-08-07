import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch_app/config/app_config.dart';
import 'package:punch_app/models/clock_field_model.dart';
import '../../helpers/fading_edge_scrollview.dart';
import '../../helpers/message.dart';
import '../../services/firestore_service.dart';
import '../../views/clocks_detail/components/date_picker_field.dart';
import '../../views/clocks_detail/components/mini_map.dart';
import '../../helpers/app_localizations.dart';
import '../../models/user_model.dart';

class ClocksDetail extends StatefulWidget {

  UserModel intern;
  String from;
  ClocksDetail({ this.intern, this.from });

  @override
  _ClocksDetailState createState() => _ClocksDetailState();
}

class _ClocksDetailState extends State<ClocksDetail> {

  final _globalScaffoldKey = GlobalKey<ScaffoldState>();
  final DateTime date = DateTime.now();
  DateTime selectedDate;
  String today;
  List<ClockFieldModel> clockModelList = [];
  List<ClockFieldModel> scheduleList = [];
  int _current = 0;
  double sliderHeight = 288;

  @override
  void initState() {
    super.initState();
    getData(date);
  }

  void getData(DateTime dt) async{
    try{
      clockModelList.clear();
      scheduleList.clear();

      String day = DateFormat('EEEE').format(dt);

      String pickerDate = '${dt.year}-${dt.month}-${dt.day}';
      String todayDate = '${date.year}-${date.month}-${date.day}';

      Iterable schedules = widget.intern.schedules[day.substring(0,3).toLowerCase()];
      schedules.forEach((element) {
        scheduleList.add(
            ClockFieldModel(day: day, clockIn: element['clockIn'] != null ? DateTime.parse(element['clockIn'].toDate().toString()) : null, clockOut: element['clockOut'] != null ? DateTime.parse(element['clockOut'].toDate().toString()) : null)
        );
      });

      setState(() {selectedDate = dt; today = pickerDate == todayDate ? 'Today' : day; _current = 0;});

      dynamic result = await Provider.of<FirestoreService>(context, listen: false).getClockHistory(
          uID: widget.intern.uID,
          $date: pickerDate
      );

      if(result != null){

        Iterable clocks = result['clocks'];
        clocks.forEach((element) {
          clockModelList.add(
              ClockFieldModel(
                  day: pickerDate == todayDate ? 'Today' : day,
                  clockIn: element['clock_in'] != null ? DateTime.parse(element['clock_in'].toDate().toString()) : null,
                  clockOut: element['clock_out'] != null ? DateTime.parse(element['clock_out'].toDate().toString()) : null,
                  location: element['location'] ?? null
              )
          );
        });

        setState(() {sliderHeight = clockModelList[_current].location != null ? 556 : 288;});

      }else{
        clockModelList.add(
            ClockFieldModel(
                day: pickerDate == todayDate ? 'Today' : day,
                clockIn: null,
                clockOut: null,
                location: null
            )
        );
        setState(() {sliderHeight = clockModelList[_current].location != null ? 556 : 288;});
      }
    }catch(error){
      if(!AppConfig.isPublished){
        print('Error: $error');
      }
      Message.show(_globalScaffoldKey, AppLocalizations.of(context).translate('receive_error'));
      setState(() {sliderHeight = clockModelList[_current].location != null ? 556 : 288;});
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _globalScaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('clock_in_out'), style: TextStyle(fontSize: 18)),
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
                      fit: BoxFit.fitHeight,
                    ),
                  ) : ClipRRect(borderRadius: BorderRadius.circular(600), child: Container(padding: EdgeInsets.all(5) ,color: Colors.grey[200], child: Center(child: Text(widget.intern.firstName, style: TextStyle(fontSize: 13, color: Colors.grey[500], decoration: TextDecoration.none), textAlign: TextAlign.center))))
              ),
            ),
          ),

          SizedBox(height: 20),
          Text('${widget.intern.firstName} ${widget.intern.lastName}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          SizedBox(height: 20),
          Divider(),
          SizedBox(height: 5),
          Expanded(
            child: FadingEdgeScrollView.fromSingleChildScrollView(
              child: SingleChildScrollView(
                controller: ScrollController(),
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [

                    SizedBox(height: 20),
                    Text('$today\'s ${AppLocalizations.of(context).translate('work_schedule')}', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                    SizedBox(height: 25),

                    scheduleList.length > 0 ? Column(
                      children: scheduleList.map((e) => Column(
                        children: [
                          //Text('${DateFormat.jm().format(e.clockIn)} to ${DateFormat.jm().format(e.clockOut)}', style: TextStyle(fontSize: 16, color: Colors.grey[500]), textAlign: TextAlign.center),
                          Text(e.clockIn != null && e.clockOut != null ? '${DateFormat.jm().format(e.clockIn)} to ${DateFormat.jm().format(e.clockOut)}' : 'No schedule for today', style: TextStyle(fontSize: 16, color: Colors.grey[500]), textAlign: TextAlign.center),
                          SizedBox(height: 10)
                        ],
                      )).toList(),
                    ) : Text('No schedule for today', style: TextStyle(fontSize: 16, color: Colors.grey[500])),

                    CarouselSlider(
                      options: CarouselOptions(
                          height: sliderHeight,
                          autoPlay: false,
                          enableInfiniteScroll: false,
                          enlargeCenterPage: false,
                          viewportFraction: 1.0,
                          scrollPhysics: BouncingScrollPhysics(),
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          }
                      ),
                      items: clockModelList.map((clocks) {

                        return Builder(
                          builder: (BuildContext context) {
                            return FadeIn(
                              child: Column(
                                children: [
                                  SizedBox(height: 50),

                                  Text('${widget.intern.firstName} ${AppLocalizations.of(context).translate('clocked_in_at').toLowerCase()}', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                                  SizedBox(height: 25),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      clocks.clockIn != null ? Row(
                                        children: [
                                          Icon(Icons.access_time_outlined, color: Colors.green[500], size: 20),
                                          SizedBox(width: 10),
                                        ],
                                      ) : Container(),
                                      Text(clocks.clockIn != null ? DateFormat.yMMMd().add_jm().format(clocks.clockIn) : '-', style: TextStyle(fontSize: 16, color: Colors.green[500])),
                                    ],
                                  ),
                                  SizedBox(height: 50),

                                  Text('${widget.intern.firstName} ${AppLocalizations.of(context).translate('clocked_out_at').toLowerCase()}', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                                  SizedBox(height: 25),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      clocks.clockOut != null ? Row(
                                        children: [
                                          Icon(Icons.access_time_outlined, color: Colors.green[500], size: 20),
                                          SizedBox(width: 10),
                                        ],
                                      ) : Container(),
                                      Text(clocks.clockOut != null ? DateFormat.yMMMd().add_jm().format(clocks.clockOut) : '-', style: TextStyle(fontSize: 16, color: Colors.green[500])),
                                    ],
                                  ),
                                  SizedBox(height: 50),

                                  clocks.location != null ? Column(
                                    children: [

                                      Text('${widget.intern.firstName} ${AppLocalizations.of(context).translate('is_at').toLowerCase()}', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                                      SizedBox(height: 25),

                                      SizedBox(
                                          width: MediaQuery.of(context).size.width - 100,
                                          height: 200,
                                          child: ClipRRect(borderRadius: BorderRadius.circular(15), child: MiniMap(
                                              location: clocks.location
                                          ))
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ) : Container(),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),

                    clockModelList.length > 1 ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: clockModelList.map((url) {
                              int index = clockModelList.indexOf(url);
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _current == index
                                      ? Color.fromRGBO(0, 0, 0, 0.3)
                                      : Color.fromRGBO(0, 0, 0, 0.1),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ) : SizedBox(height: 8),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: DatePickerField(
                        enabled: true,
                        onDatePicked: (dt) async{
                          getData(dt);
                        },
                        value: selectedDate,
                        hint: 'Date',
                        helpText: 'Select date',
                      ),
                    ),

                    SizedBox(height: 40),

                    /*Text('${widget.intern.firstName} ${AppLocalizations.of(context).translate('clocked_in_at').toLowerCase()}', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        clockedIn != null ? Row(
                          children: [
                            Icon(Icons.access_time_outlined, color: Colors.green[500], size: 20),
                            SizedBox(width: 10),
                          ],
                        ) : Container(),
                        Text(clockedIn != null ? clockedIn : '-', style: TextStyle(fontSize: 16, color: Colors.green[500])),
                      ],
                    ),
                    SizedBox(height: 50),

                    Text('${widget.intern.firstName} ${AppLocalizations.of(context).translate('clocked_out_at').toLowerCase()}', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        clockedOut != null ? Row(
                          children: [
                            Icon(Icons.access_time_outlined, color: Colors.green[500], size: 20),
                            SizedBox(width: 10),
                          ],
                        ) : Container(),
                        Text(clockedOut != null ? clockedOut : '-', style: TextStyle(fontSize: 16, color: Colors.green[500])),
                      ],
                    ),
                    SizedBox(height: 50),

                    location != null ? Column(
                      children: [

                        Text('${widget.intern.firstName} ${AppLocalizations.of(context).translate('is_at').toLowerCase()}', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                        SizedBox(height: 25),

                        SizedBox(
                            width: MediaQuery.of(context).size.width - 100,
                            height: 200,
                            child: ClipRRect(borderRadius: BorderRadius.circular(15), child: MiniMap(
                                location: location
                            ))
                        ),
                        SizedBox(height: 20),
                      ],
                    ) : Container(),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: DatePickerField(
                        enabled: true,
                        onDatePicked: (dt) async{

                          String shortDay = DateFormat('EEEE').format(dt).substring(0,3).toLowerCase();

                          setState(() {
                            selectedDate = dt;
                          });
                          String pickerDate = '${dt.year}-${dt.month}-${dt.day}';
                          String todayDate = '${date.year}-${date.month}-${date.day}';
                          dynamic result = await Provider.of<FirestoreService>(context, listen: false).getClockHistory(
                            uID: widget.intern.uID,
                            $date: pickerDate
                          );

                          if(result == null){

                            if(pickerDate == todayDate){
                              getData();
                            }else{
                              setState(() {
                                internScheduleClockIn = widget.intern.schedules[shortDay]['clock_in'] ?? null;
                                internScheduleClockOut = widget.intern.schedules[shortDay]['clock_out'] ?? null;
                                internClockClockIn = null;
                                internClockClockOut = null;
                                location = null;
                              });
                            }
                          }else if(result is Map<String, dynamic>){
                            setState(() {
                              internScheduleClockIn = widget.intern.schedules[shortDay]['clock_in'] ?? null;
                              internScheduleClockOut = widget.intern.schedules[shortDay]['clock_out'] ?? null;
                              if('${dt.year}-${dt.month}-${dt.day}' == '${result['clock_in'].toDate().year}-${result['clock_in'].toDate().month}-${result['clock_in'].toDate().day}') {
                                internClockClockIn = result['clock_in'] ?? null;
                              }else{
                                internClockClockIn = null;
                              }

                              if('${dt.year}-${dt.month}-${dt.day}' == '${result['clock_out'].toDate().year}-${result['clock_out'].toDate().month}-${result['clock_out'].toDate().day}'){
                                internClockClockOut = result['clock_out'] ?? null;
                              }else{
                                internClockClockOut = null;
                              }
                              location = result['location'] ?? null;
                            });
                          }else{
                            Message.show(_globalScaffoldKey, AppLocalizations.of(context).translate('receive_error'));
                          }
                        },
                        value: selectedDate,
                        hint: 'Date',
                        helpText: 'Select date',
                      ),
                    ),

                    SizedBox(height: 40),*/
                  ]
                )
              ),
            ),
          )
        ],
      ),
    );
  }
}