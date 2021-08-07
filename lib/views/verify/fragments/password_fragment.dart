import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:provider/provider.dart';
import '../../../services/firebase_auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../database/storage.dart';
import '../../../helpers/uppercase_text_formatter.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_colors.dart';
import '../../../helpers/app_localizations.dart';
import '../../../helpers/app_text_field.dart';
import '../../../helpers/fading_edge_scrollview.dart';
import '../../../helpers/message.dart';
import '../../../helpers/progress_button.dart';
import '../../../view_models/user_view_model.dart';

class PasswordFragment extends StatefulWidget {

  final GlobalKey<ScaffoldState> globalScaffoldKey;
  final Function() onFinish;
  PasswordFragment({ this.globalScaffoldKey, this.onFinish });

  @override
  _PasswordFragmentState createState() => _PasswordFragmentState();
}


class _PasswordFragmentState extends State<PasswordFragment> with TickerProviderStateMixin{

  final _formKey = GlobalKey<FormState>();
  final Storage storage = new Storage();
  AnimationController _buttonAnimationController;
  ScrollController scrollController = ScrollController();

  String password, passwordRepeat;
  bool submitSt = true;

  @override
  void initState() {
    super.initState();

    _buttonAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(child: Scaffold(body: regCodeFragmentBody(), resizeToAvoidBottomInset: false));
  }

