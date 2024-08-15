import 'dart:html';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

class birdNet extends StatefulWidget {
  final String deviceId;

  const birdNet({Key? key, required this.deviceId}) : super(key: key);

  @override
  State<birdNet> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<birdNet> {
  late DateTime _startDate;
  late DateTime _endDate;
  String errorMessage = '';
  List<ApiData> tableData = [];
  String searchTimestamp = '';
  late TextEditingController _searchController; // Add TextEditingController

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> getAPIData(
      String deviceId, DateTime startDate, DateTime endDate) async {
    final response = await http.get(Uri.https(
      'n7xpn7z3k8.execute-api.us-east-1.amazonaws.com',
      '/default/bird_detections',
      {
        'deviceId': deviceId,
        'startDate': DateFormat('dd-MM-yyyy').format(startDate),
        'endDate': DateFormat('dd-MM-yyyy').format(endDate),
      },
    ));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        tableData = jsonData.map((item) => ApiData.fromJson(item)).toList();
        // Sort the tableData list based on timestamp in descending order
        tableData.sort((a, b) => DateFormat('dd-MM-yyyy_HH-mm-ss')
            .parse(b.timestamp)
            .compareTo(DateFormat('dd-MM-yyyy_HH-mm-ss').parse(a.timestamp)));
      });
    } else {
      setState(() {
        errorMessage = 'Failed to load data';
      });
    }
  }

  void updateData() async {
    await getAPIData(widget.deviceId, _startDate, _endDate);
  }

  Future<void> downloadMp3(String deviceId, String timestamp) async {
    try {
      final filename = '$deviceId' + "_" + '$timestamp.mp3';
      final url =
          'https://1yyfny7qh1.execute-api.us-east-1.amazonaws.com/download?key=$filename';
      print('Downloading file from: $url');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final blob = Blob([response.bodyBytes]);
        final anchor = AnchorElement(href: Url.createObjectUrlFromBlob(blob));
        anchor.download = filename;
        anchor.click();
        print('File downloaded successfully');
      } else {
        print('Failed to download file: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  void searchByTimestamp(String timestamp) {
    setState(() {
      searchTimestamp = timestamp;
    });
  }

  Future<void> downloadTableDataAsCsv() async {
    try {
      final List<List<String>> csvData = [
        ['Timestamp', 'Common Name', 'Scientific Name', 'Confidence']
      ];
      for (final data in tableData) {
        for (final detection in data.detections) {
          csvData.add([
            data.timestamp,
            detection.commonName,
            detection.scientificName,
            detection.confidence.toString(),
          ]);
        }
      }
      final csvString = const ListToCsvConverter().convert(csvData);
      final filename =
          "$_startDate" + "" + "$_endDate" + "" + 'bird_detections.csv';

      final blob = Blob([csvString]);
      final anchor = AnchorElement(href: Url.createObjectUrlFromBlob(blob));
      anchor.download = filename;
      anchor.click();
    } catch (e) {
      print('Error downloading CSV: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bee Data for ' + widget.deviceId,
          style: TextStyle(
            fontSize: 20.0,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 123, 156, 125),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 20), // Adding horizontal padding
                  child: SizedBox(
                    height: 60,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(
                            8.0), // Adding internal padding
                        // child: Text(
                        //   '"Hunt birds with cameras, not with guns. Save them!!"',
                        //   style: TextStyle(
                        //     fontSize: 20,
                        //     fontWeight: FontWeight.bold,
                        //     fontStyle: FontStyle.italic,
                        //     backgroundColor: Color.fromARGB(255, 227, 227, 227),
                        //   ),
                        //   textAlign: TextAlign.center,
                        // ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              onTap: () async {
                                final DateTime? selectedDate =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color.fromARGB(
                                              255, 123, 156, 125),
                                          onPrimary: Colors.white,
                                          onSurface: Colors.purple,
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            elevation: 10,
                                            backgroundColor: Colors.black,
                                          ),
                                        ),
                                      ),
                                      child: MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                          alwaysUse24HourFormat: true,
                                        ),
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
                                  text: DateFormat('dd-MM-yyyy')
                                      .format(_startDate)),
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Expanded(
                            child: TextFormField(
                              onTap: () async {
                                final DateTime? selectedDate =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color.fromARGB(
                                              255, 123, 156, 125),
                                          onPrimary: Colors.white,
                                          onSurface: Colors.purple,
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            elevation: 10,
                                            backgroundColor: Colors.black,
                                          ),
                                        ),
                                      ),
                                      child: MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                          alwaysUse24HourFormat: true,
                                        ),
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
                                  text: DateFormat('dd-MM-yyyy')
                                      .format(_endDate)),
                            ),
                          ),
                          SizedBox(width: 20.0),
                          ElevatedButton(
                            onPressed: () {
                              updateData();
                            },
                            child: Icon(
                              Icons.autorenew,
                              size: 20,
                              color: Colors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 123, 156, 125),
                              minimumSize: Size(20, 0),
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(width: 20.0),
                          ElevatedButton(
                            onPressed: () async {
                              await downloadTableDataAsCsv();
                            },
                            child: Text(
                              "Fetch Data",
                              style: TextStyle(
                                  backgroundColor:
                                      Color.fromARGB(255, 123, 156, 125),
                                  color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 123, 156, 125),
                              minimumSize: Size(80, 0),
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(width: 20.0),
                          IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              searchByTimestamp(_searchController.text);
                            },
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: TextFormField(
                              controller: _searchController,
                              onChanged: (value) {
                                searchByTimestamp(value);
                              },
                              decoration: InputDecoration(
                                hintText: 'Search Timestamp',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      // Error message
                      if (errorMessage.isNotEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              errorMessage,
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 16.0),
                      // Table data
                      DataTable(
                        decoration: BoxDecoration(),
                        dataRowHeight: 60,
                        columns: [
                          DataColumn(
                            label: SizedBox(
                              // Wrap the label with SizedBox to set fixed width
                              width:
                                  50, // Set a fixed width for the Index column
                              child: Text(
                                'Index',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            numeric:
                                true, // This indicates that the column contains numeric data
                          ),
                          DataColumn(
                            label: SizedBox(
                              // Wrap the label with SizedBox to set fixed width
                              width:
                                  150, // Set a fixed width for the Common Name column
                              child: Text(
                                'Timestamp',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // DataColumn(
                          //   label: SizedBox(
                          //     // Wrap the label with SizedBox to set fixed width
                          //     width:
                          //         150, // Set a fixed width for the Common Name column
                          //     child: Text(
                          //       'Common Name',
                          //       style: TextStyle(
                          //         fontWeight: FontWeight.bold,
                          //         fontSize: 15,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // DataColumn(
                          //   label: SizedBox(
                          //     // Wrap the label with SizedBox to set fixed width
                          //     width:
                          //         150, // Set a fixed width for the Scientific Name column
                          //     child: Text(
                          //       'Scientific Name',
                          //       style: TextStyle(
                          //         fontWeight: FontWeight.bold,
                          //         fontSize: 15,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // DataColumn(
                          //   label: SizedBox(
                          //     // Wrap the label with SizedBox to set fixed width
                          //     width:
                          //         100, // Set a fixed width for the Confidence column
                          //     child: Text(
                          //       'Confidence',
                          //       style: TextStyle(
                          //         fontWeight: FontWeight.bold,
                          //         fontSize: 15,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          DataColumn(
                            label: SizedBox(
                              // Wrap the label with SizedBox to set fixed width
                              width:
                                  150, // Set a fixed width for the Download Mp3 column
                              child: Text(
                                'Download Mp3',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                        rows: tableData
                            .asMap()
                            .entries
                            .where((entry) => entry.value.timestamp
                                .startsWith(searchTimestamp))
                            .map(
                              (entry) => DataRow(
                                cells: [
                                  DataCell(
                                    SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (entry.key + 1).toString(),
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry.value.timestamp,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: entry.value.detections
                                            .map(
                                              (detection) => Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    (entry.value.detections.indexOf(
                                                                    detection) +
                                                                1)
                                                            .toString() +
                                                        ") " +
                                                        detection.commonName,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  if (detection !=
                                                      entry.value.detections
                                                          .last)
                                                    Divider(),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: entry.value.detections
                                            .map(
                                              (detection) => Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    (entry.value.detections.indexOf(
                                                                    detection) +
                                                                1)
                                                            .toString() +
                                                        ") " +
                                                        detection
                                                            .scientificName,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  if (detection !=
                                                      entry.value.detections
                                                          .last)
                                                    Divider(),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: entry.value.detections
                                            .map(
                                              (detection) => Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    (entry.value.detections.indexOf(
                                                                    detection) +
                                                                1)
                                                            .toString() +
                                                        ") " +
                                                        detection.confidence
                                                            .toStringAsFixed(3),
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  if (detection !=
                                                      entry.value.detections
                                                          .last)
                                                    Divider(),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        downloadMp3(widget.deviceId,
                                            entry.value.timestamp);
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Colors.teal,
                                        ),
                                      ),
                                      child: Text('Download'),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApiData {
  final String timestamp;
  final List<Detection> detections;

  ApiData({
    required this.timestamp,
    required this.detections,
  });

  factory ApiData.fromJson(Map<String, dynamic> json) {
    return ApiData(
      timestamp: json['TimeStamp'],
      detections: (json['Detections'] as List)
          .map((detectionJson) => Detection.fromJson(detectionJson))
          .toList(),
    );
  }
}

class Detection {
  final String commonName;
  final String scientificName;
  final double confidence;

  Detection({
    required this.commonName,
    required this.scientificName,
    required this.confidence,
  });

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      commonName: json['common_name'],
      scientificName: json['scientific_name'],
      confidence:
          double.parse((json['confidence'] as double).toStringAsFixed(3)),
    );
  }
}
