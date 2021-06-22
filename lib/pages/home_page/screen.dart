import 'package:flutter/material.dart';
import 'package:heart_beat_monitor/constants/colors.dart';
import 'package:heart_beat_monitor/models/heart_rate.dart';
import 'package:heart_beat_monitor/pages/home_page/bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as Graph;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // variables
  late HomeBloc _bloc;

  @override
  void initState() {
    _bloc = new HomeBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            buildMetricsSection(),
            getBeatsGraph(),
            getReader(),
          ],
        ),
      ),
    );
  }

  Widget buildMetricsSection() {
    return Expanded(
      flex: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getTopTittle(),
              SizedBox(
                height: 3,
              ),
              getHeartBeatDisplay(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              getMetricsDisplay(title: "Max", stream: _bloc.maxHeartBeatStream),
              getMetricsDisplay(title: "Min", stream: _bloc.minHeartBeatStream),
              getMetricsDisplay(title: "Avg", stream: _bloc.avgHeartBeatStream),
            ],
          ),
        ],
      ),
    );
  }

  Widget getBeatsGraph() {
    return Expanded(
      flex: 35,
      child: Container(
        child: StreamBuilder<dynamic>(
          stream: _bloc.chartDataStream,
          builder: (context, snapshot) {
            try {
              return SfCartesianChart(
                margin: EdgeInsets.symmetric(
                  vertical: 35,
                  horizontal: 0,
                ),
                plotAreaBorderColor: AppColor.background,
                enableSideBySideSeriesPlacement: false,
                primaryXAxis: NumericAxis(
                  isVisible: false,
                  majorGridLines: MajorGridLines(width: 0),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                ),
                primaryYAxis: NumericAxis(
                  visibleMaximum: 1.5,
                  visibleMinimum: -0.65,
                  isVisible: false,
                  majorGridLines: MajorGridLines(width: 0),
                  interval: 5,
                ),
                series: <ChartSeries>[
                  FastLineSeries<HeartRate, int>(
                    gradient: LinearGradient(
                      stops: [0.2, 0.496, 0.32],
                      colors: [
                        Color(0x70A2E5DF),
                        Color(0xffA2E5DF),
                        Color(0x15A2E5DF),
                      ],
                    ),
                    animationDuration: 0,
                    color: AppColor.primary_blue,
                    width: 2,
                    dataSource: snapshot.data,
                    xValueMapper: (HeartRate data, _) => _,
                    yValueMapper: (HeartRate data, _) => data.signal,
                  ),
                ],
              );
            } catch (e) {
              print(e);
              return Container();
            }
          },
        ),
      ),
    );
  }

  Widget getReader() {
    return Expanded(
      flex: 25,
      child: Container(
        child: Center(
          child: GestureDetector(
            onLongPressStart: (_) {
              _bloc.log.v("On the reader");
              _bloc.startReader();
              _bloc.setFingerTouchState!(true);
            },
            onLongPressEnd: (_) {
              _bloc.log.v("Off the reader");
              _bloc.setFingerTouchState!(false);
            },
            child: StreamBuilder<dynamic>(
              stream: _bloc.timerStateStream,
              builder: (context, snapshot) {
                // initial fingerprint animator
                if (snapshot.data == null || snapshot.data == false) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "assets/images/finger-active.gif",
                        height: 100,
                        width: 100,
                      ),
                    ],
                  );
                } else {
                  // reader animator with loader
                  return getReaderGouge();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget getReaderGouge() {
    return StreamBuilder<dynamic>(
      stream: _bloc.fingerTouchStateStream,
      builder: (context, fingerState) {
        return Opacity(
          opacity: fingerState.data == true ? 1 : 0.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                "assets/images/scanning.gif",
                height: 70,
                width: 70,
              ),
              Container(
                width: 200,
                height: 200,
                child: StreamBuilder<dynamic>(
                  stream: _bloc.timerStartValueStream,
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return getRadialGouge(0);
                    }
                    return getRadialGouge(snapshot.data);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget getRadialGouge(double value) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 60,
          showLabels: false,
          showTicks: false,
          startAngle: 270,
          endAngle: 270,
          radiusFactor: 0.4,
          pointers: <GaugePointer>[
            RangePointer(
              animationDuration: 1000,
              value: value,
              cornerStyle: Graph.CornerStyle.bothFlat,
              width: 0.1,
              sizeUnit: GaugeSizeUnit.factor,
              color: AppColor.primary_blue,
            )
          ],
          axisLineStyle: AxisLineStyle(
            thickness: 0.1,
            color: Color(0x15A2E5DF),
            thicknessUnit: GaugeSizeUnit.factor,
          ),
        )
      ],
    );
  }

  Widget getMetricsDisplay({
    required String title,
    required Stream stream,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: AppColor.light_black,
          ),
        ),
        StreamBuilder<dynamic>(
          stream: stream,
          builder: (context, snapshot) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (BuildContext context, double opacity, Widget? child) {
                return Opacity(
                  opacity: opacity,
                  child: Text(
                    "${snapshot.data ?? 0}",
                    style: TextStyle(
                      fontSize: 42,
                      color: AppColor.primary_blue,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget getTopTittle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              "assets/images/heart-active.gif",
              height: 40,
              width: 40,
            ),
            getSmallerRadialGouge(),
          ],
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          "Heart Rate",
          style: TextStyle(
              fontSize: 14,
              color: AppColor.primary_blue,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 10,
        ),
      ],
    );
  }

  Widget getSmallerRadialGouge() {
    return StreamBuilder<dynamic>(
      stream: _bloc.timerStartValueStream,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Container(
            width: 50,
            height: MediaQuery.of(context).size.width < 320 ? 50 : 100,
            child: Container(),
          );
        } else {
          return Container(
            width: 50,
            height: MediaQuery.of(context).size.width < 320 ? 50 : 100,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 60,
                  showLabels: false,
                  showTicks: false,
                  startAngle: 270,
                  endAngle: 270,
                  radiusFactor: 0.9,
                  pointers: <GaugePointer>[
                    RangePointer(
                      animationDuration: 1000,
                      value: snapshot.data,
                      cornerStyle: Graph.CornerStyle.bothFlat,
                      width: 0.1,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: AppColor.primary_blue,
                    )
                  ],
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.1,
                    color: AppColor.background,
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }

  Widget getHeartBeatDisplay() {
    return StreamBuilder<dynamic>(
      stream: _bloc.heartBeatStream,
      builder: (context, snapshot) {
        String type = _bloc.getDisplayText(snapshot.data ?? 0);
        double fontsize = MediaQuery.of(context).size.width < 320 ? 62 : 76;

        switch (type) {
          case "Single":
            return displayHeartBeat("00", fontsize, snapshot);
          case "Double":
            return displayHeartBeat("0", fontsize, snapshot);
          default:
            return displayHeartBeat("", fontsize, snapshot);
        }
      },
    );
  }

  Widget displayHeartBeat(
      String zeroes, double fontsize, AsyncSnapshot snapshot) {
    return RichText(
        text: TextSpan(
      children: [
        TextSpan(
          text: zeroes,
          style: TextStyle(
            fontSize: fontsize,
            color: Color(0xff313244),
          ),
        ),
        TextSpan(
          text: "${snapshot.data ?? 0}",
          style: TextStyle(
            fontSize: fontsize,
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
    ));
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
