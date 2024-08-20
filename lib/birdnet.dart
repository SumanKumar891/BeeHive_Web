import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'dart:convert';

class BirdNet extends StatefulWidget {
  final String deviceId;

  const BirdNet({Key? key, required this.deviceId}) : super(key: key);

  @override
  State<BirdNet> createState() => _BirdNetState();
}

class _BirdNetState extends State<BirdNet> {
  List<dynamic> devices = [];
  String _selectedDevice = '';
  String _currentStatus = 'Loading';
  String _dataReceivedTime = 'Loading';
  DateTime? selectedDate;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _fetchDevicesList();
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

  Future<void> downloadFile() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date first')),
      );
      return;
    }
    final cutoffDate = DateTime(2024, 8, 16);
    final deviceId = selectedDate!.isBefore(cutoffDate) ? '1' : '01';
    String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate!);

    String apiUrl =
        'https://ifu5tf7mu2.execute-api.us-east-1.amazonaws.com/default/bee-audio-download?deviceid=$deviceId&startdate=$formattedDate&enddate=$formattedDate';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final downloadUrl = responseData['download_url'];

        if (await canLaunch(downloadUrl)) {
          await launch(downloadUrl);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download started')),
          );
          print('File downloaded successfully');
        } else {
          print('Could not launch $downloadUrl');
        }
      } else {
        print('Failed to create ZIP file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
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
                  onPressed: () => _selectDate(context),
                  child: Text(
                    selectedDate == null
                        ? 'Select Date'
                        : 'Selected Date: ${DateFormat('dd-MM-yyyy').format(selectedDate!)}',
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
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