  Widget regCodeFragmentBody(){

    String name = '';
    String companyLogo = '';
    String companyName = '';

    if(Provider.of<UserViewModel>(context, listen: false).firstName != '' && Provider.of<UserViewModel>(context, listen: false).lastName != ''){
       name = capitalize(Provider.of<UserViewModel>(context, listen: false).firstName) + ' ' + capitalize(Provider.of<UserViewModel>(context, listen: false).lastName);
    }

    if(Provider.of<UserViewModel>(context, listen: false).logoURL != null && Provider.of<UserViewModel>(context, listen: false).logoURL != ''){
      companyLogo = Provider.of<UserViewModel>(context, listen: false).logoURL;
    }

    if(Provider.of<UserViewModel>(context, listen: false).companyName != null && Provider.of<UserViewModel>(context, listen: false).companyName != ''){
      companyName = Provider.of<UserViewModel>(context, listen: false).companyName;
    }

    return FadingEdgeScrollView.fromSingleChildScrollView(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        controller: scrollController,
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.fromLTRB(30, 40, 30, 30 ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text(name, style: TextStyle(fontSize: 30, color: Colors.grey[600]))),
              SizedBox(height: 30),
              Center(child: Text(AppLocalizations.of(context).translate('great_to_work_at'), style: TextStyle(fontSize: 18, color: Colors.grey[500]))),
              SizedBox(height: 40),
              Center(
                child: Container(
                    width: 120,
                    height: 120,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: companyLogo != null && companyLogo != '' ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        placeholder:(context, url) => Container(color: Colors.grey[200]),
                        imageUrl: companyLogo,
                        width: 95,
                        height: 95,
                        fit: BoxFit.fitHeight,
                      ),
                    ) : ClipRRect(borderRadius: BorderRadius.circular(10), child: Container(padding: EdgeInsets.all(5) ,color: Colors.grey[200], child: Center(child: Text(companyName, style: TextStyle(fontSize: 13, color: Colors.grey[500], decoration: TextDecoration.none), textAlign: TextAlign.center))))
                ),
              ),
              SizedBox(height: 40),
              Center(child: Text(AppLocalizations.of(context).translate('just_one_more_step'), style: TextStyle(fontSize: 18, color: Colors.grey[500]))),
              SizedBox(height: 40),
              Center(child: Text(AppLocalizations.of(context).translate('create_a_secure_pass'), style: TextStyle(fontSize: 18, color: Colors.grey[500]))),
              SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  width: MediaQuery.of(context).size.width,
                  child: Column(

                    children: <Widget>[

                      AppTextField(
                        isEnable: submitSt,
                        labelText: AppLocalizations.of(context).translate('password'),
                        textInputFormatter: [FilteringTextInputFormatter.deny(RegExp('[ ]')), UpperCaseTextFormatter()],
                        inputAction: TextInputAction.next,
                        isPassword: true,
                        onValidate: (value){

                          if (value.isEmpty) {
                            return AppLocalizations.of(context).translate('password_empty_validate');
                          }

                          if (value.length < 3) {
                            return AppLocalizations.of(context).translate('password_len_validate');
                          }
                          return null;
                        },

                        onChanged: (value){
                          password = value;
                        },

                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),

                      AppTextField(
                        isEnable: submitSt,
                        labelText: AppLocalizations.of(context).translate('password_repeat'),
                        textInputFormatter: [FilteringTextInputFormatter.deny(RegExp('[ ]')), UpperCaseTextFormatter()],
                        inputAction: TextInputAction.done,
                        isPassword: true,
                        onValidate: (value){

                          if (value.isEmpty) {
                            return AppLocalizations.of(context).translate('password_repeat_empty_validate');
                          }

                          if (value.length < 3) {
                            return AppLocalizations.of(context).translate('password_repeat_len_validate');
                          }

                          if(value != password){
                            return AppLocalizations.of(context).translate('password_repeat_validate');
                          }

                          return null;
                        },

                        onFieldSubmitted: (value){
                          passwordRepeat = value;
                          submitForm();
                        },

                        onChanged: (value){
                          passwordRepeat = value;
                        },
                      ),

                      SizedBox(height: 18),

                      SizedBox(
                        width: MediaQuery.of(context).size.width - 65,
                        height: 50,
                        child: ProgressButton(
                          animationController: _buttonAnimationController,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: AppColors.primaryColor,
                          progressIndicatorSize: 15,
                          strokeWidth: 2,
                          child: Text(AppLocalizations.of(context).translate('set_password'), style:  TextStyle(fontSize: 14.0, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                          onPressed: (AnimationController controller) {
                            if(submitSt){
                              submitForm();
                            }
                          },
                        ),
                      ),

                      SizedBox(height: 60),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitForm() async{
    FocusScope.of(context).unfocus();

    if (_formKey.currentState.validate()) {

      _buttonAnimationController.forward();

      setState(() {
        submitSt = false;
      });

      String uID = '';

      try{
        await Future.delayed(Duration(milliseconds: 2500));
        dynamic passwordResult = await Provider.of<FirebaseAuthService>(context, listen: false).changePassword(email: Provider.of<UserViewModel>(context, listen: false).email, password: password);
        if(passwordResult is bool && passwordResult){
          uID = Provider.of<FirebaseAuthService>(context, listen: false).uID;
          dynamic result = await Provider.of<FirestoreService>(context, listen: false).updateVerified(uID: uID);
          if(result is bool && result){
            storage.saveBool('verified', true);
            widget.onFinish();
          }else{
            await performLogout();
            _buttonAnimationController.reverse();
            Message.show(widget.globalScaffoldKey, AppLocalizations.of(context).translate('set_password_fail'));
          }
        }else{
          await performLogout();
          _buttonAnimationController.reverse();
          Message.show(widget.globalScaffoldKey, AppLocalizations.of(context).translate('set_password_fail'));
        }
      }catch(error){
        if(!AppConfig.isPublished){
          print('$error');
        }

        setState(() {
          submitSt = true;
        });

        _buttonAnimationController.reverse();
        Message.show(widget.globalScaffoldKey, AppLocalizations.of(context).translate('set_password_fail'));
      }
    }
  }

  Future<void> performLogout() async{
    try{
      await Provider.of<FirebaseAuthService>(context, listen: false).signOut();
      //await storage.clearAll();
      //Provider.of<UserViewModel>(context, listen: false).setUserModel(null);
    }catch(error) {
      if (!AppConfig.isPublished) {
        print('Error: $error');
      }
    }
  }

  String capitalize(String value) {
    return "${value[0].toUpperCase()}${value.substring(1)}";
  }
}