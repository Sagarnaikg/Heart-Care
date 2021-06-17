import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:heart_beat_monitor/data/variables.dart';
import 'package:heart_beat_monitor/models/heart_rate.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc {
  final chartDataStreamController = BehaviorSubject<List<HeartRate>>.seeded([]);

  Stream<List<HeartRate>> get chartDataStream =>
      chartDataStreamController.stream;

  Function(List<HeartRate>)? get setChartData =>
      chartDataStreamController.isClosed
          ? null
          : chartDataStreamController.sink.add;

  final timerStartValueStreamController = BehaviorSubject<double>.seeded(0.0);

  Stream<double> get timerStartValueStream =>
      timerStartValueStreamController.stream;

  Function(double)? get setTimerStartValue =>
      timerStartValueStreamController.isClosed
          ? null
          : timerStartValueStreamController.sink.add;

  final beatsListIndexStreamController = BehaviorSubject<int>.seeded(0);

  Stream<int> get beatsListIndexStream => beatsListIndexStreamController.stream;

  Function(int)? get setbeatsListIndex =>
      beatsListIndexStreamController.isClosed
          ? null
          : beatsListIndexStreamController.sink.add;

  final chartDataListIndexStreamController = BehaviorSubject<int>.seeded(1079);

  Stream<int> get chartDataListIndexStream =>
      chartDataListIndexStreamController.stream;

  Function(int)? get setchartDataListIndex =>
      chartDataListIndexStreamController.isClosed
          ? null
          : chartDataListIndexStreamController.sink.add;

  final timerStateStreamController = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get timerStateStream => timerStateStreamController.stream;

  Function(bool)? get setTimerState => timerStateStreamController.isClosed
      ? null
      : timerStateStreamController.sink.add;

  final fingerTouchStateStreamController = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get fingerTouchStateStream =>
      fingerTouchStateStreamController.stream;

  Function(bool)? get setFingerTouchState =>
      fingerTouchStateStreamController.isClosed
          ? null
          : fingerTouchStateStreamController.sink.add;

  HomeBloc() {
    // will create 3sec frame of graph
    List<HeartRate> chartData = [];
    for (int i = 0; i < 1080; i++) {
      chartData.add(
        HeartRate(i, -0.3),
      );
    }
    setChartData!(chartData);
  }

  // variables
  Random rng = new Random();
  Timer? _timer;

  void startReader() {
    setTimerState!(true);
    if (_timer == null) {
      startTimer();
    } else {
      if (!_timer!.isActive) {
        startTimer();
      }
    }
  }

  void startTimer() {
    const oneTic = const Duration(milliseconds: 125);
    _timer = new Timer.periodic(
      oneTic,
      (Timer timer) {
        if (timerStartValueStreamController.value == 60) {
          timer.cancel();
          setTimerStartValue!(0);
          setbeatsListIndex!(0);
          setTimerState!(false);
        } else {
          double start = timerStartValueStreamController.value;
          setTimerStartValue!(start + 0.125);
          addPluseSignal();
        }
      },
    );
  }

  void addPluseSignal() {
    if (beatsListIndexStreamController.value == 21600) {
      setbeatsListIndex!(0);
    }
    for (int i = 0; i < 45; i++) {
      List<HeartRate> chartData = chartDataStreamController.value;
      chartData.removeAt(0);
      chartData.add(HeartRate(
          chartDataListIndexStreamController.value,
          pluse_signal[beatsListIndexStreamController.value] > 0
              ? -0.3
              : pluse_signal[beatsListIndexStreamController.value]));

      chartData.replaceRange(539, 540, [
        HeartRate(
            chartDataListIndexStreamController.value,
            fingerTouchStateStreamController.value == true
                ? pluse_signal[beatsListIndexStreamController.value]
                : -0.3)
      ]);

      setChartData!(chartData);
      int index = chartDataListIndexStreamController.value;
      setchartDataListIndex!(index + 1);
      index = beatsListIndexStreamController.value;
      setbeatsListIndex!(index + 1);
    }
  }

  void dispose() {
    _timer!.cancel();
    chartDataStreamController.close();
    timerStartValueStreamController.close();
    beatsListIndexStreamController.close();
    chartDataListIndexStreamController.close();
    timerStateStreamController.close();
    fingerTouchStateStreamController.close();
  }
}
