import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BeeActivityPage extends StatefulWidget {
  @override
  _BeeActivityPageState createState() => _BeeActivityPageState();
}

class _BeeActivityPageState extends State<BeeActivityPage> {
  late Future<Map<String, dynamic>> _beeData;
  String _selectedDevice = 'Device 1'; // Default selected device
  bool _dataVisible = false; // To control visibility of the data
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

        // Check if data is empty and return static data if necessary
        if (data == null || data.isEmpty) {
          return _getStaticData();
        } else {
          return data; // Data from API
        }
      } else {
        // Handle the error case or return static data
        return _getStaticData();
      }
    } catch (error) {
      // Handle the error case or return static data
      return _getStaticData();
    }
  }

  Map<String, dynamic> _getStaticData() {
    return {
      'queenBeeStatus':
          'The queen bee is healthy and active. Egg-laying rate is high.',
      'beeFrequency': 'Bees visit the hive approximately 8000 times a day.',
      'calendar': 'Calendar data not available.', // Static data for calendar
      'devices': [
        {
          'deviceId': 'Device 1',
          'status': 'Active',
          'lastActive': '2024-08-15'
        },
        {
          'deviceId': 'Device 2',
          'status': 'Inactive',
          'lastActive': '2024-08-14'
        },
        {'deviceId': 'Device 3', 'status': 'Active', 'lastActive': '2024-08-13'}
      ]
    };
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
      _dataVisible = true; // Show the data after selecting a date
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

            // Extract device data
            final devices = data['devices'] as List<dynamic>;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown for device selection
                  DropdownButton<String>(
                    value: _selectedDevice,
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
                  SizedBox(height: 16),

                  // Display selected device details
                  _buildDeviceDetails(devices),

                  SizedBox(height: 24),

                  // Calendar
                  Text(
                    'Calendar:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
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

                  // Queen Bee Status and Bee Frequency (shown only after a date is selected)
                  if (_dataVisible) ...[
                    Text(
                      'Queen Bee Status:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      data['queenBeeStatus'] ?? 'No data available.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Bee Frequency Per Day:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      data['beeFrequency'] ?? 'No data available.',
                      style: TextStyle(fontSize: 16),
                    ),
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
        orElse: () => {
              'deviceId': 'Unknown',
              'status': 'Unknown',
              'lastActive': 'Unknown'
            });

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
                'Last Active Time:',
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
            Expanded(child: Text(selectedDevice['status'])),
            Expanded(child: Text(selectedDevice['lastActive'])),
          ],
        ),
      ],
    );
  }
}
