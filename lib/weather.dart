import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<ChartData> hiveTempData = [];
  List<ChartData> gustSpeedData = [];
  List<ChartData> weatherHumidityData = [];
  List<ChartData> cloudCoverageData = [];
  List<ChartData> hiveHumidityData = [];
  List<ChartData> weatherPressureData = [];
  List<ChartData> rainData = [];
  List<ChartData> weatherTempData = [];
  List<ChartData> windSpeedData = [];
  List<dynamic> devices = [];
  String _selectedDevice = '';
  String _currentStatus = 'Unknown';
  String _dataReceivedTime = 'Unknown';

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
          fetchData(); // Fetch data with the default selected device
        }
      });
    } else {
      throw Exception('Failed to load devices');
    }
  }

  Future<void> fetchData() async {
    if (_selectedDevice.isEmpty) return;

    // Internal Weather Data
    final internalResponse = await http.get(Uri.parse(
        'https://n2rgan0jj5.execute-api.us-west-2.amazonaws.com/default/beehive-api?deviceid=$_selectedDevice&startdate=${_selectedDay.toLocal().toIso8601String().split('T')[0]}&enddate=${_selectedDay.toLocal().toIso8601String().split('T')[0]}'));

    // External Weather Data
    final externalResponse = await http.get(Uri.parse(
        'https://ixzeyfcuw5.execute-api.us-east-1.amazonaws.com/default/weather_station_awadh_api?deviceid=$_selectedDevice&startdate=${_selectedDay.toLocal().toIso8601String().split('T')[0]}&enddate=${_selectedDay.toLocal().toIso8601String().split('T')[0]}'));

    if (internalResponse.statusCode == 200 &&
        externalResponse.statusCode == 200) {
      List<dynamic> internalData = json.decode(internalResponse.body);
      List<dynamic> externalData = json.decode(externalResponse.body);

      setState(() {
        hiveTempData = internalData
            .map((item) => ChartData.fromJson(item, 'hive_temp'))
            .toList();
        hiveHumidityData = internalData
            .map((item) => ChartData.fromJson(item, 'hive_humidity'))
            .toList();

        gustSpeedData = externalData
            .map((item) => ChartData.fromJson(item, 'gust_speed'))
            .toList();
        weatherHumidityData = externalData
            .map((item) => ChartData.fromJson(item, 'weather_humidity'))
            .toList();
        cloudCoverageData = externalData
            .map((item) => ChartData.fromJson(item, 'cloud_coverage'))
            .toList();
        weatherPressureData = externalData
            .map((item) => ChartData.fromJson(item, 'weather_pressure'))
            .toList();
        rainData = externalData
            .map((item) => ChartData.fromJson(item, 'rain'))
            .toList();
        weatherTempData = externalData
            .map((item) => ChartData.fromJson(item, 'weather_temp'))
            .toList();
        windSpeedData = externalData
            .map((item) => ChartData.fromJson(item, 'wind_speed'))
            .toList();
      });
    } else {
      throw Exception('Failed to load data');
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(1970),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != _selectedDay) {
      setState(() {
        _selectedDay = picked;
        fetchData(); // Fetch data for the selected date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Data'),
      ),
      body: Column(
        children: [
          // Dropdown for Device Selection
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                      fetchData(); // Fetch data for the new device
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
                // Device Details
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
          // Date Picker Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectDate,
              child: Text(
                  'Select Date: ${_selectedDay.toLocal().toIso8601String().split('T')[0]}'),
            ),
          ),
          // Row for Internal and External Weather Sections
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Internal Weather Section
                  Expanded(
                    child: SingleChildScrollView(
                      child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Internal Weather',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text('Temperature: XX°C'),
                              Text('Humidity: XX%'),
                              // Text('Air Quality: Good'),
                              SizedBox(height: 20),
                              // Increased container height
                              Container(
                                height: 300, // Adjust height as needed
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    _buildChartContainer('Hive Temperature',
                                        hiveTempData, 'Temperature(°C)'),
                                    _buildChartContainer('Hive Humidity',
                                        hiveHumidityData, 'Humidity(%)'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // External Weather Section
                  Expanded(
                    child: SingleChildScrollView(
                      child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'External Weather',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text('Light Intensity : XXLux'),
                              Text('Temperature: XX°C'),
                              Text('Humidity: XX%'),
                              // Text('Wind Speed: XX km/h'),
                              SizedBox(height: 20),
                              // Increased container height
                              Container(
                                height: 300, // Adjust height as needed
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    _buildChartContainer('Gust Speed',
                                        gustSpeedData, 'Speed(m/s)'),
                                    _buildChartContainer('Weather Humidity',
                                        weatherHumidityData, 'Humidity(%)'),
                                    _buildChartContainer('Cloud Coverage',
                                        cloudCoverageData, 'Coverage(%)'),
                                    _buildChartContainer('Weather Pressure',
                                        weatherPressureData, 'Pressure(hPa)'),
                                    _buildChartContainer(
                                        'Rain', rainData, 'Rain(mm)'),
                                    _buildChartContainer('Weather Temperature',
                                        weatherTempData, 'Temperature(°C)'),
                                    _buildChartContainer('Wind Speed',
                                        windSpeedData, 'Speed(m/s)'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer(
      String title, List<ChartData> data, String yAxisTitle) {
    return Container(
      height: 400,
      margin: EdgeInsets.all(10),
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
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          labelRotation: 45,
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(
            text: yAxisTitle,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          axisLine: AxisLine(width: 0),
          majorGridLines: MajorGridLines(width: 0.5),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
              int seriesIndex) {
            final ChartData chartData = data as ChartData;
            return Container(
              padding: EdgeInsets.all(8),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${chartData.date}'),
                  Text('Value: ${chartData.value}'),
                ],
              ),
            );
          },
        ),
        series: <ChartSeries<ChartData, String>>[
          LineSeries<ChartData, String>(
            dataSource: data,
            xValueMapper: (ChartData data, _) => data.date,
            yValueMapper: (ChartData data, _) => data.value,
            name: title,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String date;
  final double value;

  ChartData({required this.date, required this.value});

  factory ChartData.fromJson(Map<String, dynamic> json, String type) {
    return ChartData(
      date: json['date'] ?? '',
      value: json[type] != null ? double.parse(json[type].toString()) : 0.0,
    );
  }
}
