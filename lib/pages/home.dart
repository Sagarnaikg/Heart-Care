import 'dart:async';

import 'package:flutter/material.dart';
import 'package:heart_beat_monitor/constants/colors.dart';
import 'package:heart_beat_monitor/data/variables.dart';
import 'package:heart_beat_monitor/models/heart_rate.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // variables
  var rng = new Random();
  ScrollController controller = new ScrollController();
  List<HeartRate> chartData = [];
  late Timer _timer;
  double _start = 0.0;
  int count = 0;
  /* late ChartSeriesController? _chartSeriesController; */

  void startTimer() {
    const oneTic = const Duration(seconds: 3);
    _timer = new Timer.periodic(
      oneTic,
      (Timer timer) {
        if (_start == 60.0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start = _start + 3;
          });
          addPluseSignal();
        }
      },
    );
  }

  void addPluseSignal() {
    setState(() {
      chartData = getChartData();
    });
  }

  List<HeartRate> getChartData() {
    List<HeartRate> data = [];
    if (count == 21600) {
      count = 0;
    }
    for (int i = 0; i < 1080; i++) {
      data.add(HeartRate(count, pluse_signal[count]));
      count++;
    }

    return data;
  }

  // Method to generate random numbers in the given range
  double getRandomInt(int min, int max) {
    final Random random = Random();
    return double.parse((min + random.nextInt(max - min)).toString());
  }

  @override
  void initState() {
    /* _chartSeriesController=ChartSeriesController(); */
    for (int i = 0; i < 1080; i++) {
      chartData.add(
        HeartRate(i, 0),
      );
    }

    Timer(Duration(seconds: 1), () {
      startTimer();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 30,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Heart Rate",
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColor.primary_blue,
                          fontWeight: FontWeight.bold),
                    ),
                    RichText(
                        text: TextSpan(
                      children: [
                        TextSpan(
                          text: "78",
                          style: TextStyle(
                            fontSize: 76,
                            color: AppColor.white,
                          ),
                        ),
                        TextSpan(
                          text: " bpm",
                          style: TextStyle(
                            fontSize: 32,
                            color: AppColor.light_black,
                          ),
                        ),
                      ],
                    ))
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 50,
              child: Container(
                child: SfCartesianChart(
                  margin: EdgeInsets.all(0),
                  plotAreaBorderColor: AppColor.background,
                  enableSideBySideSeriesPlacement: false,
                  primaryXAxis: NumericAxis(
                    isVisible: false,
                    majorGridLines: MajorGridLines(width: 0),
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                  ),
                  primaryYAxis: NumericAxis(
                      visibleMaximum: 1.05,
                      visibleMinimum: -0.65,
                      isVisible: false,
                      majorGridLines: MajorGridLines(width: 0),
                      interval: 5),
                  series: <ChartSeries>[
                    // Renders fast line chart
                    FastLineSeries<HeartRate, int>(
                      animationDuration: 3000,
                      color: AppColor.primary_blue,
                      width: 1.5,
                      dataSource: chartData,
                      xValueMapper: (HeartRate data, _) => data.countTime,
                      yValueMapper: (HeartRate data, _) => data.signal,
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 20,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Max",
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColor.light_black,
                          ),
                        ),
                        Text(
                          "70",
                          style: TextStyle(
                            fontSize: 42,
                            color: AppColor.primary_blue,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Min",
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColor.light_black,
                          ),
                        ),
                        Text(
                          "50",
                          style: TextStyle(
                            fontSize: 42,
                            color: AppColor.primary_blue,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Avg",
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColor.light_black,
                          ),
                        ),
                        Text(
                          "65",
                          style: TextStyle(
                            fontSize: 42,
                            color: AppColor.primary_blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      /*     floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
            
            },
            child: Icon(Icons.add),
          ),
          SizedBox(
            width: 7,
          ),
          FloatingActionButton(
            onPressed: () {
              _chartSeriesController?.animate();
              /* _timer.cancel(); */
            },
            child: Icon(Icons.remove),
          ),
        ],
      ), */
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
