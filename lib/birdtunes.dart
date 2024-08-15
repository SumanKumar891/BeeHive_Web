// ignore_for_file: unused_local_variable

import 'dart:html';
import 'dart:html' as html;
import 'dart:io';
import 'dart:io' as io;
import 'dart:js' as js;
import 'package:aws_common/aws_common.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:aws_common/web.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:amplify_flutter/amplify.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http_parser/http_parser.dart';
// class MinioClient {
//   final String endPoint;
//   final String accessKey;
//   final String secretKey;
//   final bool useSSL;

//   MinioClient({
//     required this.endPoint,
//     required this.accessKey,
//     required this.secretKey,
//     this.useSSL = false,
//   });

//   // Add methods for interacting with MinIO server here
// }

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
    // Amplify.addPlugins([AmplifyStorageS3()]);
    // configureAmplify();
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
        tableData.sort((b, a) => DateFormat('dd-MM-yyyy_HH-mm-ss')
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

  Future<void> uploadAudioToS3(String bucket, String filename) async {
    try {
      // Open file picker to select a file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'mp4', 'mpeg'],
      );

      if (result != null && result.files.isNotEmpty) {
        final Uint8List fileBytes = result.files.first.bytes!;
        final String fileExtension =
            path.extension(result.files.first.name!).toLowerCase();

        // Set the content type based on file extension
        String contentType = 'application/octet-stream'; // Default content type
        if (fileExtension == '.mp3') {
          contentType = 'audio/mpeg';
        } else if (fileExtension == '.mp4') {
          contentType = 'video/mp4';
        }

        final String apiUrl =
            'https://9ryl4dzduk.execute-api.us-east-1.amazonaws.com/dev/$bucket/$filename';

        // Prepare the HTTP request with streamed body
        final request = http.Request('PUT', Uri.parse(apiUrl))
          ..headers['Content-Type'] = contentType
          ..bodyBytes = fileBytes;

        // Send the HTTP request
        final response = await http.Client().send(request);

        // Handle response
        if (response.statusCode == 200) {
          print('File uploaded successfully');
        } else {
          print('File upload failed with status code: ${response.statusCode}');
        }
      } else {
        print('No file selected');
      }
    } catch (e) {
      print('File upload error: $e');
    }
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
          'Bird Calls for ' + widget.deviceId,
          style: TextStyle(
            fontSize: 20.0,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 152, 207, 158,),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
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
                            final DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
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
                              text:
                                  DateFormat('dd-MM-yyyy').format(_startDate)),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          onTap: () async {
                            final DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: _endDate,
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
                              text: DateFormat('dd-MM-yyyy').format(_endDate)),
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
                          backgroundColor: Color.fromARGB(255, 152, 207, 158,),
                          minimumSize: Size(80, 0),
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      ElevatedButton(
                        onPressed: () async {
                          await downloadTableDataAsCsv();
                        },
                        child: Text(
                          'Download CSV',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 152, 207, 158,),
                          minimumSize: Size(80, 0),
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      ElevatedButton(
                        onPressed: () async {
                          String timestamp = DateFormat('dd-MM-yyyy_HH-mm-ss')
                              .format(DateTime.now());
                          String filename = 'S10_$timestamp.mp3';
                          String bucketName = 'birdnet-sagemaker';
                          await uploadAudioToS3(bucketName, filename);
                        },
                        child: Text(
                          'Upload',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 152, 207, 158,),
                          minimumSize: Size(80, 0),
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
                            color: Color.fromARGB(255, 152, 207, 158,),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
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
                          width: 50, // Set a fixed width for the Index column
                          child: Text(
                            'Index',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        numeric:
                            true, // This indicates that the column contains numeric data
                      ),
                      // DataColumn(
                      //   label: SizedBox(
                      //     width:
                      //         160, // Set the desired width for the DataColumn containing the search field
                      //     child: Expanded(
                      //       child: Padding(
                      //         padding:
                      //             const EdgeInsets.symmetric(horizontal: 0.0),
                      //         child: TextField(
                      //           controller: _searchController,
                      //           onChanged: (value) {
                      //             setState(() {
                      //               // Handle changes if necessary
                      //             });
                      //           },
                      //           decoration: InputDecoration(
                      //             labelText: 'Timestamp',
                      //             labelStyle: TextStyle(
                      //               fontSize: 15,
                      //               color: Colors.black,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //             prefixIcon: Icon(CupertinoIcons.search),
                      //             contentPadding: EdgeInsets.symmetric(
                      //               vertical: 12,
                      //               horizontal: 16,
                      //             ),
                      //             border: InputBorder.none,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
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
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          // Wrap the label with SizedBox to set fixed width
                          width:
                              150, // Set a fixed width for the Common Name column
                          child: Text(
                            'Common Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          // Wrap the label with SizedBox to set fixed width
                          width:
                              150, // Set a fixed width for the Scientific Name column
                          child: Text(
                            'Scientific Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          // Wrap the label with SizedBox to set fixed width
                          width:
                              100, // Set a fixed width for the Confidence column
                          child: Text(
                            'Confidence',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          // Wrap the label with SizedBox to set fixed width
                          width:
                              100, // Set a fixed width for the Download Mp3 column
                          child: Text(
                            'Download',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                    rows: tableData
                        .asMap()
                        .entries
                        .where((entry) => entry.value.timestamp
                            .startsWith(_searchController.text))
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
                                          fontSize: 20,
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
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(
                                SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                                  fontSize: 20,
                                                ),
                                              ),
                                              if (detection !=
                                                  entry.value.detections.last)
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                                    detection.scientificName,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              if (detection !=
                                                  entry.value.detections.last)
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                                  fontSize: 20,
                                                ),
                                              ),
                                              if (detection !=
                                                  entry.value.detections.last)
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
                                    downloadMp3(
                                        widget.deviceId, entry.value.timestamp);
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
