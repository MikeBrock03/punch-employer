import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../helpers/app_localizations.dart';
import '../../models/user_model.dart';
import '../../helpers/message.dart';

class ContactInfo extends StatefulWidget {

  UserModel userModel;
  bool isIntern;
  String from;
  ContactInfo({ this.userModel, this.isIntern, this.from });

  @override
  _ContactInfoState createState() => _ContactInfoState();
}

class _ContactInfoState extends State<ContactInfo> {

  final _globalScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalScaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('contact_info'), style: TextStyle(fontSize: 18)),
        centerTitle: true,
        brightness: Brightness.dark,
      ),
      backgroundColor: Colors.white,
      body: contactInfoBody(),
    );
  }

  Widget contactInfoBody(){

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Hero(
              tag: widget.from+widget.userModel.uID,
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
                  child: widget.userModel.imageURL != null && widget.userModel.imageURL != '' ? ClipRRect(
                    borderRadius: BorderRadius.circular(600),
                    child: CachedNetworkImage(
                      placeholder:(context, url) => Container(color: Colors.grey[200]),
                      imageUrl: widget.userModel.imageURL,
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                    ),
                  ) : ClipRRect(borderRadius: BorderRadius.circular(600), child: Container(padding: EdgeInsets.all(5) ,color: Colors.grey[200], child: Center(child: Text(widget.userModel.firstName, style: TextStyle(fontSize: 13, color: Colors.grey[500], decoration: TextDecoration.none), textAlign: TextAlign.center))))
              ),
            ),
          ),

          SizedBox(height: 20),
          Text('${widget.userModel.firstName} ${widget.userModel.lastName}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          SizedBox(height: 20),
          Divider(),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
                controller: ScrollController(),
                physics: BouncingScrollPhysics(),
                children: [

                  Column(
                      children: [

                        GestureDetector(
                          onTap: () async{

                            if(widget.userModel.mobile != null || widget.userModel.tel != null){
                              try{
                                final Uri _callLaunchUri = Uri(
                                  scheme: 'tel',
                                  path: widget.userModel.mobile ?? widget.userModel.tel,
                                );

                                if (await canLaunch(_callLaunchUri.toString())) {
                                  await launch(_callLaunchUri.toString());
                                } else {
                                  Message.show(_globalScaffoldKey, 'Could not launch the call app');
                                }
                              }catch(error){
                                print(error);
                              }
                            }

                          },
                          child: Row(
                            children: [
                              Icon(Icons.phone_iphone, size: 25, color: Colors.grey[600]),
                              SizedBox(width: 20),
                              widget.isIntern ? Text(widget.userModel.mobile != null && widget.userModel.mobile != '' ? widget.userModel.mobile : AppLocalizations.of(context).translate('not_set'), style: TextStyle(fontSize: 15, color: Colors.grey[600])) :
                              Text(widget.userModel.tel != null && widget.userModel.tel != '' ? widget.userModel.tel : AppLocalizations.of(context).translate('not_set'), style: TextStyle(fontSize: 15, color: Colors.grey[600]))
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () async{
                            try{
                              final Uri _emailLaunchUri = Uri(
                                  scheme: 'mailto',
                                  path: widget.userModel.email,
                              );

                              if (await canLaunch(_emailLaunchUri.toString())) {
                                await launch(_emailLaunchUri.toString());
                              } else {
                                Message.show(_globalScaffoldKey, 'Could not launch the mail app');
                              }
                            }catch(error){
                              print(error);
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.email_outlined, size: 25, color: Colors.grey[600]),
                              SizedBox(width: 20),
                              Text(widget.userModel.email != null && widget.userModel.email != '' ? widget.userModel.email : AppLocalizations.of(context).translate('not_set'), style: TextStyle(fontSize: 15, color: Colors.grey[600]))
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                      ]
                  )
                ]
            ),
          )
        ],
      ),
    );
  }
}
