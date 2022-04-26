import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:udhar_kharcha/controllers/dataStore.dart';
import 'package:udhar_kharcha/controllers/requests.dart';
import 'package:udhar_kharcha/controllers/utilities.dart';
import 'package:udhar_kharcha/screens/tag_widget.dart';
import 'dart:math';


class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {

  String _username = FirebaseAuth.instance.currentUser?.displayName ?? '';
  String _phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';


  List<AnalyticsData> weeklyData = [];
  List<AnalyticsData> monthlyData = [];
  List<AnalyticsData> data = [];

  int? selected;

  List total_expense = [0,0];
  double displayExpense = 0;
  String displayTitle = '';
  List<bool> isSelected = [true,false];
  int selectedType = 0;
  List<double> maximum_expense = [50,50];

  bool loading = true;


  getAnalyticsData() async{
    data = [];
    // get weekly
    GetAnalytics objM = GetAnalytics(_phoneNumber, 'weekly');
    try {
      await objM.sendQuery();
      if (objM.success) {
        total_expense[0] = objM.data['total_expense'];
        var _events = objM.data['weekly_events_and_expense'];
        for(var ele in _events) {
          String _label = parseDate(ele[0][0],'dd MMM') +'-'+ parseDate(ele[0][1],'dd MMM');
          maximum_expense[0] = max(maximum_expense[0],ele[2].toDouble());
          weeklyData.add(AnalyticsData(_label,ele[2].toDouble(),ele[1]));
        }
      }
    }
    catch (e) {
      if (kDebugMode) {
        print('failed weekly');
      }
    }
    // get monthly
    GetAnalytics objW = GetAnalytics(_phoneNumber, 'monthly');
    try {
      await objW.sendQuery();
      if (objW.success) {
        total_expense[1] = objW.data['total_expense'];
        var _events = objW.data['monthly_events_and_expense'];
        for(var ele in _events) {
          String _label = parseDate(ele[0][0],'MMM');
          maximum_expense[1] = max(maximum_expense[1],ele[2].toDouble());
          monthlyData.add(AnalyticsData(_label,ele[2].toDouble(),ele[1]));
        }
      }
    }
    catch (e) {
      if (kDebugMode) {
        print('failed monthly');
      }
    }

    loading = false;
    if(!objM.success || !objW.success){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not fetch data'),duration: Duration(seconds: 1),)
      );
    }
    else{
      setState(() {
        data = weeklyData;
        displayExpense = selected==null ? total_expense[0] : data[selected!].amount;
        selectedType = 0 ;
        displayTitle = 'Last 4 weeks';
      });
    }
  }



  @override
  void initState() {
    super.initState();
    getAnalyticsData();
    if (kDebugMode) {
      print('analytics init');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f6fb),
      body: loading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10,0,10,0),
          child: Column(children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children : [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          displayTitle,
                          overflow: TextOverflow.fade,
                          softWrap: true,
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.grey[700]
                          ),
                        ),
                        ToggleButtons(
                          borderColor: Color(0xfff7f6fb),
                          fillColor: Colors.purple,
                          borderWidth: 0,
                          color : Colors.grey,
                          selectedColor: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          constraints: BoxConstraints(
                            minHeight: 35,
                            maxHeight: 40,
                            minWidth: 70,
                            maxWidth: 80,
                          ),
                          children: <Widget>[
                            Text(
                              'Weekly',
                            ),
                            Text(
                              'Monthly',
                            ),
                          ],
                          onPressed: (int index) {
                            if(!isSelected[index]){
                              setState(() {
                                if(index==0) {
                                  isSelected[0] = true;
                                  isSelected[1] = false;

                                  selectedType = 0;
                                  data = weeklyData;
                                  displayTitle = 'Last 4 weeks';
                                }
                                else{
                                  isSelected[0] = false;
                                  isSelected[1] = true;

                                  selectedType = 1;
                                  data = monthlyData;
                                  displayTitle = 'Last 4 months';
                                }

                                if(selected!=null) {
                                  displayExpense = data[selected!].amount;
                                  displayTitle = 'In ${data[selected!].label}';
                                }
                                else{
                                  displayExpense = total_expense[index];
                                }
                              });
                            }
                          },
                          isSelected: isSelected,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\u{20B9} ${displayExpense}',
                    overflow: TextOverflow.fade,
                    softWrap: true,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                    ),
                  ),

                  SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    primaryXAxis: CategoryAxis(
                      majorGridLines: MajorGridLines(width: 0),
                      axisLine: AxisLine(width: 0),
                      maximumLabelWidth: 55,
                      labelStyle: selectedType == 0 ? TextStyle(
                        fontSize: 10
                      ): null
                    ),
                    primaryYAxis: NumericAxis(
                        minimum: 0, maximum: maximum_expense[selectedType]+100, interval: 100,
                        majorGridLines: MajorGridLines(width: 0),
                        axisLine: AxisLine(width: 0)
                    ),
                    selectionType: SelectionType.cluster,
                    onSelectionChanged: (val) {
                      if (kDebugMode) {
                        print(val.pointIndex);
                      }
                      setState(() {
                        if(selected == val.pointIndex){
                          selected = null;
                        }
                        else {
                          selected = val.pointIndex;
                        }
                        if(selected!=null) {
                          displayExpense = data[selected!].amount;
                          displayTitle = 'In ${data[selected!].label}';
                        }
                        else {
                          displayExpense = total_expense[selectedType];
                          displayTitle = selectedType == 1 ? 'Last 4 months' : 'Last 4 weeks';
                        }
                      });
                    },
                    plotAreaBackgroundColor : Color(0xfff7f6fb),
                    series: <ChartSeries<AnalyticsData, String>>[
                      ColumnSeries<AnalyticsData, String>(
                        dataSource: data,
                        xValueMapper: (AnalyticsData data, _) => data.label,
                        yValueMapper: (AnalyticsData data, _) => data.amount,
                        name: 'Expense',
                        selectionBehavior: SelectionBehavior(
                          enable: true,
                          toggleSelection: true,
                          unselectedOpacity: 0.2,
                          unselectedColor: Colors.grey,
                          selectedColor: Colors.pinkAccent
                        ),
                        borderRadius: BorderRadius.circular(5),
                        gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.purple, Colors.pinkAccent]
                        ),
                      )
                    ]
                  ),
                ]
              ),
            ),
            SizedBox(height: 15,),

            selected==null ? Container() :
            Text(
                'Breakdown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            ),

            for(int i=0,n=(selected!=null ? data[selected!].breakdownEvents.length:0);(selected!=null)&&i<data[selected!].breakdownEvents.length;i++)
              transactionCard(data[selected!].breakdownEvents[n-i-1])

          ]),
        ),
      ),
    );
  }


  Widget transactionCard(element) {
    return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20,10,15,0),
              child: Row(
                children: [
                  TagWidget(emoji: '📅', label: parseDate(element[1], 'dd MMM') ,width: 70,),
                  SizedBox(width: 6,),
                  TagWidget(emoji: '✋', label: 'Personal' , width: 70,),
                  Expanded(
                    child: Text(
                      'You spent',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
                onTap: null,
                title: Text(
                  element[0],
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                trailing: Text(
                  '\u{20B9} ${element[2]}',
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900
                  ),
                )
            ),
          ],
        )
    );
  }

}

