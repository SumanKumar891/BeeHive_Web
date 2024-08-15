
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syngenta/homepage.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
class FullScreenChart extends StatelessWidget {
  final List<apiData> chartData;

  FullScreenChart({required this.chartData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Temperature and Relative Humidity'),
      ),
      body: SfCartesianChart(
        plotAreaBackgroundColor: Colors.white,
        primaryXAxis: CategoryAxis(
          title: AxisTitle(
            text: 'Time',
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          labelRotation: 45,
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(
            text: 'Temperature(°C)',
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          axisLine: AxisLine(width: 0),
          majorGridLines: MajorGridLines(width: 0.5),
        ),
          legend: Legend(
      isVisible: true,
      position: LegendPosition.bottom,
    ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          color: Colors.white,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
            final apiData item = chartData[pointIndex];
            return Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 245, 214, 250),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(color: Colors.purple, blurRadius: 3),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("TimeStamp: ${item.TimeStamp}"),
                  Text("Temperature: ${item.Temperature}"),
                ],
              ),
            );
          },
        ),
        // title: ChartTitle(
          // text: 'Temperature and Relative Humidity',
          // textStyle: TextStyle(fontWeight: FontWeight.bold),
        // ),
        series: <ChartSeries<apiData, String>>[
          LineSeries<apiData, String>(
             name: 'Temperature',
            markerSettings: const MarkerSettings(
              height: 3.0,
              width: 3.0,
              borderColor: Colors.green,
              isVisible: true,
            ),
            dataSource: chartData,
            xValueMapper: (apiData data, _) => data.TimeStamp,
            yValueMapper: (apiData data, _) => double.parse(data.Temperature),
            dataLabelSettings: DataLabelSettings(isVisible: false),
            enableTooltip: true,
            animationDuration: 0,
            color: Colors.green,
          ),
          LineSeries<apiData, String>(
            name: 'Relative Humidity',
            markerSettings: const MarkerSettings(
              height: 3.0,
              width: 3.0,
              borderColor: Color.fromARGB(255, 218, 96, 9),
              isVisible: true,
            ),
            dataSource: chartData,
            xValueMapper: (apiData data, _) => data.TimeStamp,
            yValueMapper: (apiData data, _) => double.parse(data.Relative_Humidity),
            dataLabelSettings: DataLabelSettings(isVisible: false),
            enableTooltip: true,
            animationDuration: 0,
             color: Color.fromARGB(255, 218, 96, 9),
          ),
        ],
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          enablePanning: true,
          enableDoubleTapZooming: true,
          enableMouseWheelZooming: true,
          enableSelectionZooming: true,
          selectionRectBorderWidth: 1.0,
          selectionRectBorderColor: Colors.blue,
          selectionRectColor: Colors.transparent.withOpacity(0.3),
          zoomMode: ZoomMode.x,
        ),
      ),
    );
  }
}
