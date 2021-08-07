
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:provider/provider.dart';
import 'package:punch_app/view_models/user_view_model.dart';
import 'components/logo_picker.dart';
import '../../view_models/companies_view_model.dart';
import '../../services/firebase_storage.dart';
import '../../helpers/loading_dialog.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../helpers/fading_edge_scrollview.dart';
import '../../helpers/app_text_field.dart';
import '../../config/app_config.dart';
import '../../helpers/app_localizations.dart';
import '../../helpers/message.dart';

class CompanyForm extends StatefulWidget {

  final UserModel userModel;
  final Function() onFinish;

  CompanyForm({ this.userModel, this.onFinish });

  @override
  _CompanyFormState createState() => _CompanyFormState();
}

class _CompanyFormState extends State<CompanyForm> {

  final _formKey = GlobalKey<FormState>();
  final _globalScaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();

  String companyName, employerFirstName, employerLastName, email, imageUrl, employerEducation, employerCertification, tel;
  bool submitSt = true;

  @override
  void initState() {
    super.initState();

    if(widget.userModel != null){
      companyName = widget.userModel.companyName;
      employerFirstName = widget.userModel.firstName;
      employerLastName = widget.userModel.lastName;
      imageUrl = widget.userModel.logoURL != null && widget.userModel.logoURL != '' ? widget.userModel.logoURL : null;
      employerEducation = widget.userModel.education;
      employerCertification = widget.userModel.certification;
      tel = widget.userModel.mobile != null && widget.userModel.mobile != '' ? widget.userModel.mobile : widget.userModel.tel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
      child: Scaffold(
        key: _globalScaffoldKey,
        appBar: AppBar(
          title: Text( AppLocalizations.of(context).translate('edit') + ' ' + AppLocalizations.of(context).translate('profile'), style: TextStyle(fontSize: 18)),
          centerTitle: true,
          brightness: Brightness.dark,
          actions: [
            TextButton(
              onPressed: () {
                if(submitSt){
                  updateProfile();
                }
              },
              style: TextButton.styleFrom(
                shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                primary: Colors.white,
              ),
              child: Text(AppLocalizations.of(context).translate('save'), style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: companyFormBody(),
      ),
    );
  }

  Widget companyFormBody(){
    return FadingEdgeScrollView.fromSingleChildScrollView(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        controller: scrollController,
        child: FadeInUp(
          from: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 40, 12, 12),
            child: Column(
              children: [

                Center(child: SizedBox(width: 180, height: 180,child: LogoPicker(imageURL: imageUrl, enabled: submitSt, onImageCaptured: (path){
                  setState(() {
                    imageUrl = path;
                  });
                }))),

                Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    width: MediaQuery.of(context).size.width,
                    child: Column(

                      children: <Widget>[

                        SizedBox(height: 25),

                        AppTextField(
                          isEnable: false,
                          labelText: AppLocalizations.of(context).translate('company_name'),
                          inputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          value: companyName,
                          onValidate: (value){
                            if (value.isEmpty) {
                              return AppLocalizations.of(context).translate('company_name_empty_validate');
                            }

                            if (value.length < 3) {
                              return AppLocalizations.of(context).translate('company_name_len_validate');
                            }

                            return null;
                          },

                          onChanged: (value){
                            companyName = value;
                          },
                        ),

                        AppTextField(
                          isEnable: false,
                          labelText: AppLocalizations.of(context).translate('employer_first_name'),
                          inputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          value: employerFirstName,
                          onValidate: (value){
                            if (value.isEmpty) {
                              return AppLocalizations.of(context).translate('employer_first_name_empty_validate');
                            }

                            if (value.length < 3) {
                              return AppLocalizations.of(context).translate('employer_first_name_len_validate');
                            }

                            return null;
                          },

                          onChanged: (value){
                            employerFirstName = value;
                          },
                        ),

                        AppTextField(
                          isEnable: false,
                          labelText: AppLocalizations.of(context).translate('employer_last_name'),
                          inputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          value: employerLastName,
                          onValidate: (value){
                            if (value.isEmpty) {
                              return AppLocalizations.of(context).translate('employer_last_name_empty_validate');
                            }

                            if (value.length < 3) {
                              return AppLocalizations.of(context).translate('employer_last_name_len_validate');
                            }

                            return null;
                          },

                          onChanged: (value){
                            employerLastName = value;
                          },
                        ),

                        AppTextField(
                          isEnable: submitSt,
                          labelText: AppLocalizations.of(context).translate('employer_education'),
                          inputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          value: employerEducation,
                          onChanged: (value){
                            employerEducation = value;
                          },
                        ),

                        AppTextField(
                          isEnable: submitSt,
                          labelText: AppLocalizations.of(context).translate('employer_certification'),
                          inputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          value: employerCertification,
                          onChanged: (value){
                            employerCertification = value;
                          },
                        ),

                        AppTextField(
                          isEnable: submitSt,
                          labelText: 'Employer phone',
                          inputAction: TextInputAction.done,
                          textInputType: TextInputType.phone,
                          value: tel,
                          onChanged: (value){
                            tel = value;
                          },
                        ),

                        SizedBox(height: 20)

                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateProfile() async{

    FocusScope.of(context).unfocus();

    if (_formKey.currentState.validate()) {
      Future.delayed(Duration(milliseconds: 250), () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return LoadingDialog();
          },
        );
      });

      setState(() {
        submitSt = false;
      });

      try{

        UserModel model = widget.userModel;

        if(imageUrl != null && !imageUrl.startsWith('http')){
          dynamic uploadResult =  await Provider.of<FirebaseStorage>(context, listen: false).uploadLogo(imagePath: imageUrl, uID: model.uID);
          model.logoURL = uploadResult != null && Uri.tryParse(uploadResult).isAbsolute ? uploadResult : null;
        }else{
          model.logoURL = imageUrl;
        }
        model.companyName = companyName.trim();
        model.firstName = employerFirstName.trim();
        model.lastName = employerLastName.trim();
        model.education = employerEducation != null ? employerEducation.trim() : null;
        model.certification = employerCertification != null ? employerCertification.trim() : null;
        model.tel = tel != null ? tel.trim() : null;

        dynamic result = await Provider.of<FirestoreService>(context, listen: false).updateProfile(userModel: model);

        if(result is bool && result){

          Provider.of<UserViewModel>(context, listen: false).setUserModel(model);

          await Future.delayed(Duration(milliseconds: 1500), (){Navigator.pop(context);});
          await Future.delayed(Duration(milliseconds: 800), (){Message.show(_globalScaffoldKey, AppLocalizations.of(context).translate('company_update_success'));});
          await Future.delayed(Duration(milliseconds: 1500), (){Navigator.pop(context);});
          //widget.onFinish();
        }else{
          setState(() {
            submitSt = true;
          });
          //widget.onFinish();
          await Future.delayed(Duration(milliseconds: 1500), (){Navigator.pop(context);});
          await Future.delayed(Duration(milliseconds: 800), (){Message.show(_globalScaffoldKey, AppLocalizations.of(context).translate('company_update_fail'));});
        }

      }catch(error){
        if(!AppConfig.isPublished){
          print('$error');
        }

        setState(() {
          submitSt = true;
        });

        await Future.delayed(Duration(milliseconds: 1500), (){Navigator.pop(context);});
        await Future.delayed(Duration(milliseconds: 800), (){Message.show(_globalScaffoldKey, AppLocalizations.of(context).translate('company_update_fail'));});
      }
    }
  }
}