import 'dart:convert';
import 'dart:html' as html;
import 'package:csv/csv.dart';
import 'check_permission.dart';
import 'directory_path.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'constant.dart';

class Weather extends StatefulWidget {
  // final String deviceId;

  // const Weather({
  //   super.key,
  //   required this.deviceId,
  // });

  @override
  State<Weather> createState() => _MyHomePageState();
}

List<apiData> chartData = [];
List<Device> activeDeviceData = [];
List<Device> inactiveDeviceData = [];
List<Device> filteredDeviceData = [];
String? _selectedDeviceId;
TextEditingController _searchController = TextEditingController();

class _MyHomePageState extends State<Weather> {
  late TooltipBehavior _tooltipBehavior;
  late DateTime _startDate;
  late DateTime _endDate;
  List<dynamic> data = [];
  late String csvString = " ";
  String errorMessage = '';
  late String Class = " ";
  var checkAllPermission = CheckPermission();
  var getDirectoryPath = DirectoryPath();

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.parse(DateTime.now().toString());
    _endDate = DateTime.parse(DateTime.now().toString());
  }

  void _filterDevices() {
    setState(() {
      filteredDeviceData = deviceData
          .where((device) => device.deviceId
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
      activeDeviceData = activeDevice
          .where((device) => device.deviceId
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
      inactiveDeviceData = inactiveDevice
          .where((device) => device.deviceId
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> getAPIData(
      String deviceId, DateTime _startDate, DateTime _endDate) async {
    final response = await http.get(Uri.https(
      'z6sd4rs5e9.execute-api.us-east-1.amazonaws.com',
      '/devlopement/lambda_db',
      {
        'startdate': _startDate.year.toString() +
            "-" +
            _startDate.month.toString() +
            "-" +
            _startDate.day.toString(),
        'enddate': _endDate.year.toString() +
            "-" +
            _endDate.month.toString() +
            "-" +
            _endDate.day.toString(),
        'deviceid': _selectedDeviceId,
      },
    ));
    final Map<String, dynamic> jsonDataMap =
        Map<String, dynamic>.from(json.decode(response.body));

    final List<Map<String, dynamic>> jsonData = [jsonDataMap];
    List<List<dynamic>> csvData = [
      [
        "TimeStamp",
        "DeviceId",
        "Light_intensity(Lux)",
        "Temperature(C)",
        "Relative_Humidity(%)",
      ]
    ];

    List<dynamic> row = [];
    List<dynamic> test = jsonData[0]["body"];
    int len = test.length;
    print("Data: ${len}");

    for (int i = 0; i < len; i++) {
      row = [];
      row.add(jsonData[0]["body"][i]['TimeStamp']);
      row.add(jsonData[0]["body"][i]['DeviceId']);
      row.add(jsonData[0]["body"][i]['Light_intensity(Lux)']);
      row.add(jsonData[0]["body"][i]['Temperature(C)']);
      row.add(jsonData[0]["body"][i]['Relative_Humidity(%)']);

      csvData.add(row);
    }

    csvString = const ListToCsvConverter().convert(csvData);
    print(csvString);
    var parsed = jsonDecode(response.body); //.cast<Map<String, dynamic>>();
    if (parsed['statusCode'] == 200) {
      data = parsed['body'];
      print(data);
      chartData.clear();
      for (dynamic i in data) {
        chartData.add(apiData.fromJson(i));
      }
      setState(() {});
    } else if (parsed['statusCode'] == 400 ||
        parsed['statusCode'] == 404 ||
        parsed['statusCode'] == 500) {
      setState(() {
        errorMessage = parsed['body'][0]['message'];
      });
    } else {
      throw Exception('Failed to load api');
    }
  }

  Future<void> downloadCsvFile(String csvString, String filename) async {
    // Convert the CSV string to a byte list.
    List<int> csvBytes = utf8.encode(csvString);

    // Create a blob containing the CSV data.
    final blob = html.Blob([csvBytes], 'text/csv');

    // Create a URL for the blob.
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create a download link and click it to initiate the download.
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..download = filename;
    html.document.body!.append(anchor);
    anchor.click();

    // Clean up by revoking the URL object.
    html.Url.revokeObjectUrl(url);
  }

  void handleDownloadButtonPressed() async {
    // String csvString = 'header1,header2,header3\nvalue1,value2,value3';
    String filename = 'InsectCount.csv';
    await downloadCsvFile(csvString, filename);
    print('Download completed!');
    print('Successful');
  }

  void updateData() async {
    await getAPIData(_selectedDeviceId!, _startDate, _endDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TimeSeries Graph For Weather Data for ' + _selectedDeviceId!,
          style: TextStyle(
            fontSize: 20.0,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        //with sub dropdowns
                        decoration: InputDecoration(
                          labelText: 'All Devices',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedDeviceId != null &&
                                activeDeviceData.any((device) =>
                                    device.deviceId == _selectedDeviceId)
                            ? _selectedDeviceId
                            : null,
                        items: [
                          ...activeDeviceData.map((device) {
                            return DropdownMenuItem<String>(
                              value: device.deviceId,
                              child: Text(
                                device.deviceId,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                          ...inactiveDeviceData.map((device) {
                            return DropdownMenuItem<String>(
                              value: device.deviceId,
                              child: Text(
                                device.deviceId,
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDeviceId = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.green,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.purple,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      elevation: 10,
                                      backgroundColor:
                                          Colors.black, // button text color
                                    ),
                                  ),
                                ),
                                // child: child!,
                                child: MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: true),
                                  child: child ?? Container(),
                                ),
                              );
                            },
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _startDate = selectedDate;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                        controller: TextEditingController(
                            text: _startDate != null
                                ? DateFormat('yyyy-MM-dd').format(_startDate)
                                : ''),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: TextFormField(
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.green,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.purple,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      elevation: 10,
                                      backgroundColor:
                                          Colors.black, // button text color
                                    ),
                                  ),
                                ),
                                // child: child!,
                                child: MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: true),
                                  child: child ?? Container(),
                                ),
                              );
                            },
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _endDate = selectedDate;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                        controller: TextEditingController(
                            text: _endDate != null
                                ? DateFormat('yyyy-MM-dd').format(_endDate)
                                : ''),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        updateData();
                      },
                      child: Text(
                        'Get Data',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green, // Set the button color to green
                        minimumSize:
                            Size(80, 0), // Set a minimum width for the button
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: handleDownloadButtonPressed,
                      child: Text(
                        'Download CSV',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green, // Set the button color to green
                        minimumSize:
                            Size(80, 0), // Set a minimum width for the button
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.0),
                if (errorMessage.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        height: 400,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            semanticsLabel: errorMessage = "",
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 400,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5.0,
                                spreadRadius: 1.0,
                                offset: Offset(0.0, 0.0),
                              ),
                            ],
                          ),
                          child: SfCartesianChart(
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
                                text: 'Temperature(°C)',
                                textStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                              axisLine: AxisLine(width: 0),
                              majorGridLines: MajorGridLines(width: 0.5),
                            ),
                            tooltipBehavior: TooltipBehavior(
                              enable: true,
                              color: Colors.white,
                              // textStyle: TextStyle(color: Colors.white),
                              builder: (dynamic data,
                                  dynamic point,
                                  dynamic series,
                                  int pointIndex,
                                  int seriesIndex) {
                                final apiData item = chartData[pointIndex];
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
                                      Text("Temperature: ${item.Temperature}"),
                                      // Text("Class: ${item.Class}"),
                                    ],
                                  ),
                                );
                              },
                              // customize the tooltip color
                            ),
                            title: ChartTitle(
                              text: 'Temperature Graph',
                              textStyle: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            series: <ChartSeries<apiData, String>>[
                              LineSeries<apiData, String>(
                                // name: 'Apis Mellifera',
                                markerSettings: const MarkerSettings(
                                  height: 3.0,
                                  width: 3.0,
                                  borderColor: Colors.green,
                                  isVisible: true,
                                ),
                                dataSource: chartData,
                                xValueMapper: (apiData sales, _) =>
                                    sales.TimeStamp,
                                yValueMapper: (apiData sales, _) =>
                                    double.parse(sales.Temperature),
                                dataLabelSettings:
                                    DataLabelSettings(isVisible: false),
                                enableTooltip: true,
                                animationDuration: 0,
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
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          height: 400,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5.0,
                                spreadRadius: 1.0,
                                offset: Offset(0.0, 0.0),
                              ),
                            ],
                          ),
                          child: SfCartesianChart(
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
                                text: 'Light Intensity(Lux)',
                                textStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                              axisLine: AxisLine(width: 0),
                              majorGridLines: MajorGridLines(width: 0.5),
                            ),
                            tooltipBehavior: TooltipBehavior(
                              enable: true,
                              color: Colors.white,
                              // textStyle: TextStyle(color: Colors.white),
                              builder: (dynamic data,
                                  dynamic point,
                                  dynamic series,
                                  int pointIndex,
                                  int seriesIndex) {
                                final apiData item = chartData[pointIndex];
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
                                      Text(
                                          "Light Intensity: ${item.Light_intensity}"),
                                      // Text("Class: ${item.Class}"),
                                    ],
                                  ),
                                );
                              },
                              // customize the tooltip color
                            ),
                            title: ChartTitle(
                              text: 'Light Intensity Graph',
                              textStyle: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            series: <ChartSeries<apiData, String>>[
                              LineSeries<apiData, String>(
                                // name: 'Apis Mellifera',
                                markerSettings: const MarkerSettings(
                                  height: 3.0,
                                  width: 3.0,
                                  borderColor: Colors.green,
                                  isVisible: true,
                                ),
                                dataSource: chartData,
                                xValueMapper: (apiData sales, _) =>
                                    sales.TimeStamp,
                                yValueMapper: (apiData sales, _) =>
                                    double.parse(sales.Light_intensity),
                                dataLabelSettings:
                                    DataLabelSettings(isVisible: false),
                                enableTooltip: true,
                                animationDuration: 0,
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
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          height: 400,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5.0,
                                spreadRadius: 1.0,
                                offset: Offset(0.0, 0.0),
                              ),
                            ],
                          ),
                          child: SfCartesianChart(
                            // legend: Legend(
                            //   isVisible: true,
                            //   // name:legend,
                            //   position: LegendPosition.top,
                            //   offset: const Offset(550, -150),
                            //   // toggleSeriesVisibility: true,
                            //   // Border color and border width of legend
                            //   overflowMode: LegendItemOverflowMode.wrap,
                            //   // borderColor: Colors.black,
                            //   // borderWidth: 2
                            // ),
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
                                text: 'Relative Humidity(%)',
                                textStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                              axisLine: AxisLine(width: 0),
                              majorGridLines: MajorGridLines(width: 0.5),
                            ),
                            tooltipBehavior: TooltipBehavior(
                              enable: true,
                              color: Colors.white,
                              // textStyle: TextStyle(color: Colors.white),
                              builder: (dynamic data,
                                  dynamic point,
                                  dynamic series,
                                  int pointIndex,
                                  int seriesIndex) {
                                final apiData item = chartData[pointIndex];
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
                                      Text(
                                          "Relative Humidity: ${item.Relative_Humidity}"),
                                      // Text("Class: ${item.Class}"),
                                    ],
                                  ),
                                );
                              },
                              // customize the tooltip color
                            ),
                            title: ChartTitle(
                              text: 'Relative Humidity Graph',
                              textStyle: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            series: <ChartSeries<apiData, String>>[
                              LineSeries<apiData, String>(
                                // name: 'Apis Mellifera',
                                markerSettings: const MarkerSettings(
                                  height: 3.0,
                                  width: 3.0,
                                  borderColor: Colors.green,
                                  isVisible: true,
                                ),
                                dataSource: chartData,
                                xValueMapper: (apiData sales, _) =>
                                    sales.TimeStamp,
                                yValueMapper: (apiData sales, _) =>
                                    double.parse(sales.Relative_Humidity),
                                dataLabelSettings:
                                    DataLabelSettings(isVisible: false),
                                enableTooltip: true,
                                animationDuration: 0,
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
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<List<dynamic>> getAPIData(
    String deviceId, DateTime _startDate, DateTime _endDate) async {
  final response = await http.get(Uri.https(
    'z6sd4rs5e9.execute-api.us-east-1.amazonaws.com',
    '/devlopement/lambda_db',
    {
      'startdate': _startDate.year.toString() +
          "-" +
          _startDate.month.toString() +
          "-" +
          _startDate.day.toString(),
      'enddate': _endDate.year.toString() +
          "-" +
          _endDate.month.toString() +
          "-" +
          _endDate.day.toString(),
      'deviceid': deviceId,
    },
  ));
  var parsed = jsonDecode(response.body); //.cast<Map<String, dynamic>>();
  if (response.statusCode == 200) {
    List<dynamic> data = parsed['body'];
    return data;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load api');
  }
}

class apiData {
  apiData(this.TimeStamp, this.Light_intensity, this.Temperature,
      this.Relative_Humidity);

  final String TimeStamp;
  final String Light_intensity;
  final String Temperature;
  final String Relative_Humidity;

  factory apiData.fromJson(dynamic parsedJson) {
    return apiData(
      parsedJson['TimeStamp'].toString(),
      parsedJson['Light_intensity(Lux)'].toString(),
      parsedJson['Temperature(C)'].toString(),
      parsedJson['Relative_Humidity(%)'].toString(),
    );
  }
}
