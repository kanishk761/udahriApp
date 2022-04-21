import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:udhar_kharcha/controllers/requests.dart';
import 'package:toggle_switch/toggle_switch.dart';


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

  @override
  void initState() {
    data = data1;
    print('analytics init');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f6fb),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
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
                        tooltipBehavior: TooltipBehavior(enable: true),
                        plotAreaBackgroundColor : Color(0xfff7f6fb),
                        series: <ChartSeries<_SalesData, String>>[
                          ColumnSeries<_SalesData, String>(
                            dataSource: data,
                            xValueMapper: (_SalesData data, _) => data.year,
                            yValueMapper: (_SalesData data, _) => data.sales,
                            name: 'Expense',
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.purple, Colors.pinkAccent]
                            ),
                          )
                        ]
                    )
                  ]
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
