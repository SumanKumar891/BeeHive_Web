
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:syngenta/homepage.dart';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// class FullScreenChart2 extends StatelessWidget {
//   final List<apiData> chartData;

//   FullScreenChart2({required this.chartData});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Light Intensity Graph'),
//       ),
//       body: SfCartesianChart(
//                             // legend: Legend(
//                             //   isVisible: true,
//                             //   // name:legend,
//                             //   position: LegendPosition.top,
//                             //   offset: const Offset(550, -150),
//                             //   // toggleSeriesVisibility: true,
//                             //   // Border color and border width of legend
//                             //   overflowMode: LegendItemOverflowMode.wrap,
//                             //   // borderColor: Colors.black,
//                             //   // borderWidth: 2
//                             // ),
//                              legend: Legend(
//       isVisible: true,
//       position: LegendPosition.bottom,
//     ),
//                             plotAreaBackgroundColor: Colors.white,
//                             primaryXAxis: CategoryAxis(
//                               title: AxisTitle(
//                                 text: 'Time',
//                                 textStyle:
//                                     TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               labelRotation: 45,
//                             ),
//                             primaryYAxis: NumericAxis(
//                               title: AxisTitle(
//                                 text: 'Light Intensity(Lux)',
//                                 textStyle:
//                                     TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               axisLine: AxisLine(width: 0),
//                               majorGridLines: MajorGridLines(width: 0.5),
//                             ),
//                             tooltipBehavior: TooltipBehavior(
//                               enable: true,
//                               color: Colors.white,
//                               // textStyle: TextStyle(color: Colors.white),
//                               builder: (dynamic data,
//                                   dynamic point,
//                                   dynamic series,
//                                   int pointIndex,
//                                   int seriesIndex) {
//                                 final apiData item = chartData[pointIndex];
//                                 return Container(
//                                   padding: EdgeInsets.all(10),
//                                   decoration: BoxDecoration(
//                                     color: Color.fromARGB(255, 245, 214, 250),
//                                     borderRadius: BorderRadius.circular(5),
//                                     boxShadow: [
//                                       BoxShadow(
//                                           color: Colors.purple, blurRadius: 3)
//                                     ],
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text("TimeStamp: ${item.TimeStamp}"),
//                                       Text(
//                                           "Light Intensity: ${item.Light_intensity}"),
//                                       // Text("Class: ${item.Class}"),
//                                     ],
//                                   ),
//                                 );
//                               },
//                               // customize the tooltip color
//                             ),
//                             // title: ChartTitle(
//                               // text: 'Light Intensity Graph',
//                               // textStyle: TextStyle(fontWeight: FontWeight.bold),
//                             // ),
//                             series: <ChartSeries<apiData, String>>[
//                               LineSeries<apiData, String>(
//                                 name: 'Light Intensity',
//                                 markerSettings: const MarkerSettings(
//                                   height: 3.0,
//                                   width: 3.0,
//                                   borderColor: Colors.green,
//                                   isVisible: true,
//                                 ),
//                                 dataSource: chartData,
//                                 xValueMapper: (apiData sales, _) =>
//                                     sales.TimeStamp,
//                                 yValueMapper: (apiData sales, _) =>
//                                     double.parse(sales.Light_intensity),
//                                 dataLabelSettings:
//                                     DataLabelSettings(isVisible: false),
//                                 enableTooltip: true,
//                                 animationDuration: 0,
//                                 color: Colors.green,
//                               )
//                             ],
//                             zoomPanBehavior: ZoomPanBehavior(
//                               enablePinching: true,
//                               enablePanning: true,
//                               enableDoubleTapZooming: true,
//                               enableMouseWheelZooming: true,
//                               enableSelectionZooming: true,
//                               selectionRectBorderWidth: 1.0,
//                               selectionRectBorderColor: Colors.blue,
//                               selectionRectColor:
//                                   Colors.transparent.withOpacity(0.3),
//                               zoomMode: ZoomMode.x,
//                             ),
//                           ),
//     );
//   }
// }
