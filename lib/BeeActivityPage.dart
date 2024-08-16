import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BeeActivityPage extends StatefulWidget {
  @override
  _BeeActivityPageState createState() => _BeeActivityPageState();
}

class _BeeActivityPageState extends State<BeeActivityPage> {
  late Future<Map<String, dynamic>> _beeData;
  String _selectedDevice = ''; // Default selected device
  DateTime? _selectedDate; // To store the selected date

  @override
  void initState() {
    super.initState();
    _beeData = fetchBeeData();
  }

  Future<Map<String, dynamic>> fetchBeeData() async {
    final url =
        'https://c27wvohcuc.execute-api.us-east-1.amazonaws.com/default/beehive_activity_api';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data == null || data.isEmpty) {
          return _getStaticData();
        } else {
          return {
            'queenBeeStatus': 'No data available.',
            'beeFrequency': 'No data available.',
            'calendar': 'Calendar data not available.',
            'devices': data
          };
        }
      } else {
        return _getStaticData();
      }
    } catch (error) {
      return _getStaticData();
    }
  }

  Map<String, dynamic> _getStaticData() {
    return {
      'queenBeeStatus': 'No data available.',
      'beeFrequency': 'No data available.',
      'calendar': 'Calendar data not available.',
      'devices': []
    };
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bee Activity Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _beeData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('An error occurred.'));
          } else {
            final data = snapshot.data!;
            final devices = data['devices'] as List<dynamic>;

            if (_selectedDevice.isEmpty && devices.isNotEmpty) {
              _selectedDevice = devices[0]['deviceId'];
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120, // Set the desired width
                    child: DropdownButtonFormField<String>(
                      value:
                          _selectedDevice.isNotEmpty ? _selectedDevice : null,
                      decoration: InputDecoration(
                        labelText: 'Select Device ID',
                        labelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDevice = newValue!;
                        });
                      },
                      items: devices.map<DropdownMenuItem<String>>((device) {
                        return DropdownMenuItem<String>(
                          value: device['deviceId'],
                          child: Text(device['deviceId']),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildDeviceDetails(devices),
                  SizedBox(height: 24),
                  Text(
                    'Select Date:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 204, 203, 196),
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CalendarDatePicker(
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2025),
                      onDateChanged: _onDateChanged,
                    ),
                  ),
                  SizedBox(height: 24),
                  if (_selectedDate != null) ...[
                    Text(
                      'Queen Bee Status:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _getQueenBeeStatus(),
                      style: TextStyle(fontSize: 16),
                    ),
                    // SizedBox(height: 24),
                    // Text(
                    //   'Bee Frequency Per Day:',
                    //   style:
                    //       TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    // ),
                    // SizedBox(height: 8),
                    // Text(
                    //   data['beeFrequency'] ?? 'No data available.',
                    //   style: TextStyle(fontSize: 16),
                    // ),
                  ],
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDeviceDetails(List<dynamic> devices) {
    final selectedDevice = devices.firstWhere(
        (device) => device['deviceId'] == _selectedDevice,
        orElse: () => {'deviceId': 'Unknown', 'lastReceivedTime': 'Unknown'});

    final currentStatus = _getDeviceStatus(selectedDevice['lastReceivedTime']);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Device ID:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Expanded(
              child: Text(
                'Current Status:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Expanded(
              child: Text(
                'Data Received Time:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(selectedDevice['deviceId'])),
            Expanded(child: Text(currentStatus)),
            Expanded(child: Text(selectedDevice['lastReceivedTime'])),
          ],
        ),
      ],
    );
  }

  String _getDeviceStatus(String lastReceivedTime) {
    // Retain this logic as before
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

  String _getQueenBeeStatus() {
    if (_selectedDate == null) return 'No data available';

    final thresholdDate = DateTime(2024, 8, 13);
    final currentDate = DateTime.now();

    if (_selectedDate!.isBefore(thresholdDate) ||
        _selectedDate!.isAfter(currentDate)) {
      return 'No data available';
    } else {
      return 'Colony maintains its original queen, ensuring stability and productivity.';
    }
  }
}
