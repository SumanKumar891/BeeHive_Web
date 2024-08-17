import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BirdNet extends StatefulWidget {
  final String deviceId;

  const BirdNet({Key? key, required this.deviceId}) : super(key: key);

  @override
  State<BirdNet> createState() => _BirdNetState();
}

class _BirdNetState extends State<BirdNet> {
  late DateTime _startDate;
  late DateTime _endDate;
  String errorMessage = '';
  List<ApiData> tableData = [];
  String searchTimestamp = '';
  late TextEditingController _searchController;
  List<dynamic> devices = [];
  String _selectedDevice = '';
  String _currentStatus = 'Loading';
  String _dataReceivedTime = 'Loading';
  DateTime _selectedDay = DateTime.now();
  bool _isDownloading = false; // Add a variable to track loading state

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    _searchController = TextEditingController();
    _fetchDevicesList();
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

  void searchByTimestamp(String timestamp) {
    setState(() {
      searchTimestamp = timestamp;
    });
  }

  Future<void> _fetchDevicesList() async {
    final response = await http.get(Uri.parse(
        'https://c27wvohcuc.execute-api.us-east-1.amazonaws.com/default/beehive_activity_api'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        devices = data;
        if (devices.isNotEmpty) {
          _selectedDevice = devices[0]['deviceId'];
          _updateDeviceDetails(devices[0]);
        }
      });
    } else {
      throw Exception('Failed to load devices');
    }
  }

  void _updateDeviceDetails(Map<String, dynamic> device) {
    final lastReceivedTime = device['lastReceivedTime'];
    setState(() {
      _currentStatus = _getDeviceStatus(lastReceivedTime);
      _dataReceivedTime = lastReceivedTime ?? 'Unknown';
    });
  }

  String _getDeviceStatus(String lastReceivedTime) {
    if (lastReceivedTime == 'Unknown') return 'Unknown';

    try {
      final dateTimeParts = lastReceivedTime.split('_');
      final datePart = dateTimeParts[0].split('-');
      final timePart = dateTimeParts[1].split('-');

      final day = int.parse(datePart[0]);
      final month = int.parse(datePart[1]);
      final year = int.parse(datePart[2]);

      final hour = int.parse(timePart[0]);
      final minute = int.parse(timePart[1]);
      final second = int.parse(timePart[2]);

      final lastReceivedDate = DateTime(year, month, day, hour, minute, second);
      final currentTime = DateTime.now();
      final difference = currentTime.difference(lastReceivedDate);

      if (difference.inMinutes <= 7) {
        return 'Active';
      } else {
        return 'Inactive';
      }
    } catch (e) {
      return 'Inactive';
    }
  }

  String apiUrl =
      'https://ifu5tf7mu2.execute-api.us-east-1.amazonaws.com/default/bee-audio-download?deviceid=01&startdate=16-08-2024&enddate=16-08-2024';

  Future<void> downloadFile() async {
    setState(() {
      _isDownloading = true; // Set loading state to true
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final downloadUrl = responseData['download_url'];

        final anchor = html.AnchorElement(href: downloadUrl)
          ..setAttribute("download", "bee_audio.zip")
          ..click();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download started')),
        );
        print('File downloaded successfully');
      } else {
        print('Failed to create ZIP file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    } finally {
      setState(() {
        _isDownloading = false; // Set loading state to false after completion
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != _selectedDay) {
      setState(() {
        _selectedDay = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download Audio'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    value: _selectedDevice.isNotEmpty ? _selectedDevice : null,
                    hint: Text('Select Device'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDevice = newValue!;
                        final selectedDevice = devices.firstWhere(
                            (device) => device['deviceId'] == _selectedDevice,
                            orElse: () => {});
                        _updateDeviceDetails(selectedDevice);
                      });
                    },
                    items: devices.map<DropdownMenuItem<String>>((device) {
                      return DropdownMenuItem<String>(
                        value: device['deviceId'],
                        child: Text(device['deviceId']),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Device ID:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Current Status:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Data Received Time:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(_selectedDevice)),
                      Expanded(child: Text(_currentStatus)),
                      Expanded(child: Text(_dataReceivedTime)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _selectDate,
                  child: Text(
                      'Select Date: ${_selectedDay.toLocal().toIso8601String().split('T')[0]}'),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isDownloading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: downloadFile,
                        child: Text('Download ZIP'),
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
  final String birdId;
  final String confidence;

  ApiData({
    required this.timestamp,
    required this.birdId,
    required this.confidence,
  });

  factory ApiData.fromJson(Map<String, dynamic> json) {
    return ApiData(
      timestamp: json['timestamp'],
      birdId: json['birdId'],
      confidence: json['confidence'],
    );
  }
}
