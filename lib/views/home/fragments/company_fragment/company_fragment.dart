import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../helpers/app_navigator.dart';
import '../../../../views/company_detail/company_detail.dart';
import '../../../../helpers/fading_edge_scrollview.dart';
import '../../../../view_models/companies_view_model.dart';
import '../../../../helpers/app_localizations.dart';
import '../../../../constants/app_colors.dart';

class CompanyFragment extends StatefulWidget {

  final GlobalKey<ScaffoldState> globalScaffoldKey;
  CompanyFragment({ this.globalScaffoldKey });

  @override
  _CompanyFragmentState createState() => _CompanyFragmentState();
}

class _CompanyFragmentState extends State<CompanyFragment> with AutomaticKeepAliveClientMixin<CompanyFragment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: companyFragmentBody(),
    );
  }

  Widget companyFragmentBody(){

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          SizedBox(height: 20),
          Center(child: Text(AppLocalizations.of(context).translate('intern_companies'), style: TextStyle(fontSize: 20, color: Colors.grey[600]))),
          SizedBox(height: 25),
          Expanded(child: companyList())
        ],
      ),
    );
  }

  Widget companyList(){
    return Consumer<CompaniesViewModel>(
      builder: (BuildContext context, CompaniesViewModel value, Widget child) {
        return Provider.of<CompaniesViewModel>(context, listen: false).companyList.length > 0 ? FadeIn(
          child: Container(
            //padding: EdgeInsets.fromLTRB(38, 50, 38, 0),
            child: FadingEdgeScrollView.fromGridView(
              child: GridView.builder(
                controller: ScrollController(),
                padding: EdgeInsets.all(12),
                physics: BouncingScrollPhysics(),
                itemCount: Provider.of<CompaniesViewModel>(context, listen: false).companyList.length,
                scrollDirection: Axis.vertical,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20),
                itemBuilder: (BuildContext context, int index) {

                  var company = Provider.of<CompaniesViewModel>(context, listen: false).companyList[index];

                  return Hero(
                    tag: company.uID,
                    child: GestureDetector(
                      onTap: (){
                        AppNavigator.push(context: context, page: CompanyDetail(company: company));
                      },
                      child: Container(
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
                        child: company.logoURL != null && company.logoURL != '' ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            placeholder:(context, url) => Container(color: Colors.grey[200]),
                            imageUrl: company.logoURL,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.fitHeight,
                          ),
                        ) : ClipRRect(borderRadius: BorderRadius.circular(10), child: Container(color: Colors.grey[200], child: Center(child: Text(company.companyName, style: TextStyle(fontSize: 13, color: Colors.grey[500], decoration: TextDecoration.none)))))
                      ),
                    ),
                  );
                },
              ),
            )
          ),
        ) : notFoundView();
      },
    );
  }

  Widget notFoundView(){
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FaIcon(FontAwesomeIcons.building, size: 60, color: Colors.grey[300]),
            SizedBox(height: 15),
            Text(AppLocalizations.of(context).translate('there_is_nothing_to_show'), style: TextStyle(fontSize: 14, color: Colors.grey[400])),
            SizedBox(height: 70)
          ],
        )
    );
  }

  @override
  bool get wantKeepAlive => true;
}
