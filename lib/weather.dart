import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  DateTime _selectedDay = DateTime.now();
  List<ChartData> hiveTempData = [];
  List<ChartData> gustSpeedData = [];
  List<ChartData> HumidityData = [];
  List<ChartData> cloudCoverageData = [];
  List<ChartData> hiveHumidityData = [];
  List<ChartData> lightintensity = [];
  List<ChartData> rainData = [];
  List<ChartData> TemperatureData = [];
  List<ChartData> windSpeedData = [];
  List<dynamic> devices = [];
  String _selectedDevice = '';
  String _currentStatus = 'Unknown';
  String _dataReceivedTime = 'Unknown';

  @override
  void initState() {
    super.initState();
    _fetchDevicesList();
    fetchData();
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
    final startDate = _formatDate(_selectedDay);
    final endDate = startDate;

    // Internal device ID
    final internalDeviceId = '1';
    // External device ID
    final externalDeviceId = '202';

    // Fetch internal data
    final internalResponse = await http.get(Uri.parse(
        'https://5gdhg1ja9d.execute-api.us-east-1.amazonaws.com/default/beehive_weather?deviceid=$internalDeviceId&startdate=$startDate&enddate=$endDate'));

    // Fetch external data
    final externalResponse = await http.get(Uri.parse(
        'https://ixzeyfcuw5.execute-api.us-east-1.amazonaws.com/default/weather_station_awadh_api?deviceid=$externalDeviceId&startdate=$startDate&enddate=$endDate'));

    if (internalResponse.statusCode == 200 &&
        externalResponse.statusCode == 200) {
      try {
        final internalData = json.decode(internalResponse.body);
        final externalData = json.decode(externalResponse.body);
        setState(() {
          hiveTempData = _parseChartData(internalData, 'Temperature');
          hiveHumidityData = _parseChartData(internalData, 'Relative_Humidity');
          gustSpeedData = _parseChartData(externalData, 'gust_speed');
          HumidityData = _parseChartData(externalData, 'humidity');
          cloudCoverageData = _parseChartData(externalData, 'cloud_coverage');
          lightintensity = _parseChartData(externalData, 'light_intensity');
          rainData = _parseChartData(externalData, 'rain');
          TemperatureData = _parseChartData(externalData, 'temperature');
          windSpeedData = _parseChartData(externalData, 'wind_speed');
        });
      } catch (e) {
        print('Error parsing response: $e');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<ChartData> _parseChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? []; // Adjusted to use 'items'
    return items.map((item) => ChartData.fromJson(item, type)).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
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
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != _selectedDay) {
      setState(() {
        _selectedDay = picked;
        fetchData(); // Fetch data for the selected date
      });
    }
  }

  double _calculateAverageTemperature() {
    if (hiveTempData.isEmpty) return 0;
    return hiveTempData.map((data) => data.value).reduce((a, b) => a + b) /
        hiveTempData.length;
  }

  double _calculateAverageHumidity() {
    if (hiveHumidityData.isEmpty) return 0;
    return hiveHumidityData.map((data) => data.value).reduce((a, b) => a + b) /
        hiveHumidityData.length;
  }

  double _calculateMinTemperature() {
    return hiveTempData.isNotEmpty
        ? hiveTempData.map((e) => e.value).reduce((a, b) => a < b ? a : b)
        : 0.0;
  }

  double _calculateMaxTemperature() {
    return hiveTempData.isNotEmpty
        ? hiveTempData.map((e) => e.value).reduce((a, b) => a > b ? a : b)
        : 0.0;
  }

  double _calculateMinHumidity() {
    return hiveHumidityData.isNotEmpty
        ? hiveHumidityData.map((e) => e.value).reduce((a, b) => a < b ? a : b)
        : 0.0;
  }

  double _calculateMaxHumidity() {
    return hiveHumidityData.isNotEmpty
        ? hiveHumidityData.map((e) => e.value).reduce((a, b) => a > b ? a : b)
        : 0.0;
  }

  double _calculateExternalAverageTemperature() {
    return TemperatureData.isNotEmpty
        ? TemperatureData.map((e) => e.value).reduce((a, b) => a + b) /
            TemperatureData.length
        : 0.0;
  }

  double _calculateExternalAveragelux() {
    return lightintensity.isNotEmpty
        ? lightintensity.map((e) => e.value).reduce((a, b) => a + b) /
            lightintensity.length
        : 0.0;
  }

  double _calculateExternalAverageHumidity() {
    return HumidityData.isNotEmpty
        ? HumidityData.map((e) => e.value).reduce((a, b) => a + b) /
            HumidityData.length
        : 0.0;
  }

  double _calculateExternalMinTemperature() {
    return TemperatureData.isNotEmpty
        ? TemperatureData.map((e) => e.value).reduce((a, b) => a < b ? a : b)
        : 0.0;
  }

  double _calculateExternalMaxTemperature() {
    return TemperatureData.isNotEmpty
        ? TemperatureData.map((e) => e.value).reduce((a, b) => a > b ? a : b)
        : 0.0;
  }

  double _calculateExternalMinHumidity() {
    return HumidityData.isNotEmpty
        ? HumidityData.map((e) => e.value).reduce((a, b) => a < b ? a : b)
        : 0.0;
  }

  double _calculateExternalMaxHumidity() {
    return HumidityData.isNotEmpty
        ? HumidityData.map((e) => e.value).reduce((a, b) => a > b ? a : b)
        : 0.0;
  }

  double _calculateExternalMinlux() {
    return lightintensity.isNotEmpty
        ? lightintensity.map((e) => e.value).reduce((a, b) => a < b ? a : b)
        : 0.0;
  }

  double _calculateExternalMaxlux() {
    return lightintensity.isNotEmpty
        ? lightintensity.map((e) => e.value).reduce((a, b) => a > b ? a : b)
        : 0.0;
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
                              Text(
                                  'Average Temperature: ${_calculateAverageTemperature().toStringAsFixed(2)}°C'),
                              Text(
                                  'Minimum Temperature: ${_calculateMinTemperature().toStringAsFixed(2)}°C'),
                              Text(
                                  'Maximum Temperature: ${_calculateMaxTemperature().toStringAsFixed(2)}°C'),
                              SizedBox(height: 10),
                              Text(
                                  'Average Humidity: ${_calculateAverageHumidity().toStringAsFixed(2)}%'),
                              Text(
                                  'Minimum Humidity: ${_calculateMinHumidity().toStringAsFixed(2)}%'),
                              Text(
                                  'Maximum Humidity: ${_calculateMaxHumidity().toStringAsFixed(2)}%'),
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
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                        'Average Temperature: ${_calculateExternalAverageTemperature().toStringAsFixed(2)}°C\nMinimum Temperature: ${_calculateExternalMinTemperature().toStringAsFixed(2)}°C\nMaximum Temperature: ${_calculateExternalMaxTemperature().toStringAsFixed(2)}°C'),
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: Text(
                                        'Average Humidity: ${_calculateExternalAverageHumidity().toStringAsFixed(2)}%\nMinimum Humidity: ${_calculateExternalMinHumidity().toStringAsFixed(2)}%\nMaximum Humidity: ${_calculateExternalMaxHumidity().toStringAsFixed(2)}%'),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                  'Average Light Intensity: ${_calculateExternalAveragelux().toStringAsFixed(2)} Lux'),
                              Text(
                                  'Minimum Light Intensity: ${_calculateExternalMinlux().toStringAsFixed(2)} Lux'),
                              Text(
                                  'Maximum Light Intensity: ${_calculateExternalMaxlux().toStringAsFixed(2)} Lux'),
                              // Text('Wind Speed: XX km/h'),
                              SizedBox(height: 20),
                              // Increased container height
                              Container(
                                height: 300, // Adjust height as needed
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    // _buildChartContainer('Gust Speed',
                                    //     gustSpeedData, 'Speed(m/s)'),
                                    _buildChartContainer('Weather Humidity',
                                        HumidityData, 'Humidity(%)'),
                                    // _buildChartContainer('Cloud Coverage',
                                    //     cloudCoverageData, 'Coverage(%)'),
                                    _buildChartContainer('Weather Pressure',
                                        lightintensity, 'Light Intensity(Lux)'),
                                    // _buildChartContainer(
                                    //     'Rain', rainData, 'Rain(mm)'),
                                    _buildChartContainer('Weather Temperature',
                                        TemperatureData, 'Temperature(°C)'),
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
                  Text('timestamp: ${chartData.timestamp}'),
                  Text('Value: ${chartData.value}'),
                ],
              ),
            );
          },
        ),
        series: <ChartSeries<ChartData, String>>[
          LineSeries<ChartData, String>(
            markerSettings: const MarkerSettings(
              height: 3.0,
              width: 3.0,
              borderColor: Colors.blue,
              isVisible: true,
            ),
            dataSource: data,
            xValueMapper: (ChartData data, _) => data.timestamp,
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
  final String timestamp;

  final double value;

  ChartData({required this.timestamp, required this.value});

  factory ChartData.fromJson(Map<String, dynamic> json, String type) {
    return ChartData(
      timestamp: json['timestamp'] ?? '',
      value: json[type] != null ? double.parse(json[type].toString()) : 0.0,
    );
  }
}
