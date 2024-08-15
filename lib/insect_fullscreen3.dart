
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syngenta/homepage.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
class FullScreenChart3 extends StatelessWidget {
  final List<apiData> chartData;

  FullScreenChart3({required this.chartData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GRAPH FOR INSECT COUNT'),
      ),
      body: SfCartesianChart(
                            // legend: Legend(
                              // isVisible: false,
                              // name:legend,
                              // position: LegendPosition.top,
                              // offset: const Offset(550, -150),
                              // title: LegendTitle(
                              //     text: 'Insect',
                              //     textStyle: TextStyle(
                              //         color: Colors.black,
                              //         fontSize: 15,
                              //         fontStyle: FontStyle.italic,
                              //         fontWeight: FontWeight.w900)),
                              // toggleSeriesVisibility: true,
                              // Border color and border width of legend
                              // overflowMode: LegendItemOverflowMode.wrap,
                              // borderColor: Colors.black,
                              // borderWidth: 2
                            // ), 
                            legend: Legend(
      isVisible: true,
      position: LegendPosition.bottom,
    ),
                            plotAreaBackgroundColor: Colors.white,
                            primaryXAxis: CategoryAxis(
                              title: AxisTitle(
                                text: 'Time',
                                textStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                              labelRotation: 45,
                            ),
                            primaryYAxis: NumericAxis(
                              title: AxisTitle(
                                text: 'Insect Count',
                                textStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                              axisLine: AxisLine(width: 0),
                              majorGridLines: MajorGridLines(width: 0.5),
                              interval: 1,
                            ),
                            // tooltipBehavior: _tooltipBehavior,
                            tooltipBehavior: TooltipBehavior(
                              enable: true,
                              color: Colors.white,
                              // textStyle: TextStyle(color: Colors.white),
                              builder: (dynamic data,
                                  dynamic point,
                                  dynamic series,
                                  int pointIndex,
                                  int seriesIndex) {
                                final apiData item = chartData1[pointIndex];
                                return Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 245, 214, 250),
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.purple, blurRadius: 3)
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("TimeStamp: ${item.TimeStamp}"),
                                      Text("BOMUTE Count: ${item.Predictions}"),
                                      Text("APISME Count: ${item.Predictions}"),
                                      Text("OSMACO Count: ${item.Predictions}"),
                                    ],
                                  ),
                                );
                              },
                            ),
                            // title: ChartTitle(
                              // text: 'GRAPH FOR INSECT COUNT',
                              // textStyle: TextStyle(fontWeight: FontWeight.bold),
                            // ),

                            series: <ChartSeries<apiData, String>>[
                              LineSeries<apiData, String>(
                                
                                name: 'BOMUTE',
                                markerSettings: const MarkerSettings(
                                  height: 3.0,
                                  width: 3.0,
                                  borderColor: Colors.green,
                                  isVisible: true,
                                ),
                                dataSource: chartData1,
                                xValueMapper: (apiData sales, _) =>
                                    sales.TimeStamp,
                                yValueMapper: (apiData sales, _) =>
                                    sales.Predictions,
                                
                                dataLabelSettings:
                                    DataLabelSettings(isVisible: false),
                                enableTooltip: true,
                                animationDuration: 0,
                                color: Colors.green,
                              ),
                              LineSeries<apiData, String>(
                                // Text("Class: ${item.Class}"),
                                // name: apiData.Class as dynamic,
                                // name: 'Apis Mellifera',
                                name: 'APISME',
                                markerSettings: const MarkerSettings(
                                  height: 3.0,
                                  width: 3.0,
                                  borderColor: Colors.red,
                                  isVisible: true,
                                ),
                                dataSource: chartData2,
                                xValueMapper: (apiData sales, _) =>
                                    sales.TimeStamp,
                                yValueMapper: (apiData sales, _) =>
                                    sales.Predictions,
                                
                                dataLabelSettings:
                                    DataLabelSettings(isVisible: false),
                                enableTooltip: true,
                                animationDuration: 0,
                                color: Colors.red,
                              ),

                                LineSeries<apiData, String>(
                                // Text("Class: ${item.Class}"),
                                // name: apiData.Class as dynamic,
                                // name: 'Apis Mellifera',
                                name: 'OSMACO',
                                markerSettings: const MarkerSettings(
                                  height: 3.0,
                                  width: 3.0,
                                  borderColor: Colors.blue,
                                  isVisible: true,
                                ),
                                dataSource: chartData3,
                                xValueMapper: (apiData sales, _) =>
                                    sales.TimeStamp,
                                yValueMapper: (apiData sales, _) =>
                                    sales.Predictions,
                                // yValueMapper: (apiData sales, _) {
                                //   final apismeValue = sales.Predictions["APISME"];
                                //   print("APISME Value: $apismeValue");
                                //   return apismeValue != null
                                //       ? int.parse(apismeValue)
                                //       : 0;
                                // },

                                // double.parse(sales.Predictions['OSMACO'].toString()),
                                // name: ((apiData sales, _) => sales.TimeStamp) [0],
                                // name: apiData.Class,
                                // legendItemText: (apiData sales, _) => sales.Class,
                                dataLabelSettings:
                                    DataLabelSettings(isVisible: false),
                                enableTooltip: true,
                                animationDuration: 0,
                                color: Colors.blue,
                              )
                            ],
                            zoomPanBehavior: ZoomPanBehavior(
                              enablePinching: true,
                              enablePanning: true,
                              enableDoubleTapZooming: true,
                              enableMouseWheelZooming: true,
                              enableSelectionZooming: true,
                              selectionRectBorderWidth: 1.0,
                              selectionRectBorderColor: Colors.blue,
                              selectionRectColor:
                                  Colors.transparent.withOpacity(0.3),
                              zoomMode: ZoomMode.x,
                            ),
                          ),
    );
  }
}
