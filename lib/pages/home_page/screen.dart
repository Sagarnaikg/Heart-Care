import 'package:flutter/material.dart';
import 'package:heart_beat_monitor/constants/colors.dart';
import 'package:heart_beat_monitor/models/heart_rate.dart';
import 'package:heart_beat_monitor/pages/home_page/bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as Graph;
import 'package:flutter_svg/flutter_svg.dart';

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
            buildDetailsSection(),
            Expanded(
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
                    }),
              ),
            ),
            Expanded(
              flex: 25,
              child: Container(
                  child: Center(
                child: GestureDetector(
                  onLongPressStart: (_) {
                    print("on the tap");
                    _bloc.startReader();
                    _bloc.setFingerTouchState!(true);
                  },
                  onLongPressEnd: (_) {
                    print("Off the tap");
                    _bloc.setFingerTouchState!(false);
                  },
                  child: StreamBuilder<dynamic>(
                      stream: _bloc.timerStateStream,
                      builder: (context, snapshot) {
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
                                                return SfRadialGauge(axes: <
                                                    RadialAxis>[
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
                                                        value: 0,
                                                        cornerStyle: Graph
                                                            .CornerStyle
                                                            .bothFlat,
                                                        width: 0.1,
                                                        sizeUnit: GaugeSizeUnit
                                                            .factor,
                                                        color: AppColor
                                                            .primary_blue,
                                                      )
                                                    ],
                                                    axisLineStyle:
                                                        AxisLineStyle(
                                                      thickness: 0.1,
                                                      color: Color(0x15A2E5DF),
                                                      thicknessUnit:
                                                          GaugeSizeUnit.factor,
                                                    ),
                                                  )
                                                ]);
                                              }

                                              return SfRadialGauge(axes: <
                                                  RadialAxis>[
                                                RadialAxis(
                                                  minimum: 0,
                                                  maximum: 61.375,
                                                  showLabels: false,
                                                  showTicks: false,
                                                  startAngle: 270,
                                                  endAngle: 270,
                                                  radiusFactor: 0.4,
                                                  pointers: <GaugePointer>[
                                                    RangePointer(
                                                      animationDuration: 1000,
                                                      value: snapshot.data,
                                                      cornerStyle: Graph
                                                          .CornerStyle.bothFlat,
                                                      width: 0.1,
                                                      sizeUnit:
                                                          GaugeSizeUnit.factor,
                                                      color:
                                                          AppColor.primary_blue,
                                                    )
                                                  ],
                                                  axisLineStyle: AxisLineStyle(
                                                    thickness: 0.1,
                                                    color: Color(0x15A2E5DF),
                                                    thicknessUnit:
                                                        GaugeSizeUnit.factor,
                                                  ),
                                                )
                                              ]);
                                            }),
                                      ),
                                    ],
                                  ),
                                );
                              });
                        }
                      }),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Expanded buildDetailsSection() {
    return Expanded(
      flex: 40,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
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
                        StreamBuilder<dynamic>(
                          stream: _bloc.timerStartValueStream,
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {
                              return Container(
                                  width: 50, height: 100, child: Container());
                            } else {
                              return Container(
                                width: 50,
                                height: 100,
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
                                          cornerStyle:
                                              Graph.CornerStyle.bothFlat,
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
                        ),
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
                ),
                SizedBox(
                  height: 3,
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
            Row(
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
