import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:udhar_kharcha/controllers/requests.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:udhar_kharcha/screens/tag_widget.dart';


class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {

  List<_SalesData> data1 = [
    _SalesData('Jan', 35),
    _SalesData('Feb', 28),
    _SalesData('Mar', 34),
    _SalesData('Apr', 32),
    _SalesData('May', 40),
  ];

  List<_SalesData> data2 = [
    _SalesData('Jan', 10),
    _SalesData('Feb', 20),
    _SalesData('Mar', 30),
    _SalesData('Apr', 40),
    _SalesData('May', 50),

  ];

  List<_SalesData> data = [];
  int _initLabel = 0;

  int? selected;

  @override
  void initState() {
    super.initState();
    data = data1;
    print('analytics init');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f6fb),
      body: SingleChildScrollView(
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
                          'Between 1 Apr - 30 Apr',
                          overflow: TextOverflow.fade,
                          softWrap: true,
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.grey[700]
                          ),
                        ),
                        ToggleSwitch(
                          inactiveFgColor : Colors.grey,
                          inactiveBgColor: Color(0xfff7f6fb),
                          minHeight: 30.0,
                          cornerRadius: 20.0,
                          initialLabelIndex: _initLabel,
                          totalSwitches: 2,
                          labels: ['Weekly', 'Monthly'],
                          onToggle: (index) {
                            print('switched to: $index');
                            setState(() {
                              _initLabel = index!=null ? index : 0;
                              if(index==0)
                                data = data1;
                              else
                                data = data2;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\u{20B9} 500',
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
                    ),
                    primaryYAxis: NumericAxis(
                        minimum: 0, maximum: 50, interval: 10,
                        majorGridLines: MajorGridLines(width: 0),
                        axisLine: AxisLine(width: 0)
                    ),
                    //tooltipBehavior: TooltipBehavior(enable: true),
                    selectionType: SelectionType.cluster,
                    onSelectionChanged: (val) {
                      print(val.pointIndex);
                      setState(() {
                        selected == val.pointIndex
                            ? selected = null :
                        selected = val.pointIndex;
                      });
                    },
                    plotAreaBackgroundColor : Color(0xfff7f6fb),
                    series: <ChartSeries<_SalesData, String>>[
                      ColumnSeries<_SalesData, String>(
                        dataSource: data,
                        xValueMapper: (_SalesData data, _) => data.year,
                        yValueMapper: (_SalesData data, _) => data.sales,
                        name: 'Expense',
                        selectionBehavior: SelectionBehavior(
                          enable: true,
                          toggleSelection: true,
                          unselectedOpacity: 0.2,
                          unselectedColor: Colors.grey,
                          selectedColor: Colors.pinkAccent
                        ),
                        borderRadius: BorderRadius.circular(5),
                        gradient: LinearGradient(
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

            for(int i = 0;i<data.length;i++)
              selected==null ? Container() :
              transactionCard(data[selected!])

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
                  TagWidget(emoji: '📅', label: '' ,width: 50,),
                  SizedBox(width: 6,),
                  TagWidget(emoji: '✋', label: 'Personal' , width: 60,),
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
                  'element.name',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                trailing: Text(
                  '\u{20B9} ${element.sales}',
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

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
