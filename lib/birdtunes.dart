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
import 'package:aws_common/web.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http_parser/http_parser.dart';

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

  // Dropdown value
  String? _selectedDeviceId;
  List<String> _deviceIds = []; // List of device IDs

  // Device details
  String _deviceStatus = 'Unknown';
  String _lastReceivedTime = 'Unknown';

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    _searchController = TextEditingController();
    _deviceIds = [widget.deviceId]; // Initialize with current device ID

    // Fetch additional device IDs if needed
    fetchDeviceIds();
  }

  Future<void> fetchDeviceIds() async {
    // Add your code to fetch device IDs
    // Example:
    // final response = await http.get(...);
    // if (response.statusCode == 200) {
    //   setState(() {
    //     _deviceIds = jsonDecode(response.body);
    //   });
    // }
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
    if (_selectedDeviceId != null) {
      await getAPIData(_selectedDeviceId!, _startDate, _endDate);
      await updateDeviceDetails(_selectedDeviceId!);
    }
  }

  Future<void> updateDeviceDetails(String deviceId) async {
    // Fetch device details
    final response = await http.get(Uri.https(
      'c27wvohcuc.execute-api.us-east-1.amazonaws.com',
      '/default/beehive_activity_api',
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final device = (data['devices'] as List<dynamic>).firstWhere(
        (device) => device['deviceId'] == deviceId,
        orElse: () => {'deviceId': 'Unknown', 'lastReceivedTime': 'Unknown'},
      );

      setState(() {
        _deviceStatus = _getDeviceStatus(device['lastReceivedTime']);
        _lastReceivedTime = device['lastReceivedTime'];
      });
    }
  }

  String _getDeviceStatus(String lastReceivedTime) {
    if (lastReceivedTime == 'Unknown') return 'Unknown';

    try {
      final lastReceivedDate = DateTime.parse(lastReceivedTime);
      final currentTime = DateTime.now();
      final difference = currentTime.difference(lastReceivedDate);

      if (difference.inMinutes <= 2) {
        return 'Active';
      } else {
        return 'Inactive';
      }
    } catch (e) {
      return 'Inactive';
    }
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
        backgroundColor: Color.fromARGB(
          255,
          52,
          73,
          94,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device ID Dropdown
            DropdownButtonFormField<String>(
              value: _selectedDeviceId,
              decoration: InputDecoration(
                labelText: 'Select Device ID',
                border: OutlineInputBorder(),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDeviceId = newValue;
                  updateData();
                });
              },
              items: _deviceIds.map<DropdownMenuItem<String>>((deviceId) {
                return DropdownMenuItem<String>(
                  value: deviceId,
                  child: Text(deviceId),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // Device Details
            if (_selectedDeviceId != null) ...[
              Text(
                'Device ID: $_selectedDeviceId',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Current Status: $_deviceStatus',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Last Received Time: $_lastReceivedTime',
                style: TextStyle(fontSize: 16),
              ),
            ],
            SizedBox(height: 24),

            // Date Pickers and Button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _searchController,
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null && pickedDate != _startDate) {
                            setState(() {
                              _startDate = pickedDate;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: DateFormat('yyyy-MM-dd').format(_startDate),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Date:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _searchController,
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null && pickedDate != _endDate) {
                            setState(() {
                              _endDate = pickedDate;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: DateFormat('yyyy-MM-dd').format(_endDate),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                updateData();
              },
              child: Text('Update Data'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await downloadTableDataAsCsv();
              },
              child: Text('Download CSV'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add your functionality for uploading audio
              },
              child: Text('Upload Audio'),
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

  ApiData({required this.timestamp, required this.detections});

  factory ApiData.fromJson(Map<String, dynamic> json) {
    var detectionsList = json['detections'] as List<dynamic>;
    List<Detection> detections = detectionsList
        .map((detectionJson) => Detection.fromJson(detectionJson))
        .toList();
    return ApiData(
      timestamp: json['timestamp'],
      detections: detections,
    );
  }
}

class Detection {
  final String commonName;
  final String scientificName;
  final double confidence;

  Detection(
      {required this.commonName,
      required this.scientificName,
      required this.confidence});

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      commonName: json['commonName'],
      scientificName: json['scientificName'],
      confidence: json['confidence'].toDouble(),
    );
  }
}
