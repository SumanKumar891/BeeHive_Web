//Using Flutter version 3.22.2
import 'dart:async';
import 'dart:typed_data';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syngenta/mapfullscrn.dart';
import 'birdtunes.dart';
import 'package:archive/archive.dart';

import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'check_permission.dart';
import 'directory_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syngenta/firstpage.dart';
import 'constant.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'images_fullscrn4.dart';
import 'insect_fullscreen3.dart';
import 'lightintent_full2.dart';
import 'temp_fullscreen.dart';

class HomePage extends StatefulWidget {
  final String email;

  const HomePage({
    super.key,
    required this.email,
  });

  @override
  State<HomePage> createState() => _HomeScreenState();
}

List<apiData> chartData = [];
List<apiData> chartData1 = [];
List<apiData> chartData2 = [];
List<apiData> chartData3 = [];

class _HomeScreenState extends State<HomePage> {
  late Future<String> response;
  late VideoPlayerController _controller;
  bool _isControllerInitialized = false;

  late TextEditingController _serialId;
  late TextEditingController _securityKey;
  //late TextEditingController _searchController;
  late TextEditingController dateController;
  late TextEditingController timeinput;
  late String result;
  void selectedCountry = "";
  late int sleepDuration = 0;
  late TooltipBehavior _tooltipBehavior;
  late DateTime _startDate;
  late DateTime _endDate;
  late String deviceId;
  List<dynamic> data = [];
  late String csvString = " ";
  String errorMessage = '';
  late String Class = " ";
  late int? count = 0;
  String? _selectedSubItem;
  var checkAllPermission = CheckPermission();
  var getDirectoryPath = DirectoryPath();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  TextEditingController _searchController = TextEditingController();
  List<Device> filteredDeviceData = [];
  List<Device> activeDeviceData = [];
  List<Device> inactiveDeviceData = [];
  List<String> imageUrls = [];
  String _currentTime = '';
  List<String> _subItems = [];
  void _updateTime() {
    final DateTime now = DateTime.now();
    final DateFormat formatter =
        DateFormat('yyyy-MM-dd HH:mm:ss'); // Format for date and time
    setState(() {
      _currentTime = formatter.format(now);
    });
  }

  /*Future<void> _downloadAllImagesAsZip() async {                //code for downloading zip file of images
  final archive = Archive();

  for (String url in imageUrls) {
    // Fetch the image
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Add the image to the archive
      final filename = url.split('/').last;
      archive.addFile(ArchiveFile(
        filename,
        response.bodyBytes.length,
        response.bodyBytes,
      ));
    } else {
      print('Failed to download image: $url');
    }
  }

  // Encode the archive as a ZIP file
  final zipEncoder = ZipEncoder();
  final zipData = zipEncoder.encode(archive);

  if (zipData != null) {
    // Create a blob URL for the ZIP file
    final blob = html.Blob([zipData]);
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);

    // Create an anchor element for download
    final anchorElement = html.AnchorElement(href: blobUrl)
      ..setAttribute('download', 'images.zip')
      ..click();

    // Revoke the blob URL
    html.Url.revokeObjectUrl(blobUrl);
  } else {
    print('Failed to create ZIP file.');
  }
}*/
  void _downloadAllImagesaszip() async {
    //code for downloading zip file of images
    final archive = Archive();

    for (String url in imageUrls) {
      // Fetch the image
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Add the image to the archive
        final filename = url.split('/').last;
        final fileBytes = response.bodyBytes;
        final archiveFile =
            ArchiveFile.noCompress(filename, fileBytes.length, fileBytes);
        archive.addFile(archiveFile);
      } else {
        print('Failed to download image: $url');
      }
    }

    // Encode the archive to zip format
    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);

    // Convert the zip data to Uint8List
    final zipBytes = Uint8List.fromList(zipData!);

    // Create a blob URL for the zip file
    final blob = html.Blob([zipBytes]);
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);

    // Create an anchor element for download
    final anchorElement = html.AnchorElement(href: blobUrl)
      ..setAttribute('download', 'images.zip')
      ..click();

    // Revoke the blob URL
    html.Url.revokeObjectUrl(blobUrl);
  }

/*void _downloadAllImages() async {             //code for downloading images seperately one by one
    for (String url in imageUrls) {
      // Fetch the image
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Create a blob URL for the image
        final blob = html.Blob([response.bodyBytes]);
        final blobUrl = html.Url.createObjectUrlFromBlob(blob);

        // Create an anchor element for download
        final anchorElement = html.AnchorElement(href: blobUrl)
          ..setAttribute('download', url.split('/').last)
          ..click();

        // Revoke the blob URL
        html.Url.revokeObjectUrl(blobUrl);
      } else {
        print('Failed to download image: $url');
      }
    }
  }*/
  void _downloadAllurl() {
    //for downloading urls of images
    // Generate text file content with total count and image URLs
    int totalCount = imageUrls.length;
    String concatenatedUrls = imageUrls.join('\n');
    String fileContent = 'Total Images: $totalCount\n$concatenatedUrls';

    // Encode content as UTF-8
    List<int> encodedContent = utf8.encode(fileContent);

    // Create blob URL for download
    String blobUrl = 'data:application/octet-stream;charset=utf-8;base64,' +
        base64Encode(encodedContent);

    // Create anchor element for download
    html.AnchorElement anchorElement = html.AnchorElement(href: blobUrl)
      ..setAttribute('download', 'images.txt');

    // Trigger download
    anchorElement.click();
  }

  bool _hovering = false;
  bool condition = false;
  // DateTime today = DateTime.now();
  // void _onDaySelected(DateTime day, DateTime focusedDay) {
  // setState(() {
  // today = day;
  // });
  // }
  @override
  void initState() {
    response = getData(widget.email);
    _serialId = TextEditingController();
    _securityKey = TextEditingController();
    dateController = TextEditingController();
    timeinput = TextEditingController();
    _startDate = DateTime.parse(DateTime.now().toString());
    _endDate = DateTime.parse(DateTime.now().toString());

    _searchController.addListener(_filterDevices);
    super.initState();
    _updateTime();
    Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });
    /*_controller = VideoPlayerController.asset('assets/bird.mp4')
      ..initialize().then((_) {
        setState(() {
          _isControllerInitialized = true;
        });
        _controller.play();
        _controller.setLooping(true);
      }).catchError((error) {
        print("Error initializing video player: $error");
      });*/
  }

  @override
  void dispose() {
    _serialId.dispose();
    _securityKey.dispose();

    _searchController.dispose();
    super.dispose();
    _controller.dispose();
    super.dispose();
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

  final Map<String, dynamic> countryDeviceIds = {
    // 'All Devices':deviceData.map((device) => device.deviceId).toList(),
    'Germany': {
      '(Deployment 2023)': ['D0315', 'D0318'],
      '(BioMonitor 4-CAP June-2024)': ['69', '71', '78', '84', '85'],
      '(NaPa/LivinGro/University of Bonn)': [
        '67',
        '68',
        '73',
        '74',
        '75',
        '76',
        '82'
      ]
    },
    'Switzerland': {
      '(Deployment 2023)': ['44', '26'],
    },
    'Spain': {
      '(Deployment 2023)': ['D1003', 'D1004', 'D1005'],
    },
    'France': {
      '(Deployment 2023)': [
        'D0500',
        'D0501',
        'D0502',
        'D0503',
        'D0504',
        'D0505'
      ],
    },
    'UK': {
      '(Deployment 2023)': ['02', '05', '04'],
      '(Sandringham)': ['112', '114', '115']
    },
    'USA': {
      '(Deployment 2023)': ['02', '05', '04', '06']
    },
    'India': {
      '(Deployment 2023)': ['07', '08', '09', '11', '12', 'S1', 'S2', '10'],
    },
    'Lab': {
      '(Deployment 2023)': [
        'bf',
        '22',
        '15',
        '16',
        'S4',
        'S23',
        'S21',
        'S11',
        'S14'
      ],
    },
    'Australia': {
      '(Syngenta AU / University of S. Queensland - canola)': [
        '46',
        '47',
        '48',
        '49',
        '50',
        '51',
        '52',
        '53'
      ],
    },
  };
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
        chartData.add(apiData.fromJson(i, count));
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

  Future<void> getbatteryData(String deviceId, DateTime _startDate,
      TimeOfDay _startTime, DateTime _endDate, TimeOfDay _endTime) async {
    final response = await http.get(Uri.https(
      '19b0idkyba.execute-api.us-east-1.amazonaws.com',
      '/default/battery_percentage_1',
      {
        'deviceid': _selectedDeviceId,
        'start_timestamp': _startDate.day.toString() +
            "-" +
            _startDate.month.toString() +
            "-" +
            _startDate.year.toString() +
            "_" +
            _startTime.hour.toString() +
            "-" +
            _startTime.minute.toString(),
        'end_timestamp': _endDate.day.toString() +
            "-" +
            _endDate.month.toString() +
            "-" +
            _endDate.year.toString() +
            "_" +
            _endTime.hour.toString() +
            "-" +
            _endTime.minute.toString(),
      },
    ));

    var data = jsonDecode(response.body.toString());
    if (response.statusCode == 200) {
      for (dynamic i in data) {
        chartData.add(apiData.fromJson(i, count));
      }
      setState(() {});
    } else if (response.statusCode == 400 ||
        response.statusCode == 404 ||
        response.statusCode == 500) {
      setState(() {
        errorMessage = data['message'];
      });
    } else {
      throw Exception('Failed to load api');
    }
  }

  Future<void> getinsectData(
      String deviceId, DateTime _startDate, DateTime _endDate) async {
    final response = deviceId.startsWith('D')
        ? await http.get(Uri.https(
            'd2wa2msynb.execute-api.us-east-1.amazonaws.com',
            '/inference/inferenced_data',
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
          ))
        : await http.get(Uri.https(
            'ynm2l0r0di.execute-api.us-east-1.amazonaws.com',
            '/Data/inferenced_data',
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
    // print(response.body);
    final Map<String, dynamic> jsonDataMap =
        Map<String, dynamic>.from(json.decode(response.body));

    final List<Map<String, dynamic>> jsonData = [jsonDataMap];
    List<List<dynamic>> csvData = [
      [
        "TimeStamp",
        "DeviceId",
        "APISME",
        "BOMUTE",
        "OSMACO",
      ]
    ];

    List<dynamic> row = [];
    List<dynamic> test = jsonData[0]["body"];
    int len = test.length;
    // print("Data: ${len}");

    for (int i = 0; i < len; i++) {
      row = [];
      row.add(jsonData[0]["body"][i]['TimeStamp']);
      row.add(jsonData[0]["body"][i]['DeviceId']);
      // row.add(jsonData[0]["body"][i]['Predictions']);
      // row.add(jsonData[0]["body"][i]['Mean']);
      final predictions = json.decode(jsonData[0]["body"][i]['Predictions']);
      if (predictions != null && predictions['APISME'] != null) {
        row.add(predictions['APISME']);
      } else {
        row.add("");
      }
      final predictions1 = json.decode(jsonData[0]["body"][i]['Predictions']);
      if (predictions1 != null && predictions1['BOMUTE'] != null) {
        row.add(predictions1['BOMUTE']);
      } else {
        row.add("");
      }
      final predictions2 = json.decode(jsonData[0]["body"][i]['Predictions']);
      if (predictions2 != null && predictions2['OSMACO'] != null) {
        row.add(predictions2['OSMACO']);
      } else {
        row.add("");
      }

      csvData.add(row);
    }

    csvString = const ListToCsvConverter().convert(csvData);
    var parsed = jsonDecode(response.body);
    if (parsed['statusCode'] == 200) {
      data = parsed['body'];
      data = parsed['body'];
      chartData2.clear();
      chartData1.clear();
      chartData3.clear();

      for (dynamic i in data) {
        print(i['Predictions'] != '{}');
        if (i['Predictions'] != '{}') {
          print(json.decode(i['Predictions'])['APISME']);
          int? apismeParsedValue = (json.decode(i['Predictions'])['APISME']);
          print('apismeParsedValue:' '$apismeParsedValue');
          if (apismeParsedValue != null) {
            count = apismeParsedValue;
            chartData2.add(apiData.fromJson(i, count));
          }
        }
      }
      for (dynamic i in data) {
        print(i['Predictions'] != '{}');
        if (i['Predictions'] != '{}') {
          print(json.decode(i['Predictions'])['BOMUTE']);
          int? bomuteParsedValue = (json.decode(i['Predictions'])['BOMUTE']);
          print('bomuteParsedValue:' '$bomuteParsedValue');
          if (bomuteParsedValue != null) {
            count = bomuteParsedValue;
            chartData1.add(apiData.fromJson(i, count));
          }
        }
      }
      for (dynamic i in data) {
        print(i['Predictions'] != '{}');
        if (i['Predictions'] != '{}') {
          print(json.decode(i['Predictions'])['OSMACO']);
          int? osmacoParsedValue = (json.decode(i['Predictions'])['OSMACO']);
          print('osmacoParsedValue:' '$osmacoParsedValue');
          if (osmacoParsedValue != null) {
            count = osmacoParsedValue;
            chartData3.add(apiData.fromJson(i, count));
          }
        }
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

  Future<void> fetchImages(String device, DateTime date) async {
    final formattedDate = DateFormat('dd-MM-yyyy').format(date);
    try {
      final response = await http.get(Uri.parse(
          'https://tulp6xq61c.execute-api.us-east-1.amazonaws.com/dep/images?device=$device&date=$formattedDate'));

      if (response.statusCode == 200) {
        final bodyJson = json.decode(response.body);
        final images = json.decode(bodyJson['body'])['images'];
        setState(() {
          imageUrls = List<String>.from(images);
        });
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      print('Error fetching images: $e');
      Fluttertoast.showToast(
        msg: 'Error fetching images',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  void updateData() async {
    await getAPIData(_selectedDeviceId!, _startDate, _endDate);
    await getbatteryData(
        _selectedDeviceId!, _startDate, _startTime, _endDate, _endTime);
    await getinsectData(_selectedDeviceId!, _startDate, _endDate);
    await fetchImages(_selectedDeviceId!, _startDate);
  }

  Future<void> _refreshData() async {
    // Fetch updated images based on the current start date
    await fetchImages(_selectedDeviceId!, _startDate!);
  }

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String? _selectedDeviceId;
  String? _selectedCountry;
  List<String> _deviceIds = [];

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void _openBirdNetDialog(BuildContext context) {
    String enteredDeviceId = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Enter Device ID',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.green,
            ),
          ),
          content: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: TextField(
              onChanged: (value) {
                enteredDeviceId = value;
              },
              decoration: InputDecoration(
                hintText: 'S01',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (enteredDeviceId.isEmpty) {
                  enteredDeviceId = 'S01'; // Default value
                }
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => birdNet(deviceId: enteredDeviceId),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              child: Text('Next'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final String deviceId;
    return new Scaffold(
        appBar: AppBar(
          title: Image.asset(
            "assets/logo.png",
            height: 99.0,
            width: 90,
          ),
          // title:Text("Syngenta overview") ,
          // leading: Container(

          // child: Image.network('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_gvE_VWYIpULD6qdLckef-ChPtzymPNd-oA&s')),
          // leading: Container(
          // child: Text("vansh"),),),
          // child: Image.network('https://bsmedia.business-standard.com/_media/bs/img/article/2020-09/02/full/20200902081814.jpg'),
          //  child: Image(
          // image:AssetImage('assets/logo.png'),)),),

          backgroundColor: Color.fromARGB(255, 152, 207, 158),
          actions: <Widget>[
            ElevatedButton(
                onPressed: () {
                  _openBirdNetDialog(context);
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 40, 43, 40))),
                child: Text(
                  "Bird tunes",
                  style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 198, 112, 13),
                      fontStyle: FontStyle.italic),
                )),
            IconButton(
              icon: Icon(
                Icons.account_circle_outlined,
              ),
              onPressed: () {},
            ),
          ],
        ),
        drawer: Drawer(
          child: Container(
            color: Color.fromARGB(
              255,
              152,
              207,
              158,
            ),
            child: ListView(
              children: [
                DrawerHeader(
                    child: Center(
                  child: Image.asset(
                    "assets/logo.png",
                  ),
                )),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text(
                    "Home",
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => FirstPage()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.dashboard),
                  title: Text(
                    "Dashboard",
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => FirstPage()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.device_hub),
                  title: Text(
                    "Devices",
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => FirstPage()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text(
                    "Settings",
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => FirstPage()));
                  },
                )
              ],
            ),
          ),
        ),
        body: FutureBuilder<String>(
          future: response,
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data == '200') {
                filteredDeviceData = filteredDeviceData.isNotEmpty
                    ? filteredDeviceData
                    : deviceData
                        .where((device) => device.deviceId.length != 5)
                        .toList();
                activeDeviceData = activeDeviceData.isNotEmpty
                    ? activeDeviceData
                    : activeDevice
                        .where((device) => device.deviceId.length != 5)
                        .toList();
                inactiveDeviceData = inactiveDeviceData.isNotEmpty
                    ? inactiveDeviceData
                    : inactiveDevice
                        .where((device) => device.deviceId.length != 5)
                        .toList();
                return SingleChildScrollView(
                  // scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Container(
                        height: 500,
                        width: double.infinity,
                        color: Color.fromARGB(255, 126, 161, 169),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor: Color.fromARGB(
                                        255,
                                        152,
                                        207,
                                        158,
                                      ),
                                      insetPadding: EdgeInsets.all(10),
                                      child: Container(
                                          padding: EdgeInsets.all(10),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.8,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          child: MapPage()),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                //c1
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  color: Color.fromARGB(
                                    255,
                                    152,
                                    207,
                                    158,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 7, 7, 7),
                                      blurRadius: 5.0,
                                      spreadRadius: 1.0,
                                      offset: Offset(0.0, 0.0),
                                    ),
                                  ],
                                ),

                                height: 450,
                                width: (screenWidth * 0.5) - 20,
                                // color: Colors.blue[50],
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(""),
                                    Text(
                                      "All Devices",
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    ).animate().fade(delay: 500.ms).slideX(),
                                    // SizedBox(height: 10,),

                                    Container(
                                      height: 386,
                                      child: FlutterMap(
                                        options: MapOptions(
                                          center: LatLng(20.5937, 78.9629),
                                          zoom: 5.0,
                                        ),
                                        children: [
                                          TileLayer(
                                            urlTemplate:
                                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                            subdomains: ['a', 'b', 'c'],
                                          ),
                                          MarkerLayer(
                                            markers: [
                                              Marker(
                                                width: 80.0,
                                                height: 80.0,
                                                point: LatLng(20.5937, 78.9629),
                                                builder: (ctx) => Container(
                                                  child: Icon(
                                                    Icons.location_on,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                // color: Color.fromARGB(255, 15, 140, 193),
                              ),
                            ),
                            Container(
                              //c2
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
                              margin: EdgeInsets.all(20),
                              height: 450,
                              width: (screenWidth * 0.5) - 20,
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ListView(
                                  children: [
                                    Text('TOTAL DEVICES',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text("${filteredDeviceData.length}"),
                                    SizedBox(height: 16.0),
                                    Text('Indian Standard Time',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text("${_currentTime}"),
                                    SizedBox(height: 16.0),
                                    Text('ACTIVE DEVICES',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text("${activeDeviceData.length}"),
                                    SizedBox(height: 16.0),
                                    Text('ACTIVE DEVICES IDs',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    activeDeviceData.isEmpty
                                        ? Text(
                                            'No Active  Devices',
                                            style: TextStyle(color: Colors.red),
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                                for (int i = 0;
                                                    i < activeDeviceData.length;
                                                    i++)
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: "${i + 1}.   ",
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              activeDeviceData[
                                                                      i]
                                                                  .deviceId,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                              ])
                                  ],
                                ),
                              ),
                              // SizedBox(height: 16.0),

                              // color: Color.fromARGB(255, 85, 146, 15),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 500,
                        width: double.infinity,
                        color: Color.fromARGB(255, 126, 161, 169),
                        child: Row(
                          children: [
                            Container(
                              //container 3 c3

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
                              height: 450,
                              width: (screenWidth * 0.5) - 20,

                              child: Column(
                                children: [
                                  /* TextField(
                     
                decoration: InputDecoration(
                  hintText: 'Type to filter options...',
                  border: OutlineInputBorder(),
                ),
               onChanged: (String? newValue) {
                            setState(() {
                              _deviceIds = newValue as List<String>;
                            });
                          },

              ),
              SizedBox(height: 20.0),
              DropdownButton<String>(
                          
                          value: _selectedDeviceId,
                           onChanged: (String? newValue) {
                            setState(() {
                              deviceData = newValue as List<Device>;
                            });
                          },
items: _deviceIds.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                            );
                          }).toList(),

                        ),*/

                                  /* Expanded(               //for text field searching device Ids
            // width: 200,
            // height: 50,
            // margin: EdgeInsets.only(bottom: 1, top: 5),
            child: TextField(
              controller: _searchConVtroller,
              decoration: InputDecoration(
                hintText: 'Search Device ID',
                fillColor: Colors.transparent,
                hintStyle: TextStyle(color: const Color.fromARGB(255, 210, 64, 64), fontSize: 20),
                filled: true,

                // border: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(10),
                // ),
              ),
              style: TextStyle(
                color: const Color.fromARGB(255, 151, 37, 37), // Change text color here
              ),
            ),
          ),*/
                                  /* Expanded(                         //for showing all devices.(with color red and green)
                     child: DropdownButtonFormField<String>(
                          
                          decoration: InputDecoration(
                            labelText: 'All Devices',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedDeviceId,
                          items: [
                            ...activeDeviceData.map((device) {
                              return DropdownMenuItem<String>(
                                value: device.deviceId,
                                child: Text(
                                  device.deviceId,
                                  style: TextStyle(color: Colors.green)      
                                             ),
                              );
                            }).toList(),
                            ...inactiveDeviceData.map((device) {
                              return DropdownMenuItem<String>(
                                value: device.deviceId,
                                child: Text(
                                  device.deviceId,
                                  style: TextStyle(color: Colors.red),
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
                    ), */
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      //with sub dropdowns
                                      decoration: InputDecoration(
                                        labelText: 'All Devices',
                                        border: OutlineInputBorder(),
                                      ),
                                      value: _selectedDeviceId != null &&
                                              activeDeviceData.any((device) =>
                                                  device.deviceId ==
                                                  _selectedDeviceId)
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
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Select country',
                                        border: OutlineInputBorder(),
                                      ),
                                      value: _selectedCountry,
                                      items: countryDeviceIds.keys
                                          .map((String country) {
                                        return DropdownMenuItem<String>(
                                          value: country,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(country),
                                              if (countryDeviceIds[country]
                                                  is Map<String, List<String>>)
                                                DropdownButton<String>(
                                                  value: _selectedCountry ==
                                                          country
                                                      ? _selectedSubItem
                                                      : null,
                                                  onChanged:
                                                      (String? subValue) {
                                                    setState(() {
                                                      _selectedCountry =
                                                          country;
                                                      _selectedSubItem =
                                                          subValue;
                                                      _deviceIds = List<
                                                              String>.from(
                                                          countryDeviceIds[
                                                                      country]?[
                                                                  _selectedSubItem] ??
                                                              []);
                                                      _selectedDeviceId = null;
                                                    });
                                                  },
                                                  items: (countryDeviceIds[
                                                              country]
                                                          as Map<String,
                                                              List<String>>)
                                                      .keys
                                                      .map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (String subItem) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: subItem,
                                                      child: Text(subItem),
                                                    );
                                                  }).toList(),
                                                ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedCountry = newValue;
                                          _selectedSubItem = null;
                                          _deviceIds = [];
                                          _selectedDeviceId = null;
                                          if (countryDeviceIds[newValue]
                                              is Map<String, List<String>>) {
                                            _subItems =
                                                (countryDeviceIds[newValue]
                                                        as Map<String,
                                                            List<String>>)
                                                    .keys
                                                    .toList();
                                          } else {
                                            _deviceIds = List<String>.from(
                                                countryDeviceIds[newValue] ??
                                                    []);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText:
                                            'Deployed Device Ids (select country)',
                                        border: OutlineInputBorder(),
                                      ),
                                      value:
                                          _deviceIds.contains(_selectedDeviceId)
                                              ? _selectedDeviceId
                                              : null,
                                      items: _deviceIds
                                          .map<DropdownMenuItem<String>>(
                                              (String deviceId) {
                                        return DropdownMenuItem<String>(
                                          value: deviceId,
                                          child: Text(deviceId),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedDeviceId = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                  /* Expanded(
                     child: DropdownButtonFormField<String>(     //for selecting country
                          
                          decoration: InputDecoration(
                            labelText: 'Select country',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedCountry,
                          items: countryDeviceIds.keys.map((String country) {
                            return DropdownMenuItem<String>(
                              value: country,
                              child: Text(country),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCountry = newValue;
                              _deviceIds =countryDeviceIds[newValue]!;
                              _selectedDeviceId=null;
                            });
                          },
                        ),
                      ),
                  
                    Expanded(                                   //country wise devices
                     child: DropdownButtonFormField<String>(
                          
                          decoration: InputDecoration(
                            labelText: 'Deployed Device Ids (select country)',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedDeviceId,
                          items: _deviceIds.map((String deviceId) {
                            return DropdownMenuItem<String>(
                              value: deviceId,
                              child: Text(deviceId),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDeviceId = newValue;
                            });
                          },
                        ),
                    ),*/
                                  Expanded(
                                    child: TextFormField(
                                      onTap: () async {
                                        final DateTime? selectedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate:
                                              _startDate ?? DateTime.now(),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme:
                                                    const ColorScheme.light(
                                                  primary: Colors.green,
                                                  onPrimary: Colors.white,
                                                  onSurface: Colors.purple,
                                                ),
                                                textButtonTheme:
                                                    TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    elevation: 10,
                                                    backgroundColor: Colors
                                                        .black, // button text color
                                                  ),
                                                ),
                                              ),
                                              // child: child!,
                                              child: MediaQuery(
                                                data: MediaQuery.of(context)
                                                    .copyWith(
                                                        alwaysUse24HourFormat:
                                                            true),
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
                                              ? DateFormat('yyyy-MM-dd')
                                                  .format(_startDate)
                                              : ''),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      onTap: () async {
                                        final DateTime? selectedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate:
                                              _endDate ?? DateTime.now(),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme:
                                                    const ColorScheme.light(
                                                  primary: Colors.green,
                                                  onPrimary: Colors.white,
                                                  onSurface: Colors.purple,
                                                ),
                                                textButtonTheme:
                                                    TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    elevation: 10,
                                                    backgroundColor: Colors
                                                        .black, // button text color
                                                  ),
                                                ),
                                              ),
                                              // child: child!,
                                              child: MediaQuery(
                                                data: MediaQuery.of(context)
                                                    .copyWith(
                                                        alwaysUse24HourFormat:
                                                            true),
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
                                              ? DateFormat('yyyy-MM-dd')
                                                  .format(_endDate)
                                              : ''),
                                    ),
                                  ),
                                  Row(children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          updateData();
                                        },
                                        child: Text(
                                          '  Get Data  ',
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255,
                                              207,
                                              235,
                                              176), // Set the button color to green
                                          minimumSize: Size(60,
                                              0), // Set a minimum width for the button
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 24),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: handleDownloadButtonPressed,
                                        child: Text(
                                          'Download CSV',
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255,
                                              207,
                                              235,
                                              176), // Set the button color to green
                                          minimumSize: Size(60,
                                              0), // Set a minimum width for the button
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 24),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                              // color: Color.fromARGB(255, 15, 140, 193),
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      insetPadding: EdgeInsets.all(10),
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: FullScreenChart(
                                            chartData: chartData),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                //c4
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

                                margin: EdgeInsets.all(20),
                                height: 450,
                                width: (screenWidth * 0.5) - 20,
                                child: SfCartesianChart(
                                  plotAreaBackgroundColor: Colors.white,
                                  primaryXAxis: CategoryAxis(
                                    title: AxisTitle(
                                      text: 'Time',
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    labelRotation: 45,
                                  ),
                                  primaryYAxis: NumericAxis(
                                    title: AxisTitle(
                                      text: 'Temperature(°C)',
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    axisLine: AxisLine(width: 0),
                                    majorGridLines: MajorGridLines(width: 0.5),
                                  ),
                                  legend: Legend(
                                    isVisible: true,
                                    position: LegendPosition.bottom,
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
                                      final apiData item =
                                          chartData[pointIndex];
                                      return Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 245, 214, 250),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.purple,
                                                blurRadius: 3)
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                                "TimeStamp: ${item.TimeStamp}"),
                                            Text(
                                                "Temperature: ${item.Temperature}"),
                                            // Text("Class: ${item.Class}"),
                                          ],
                                        ),
                                      );
                                    },
                                    // customize the tooltip color
                                  ),
                                  title: ChartTitle(
                                    text: 'Temperature and  Relative humidity ',
                                    textStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  series: <ChartSeries<apiData, String>>[
                                    LineSeries<apiData, String>(
                                      name: 'Temperature',
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
                                      color: Colors.green,
                                    ),
                                    LineSeries<apiData, String>(
                                      name: 'Relative Humidity',
                                      markerSettings: const MarkerSettings(
                                        height: 3.0,
                                        width: 3.0,
                                        borderColor:
                                            Color.fromARGB(255, 218, 96, 9),
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
                                      color: Color.fromARGB(255, 218, 96, 9),
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
                                // color: Color.fromARGB(255, 85, 146, 15),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 500,
                        width: double.infinity,
                        color: Color.fromARGB(255, 126, 161, 169),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      insetPadding: EdgeInsets.all(10),
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: FullScreenChart2(
                                            chartData: chartData),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                //c5
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
                                height: 450,
                                width: (screenWidth * 0.5) - 20,
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
                                  legend: Legend(
                                    isVisible: true,
                                    position: LegendPosition.bottom,
                                  ),
                                  plotAreaBackgroundColor: Colors.white,
                                  primaryXAxis: CategoryAxis(
                                    title: AxisTitle(
                                      text: 'Time',
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    labelRotation: 45,
                                  ),
                                  primaryYAxis: NumericAxis(
                                    title: AxisTitle(
                                      text: 'Light Intensity(Lux)',
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.bold),
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
                                      final apiData item =
                                          chartData[pointIndex];
                                      return Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 245, 214, 250),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.purple,
                                                blurRadius: 3)
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                                "TimeStamp: ${item.TimeStamp}"),
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
                                    textStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  series: <ChartSeries<apiData, String>>[
                                    LineSeries<apiData, String>(
                                      name: 'Light Intensity',
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
                                      color: Colors.green,
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
                                // color: Color.fromARGB(255, 15, 140, 193),
                              ),
                            ),
                            GestureDetector(
                              //c6 gesture detector
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      insetPadding: EdgeInsets.all(10),
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: FullScreenChart3(
                                            chartData: chartData),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                //c6
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
                                margin: EdgeInsets.all(20),
                                height: 450,
                                width: (screenWidth * 0.5) - 20,
                                child: SfCartesianChart(
                                  // legend: Legend(
                                  // isVisible: false,
                                  // name:legend,
                                  // position: LegendPosition.top,
                                  // offset: const Offset(550, -150),
                                  // title: LegendTitle(
                                  //     text: 'Insect',
                                  //     textStyle: TextStyle(
                                  //         color: Colors.black,
                                  //         fontSize: 15,
                                  //         fontStyle: FontStyle.italic,
                                  //         fontWeight: FontWeight.w900)),
                                  // toggleSeriesVisibility: true,
                                  // Border color and border width of legend
                                  // overflowMode: LegendItemOverflowMode.wrap,
                                  // borderColor: Colors.black,
                                  // borderWidth: 2
                                  // ),
                                  legend: Legend(
                                    isVisible: true,
                                    position: LegendPosition.bottom,
                                  ),
                                  plotAreaBackgroundColor: Colors.white,
                                  primaryXAxis: CategoryAxis(
                                    title: AxisTitle(
                                      text: 'Time',
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    labelRotation: 45,
                                  ),
                                  primaryYAxis: NumericAxis(
                                    title: AxisTitle(
                                      text: 'Insect Count',
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    axisLine: AxisLine(width: 0),
                                    majorGridLines: MajorGridLines(width: 0.5),
                                    interval: 1,
                                  ),
                                  // tooltipBehavior: _tooltipBehavior,
                                  tooltipBehavior: TooltipBehavior(
                                    enable: true,
                                    color: Colors.white,
                                    // textStyle: TextStyle(color: Colors.white),
                                    builder: (dynamic data,
                                        dynamic point,
                                        dynamic series,
                                        int pointIndex,
                                        int seriesIndex) {
                                      final apiData item =
                                          chartData1[pointIndex];
                                      return Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 245, 214, 250),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.purple,
                                                blurRadius: 3)
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                                "TimeStamp: ${item.TimeStamp}"),
                                            Text(
                                                "BOMUTE Count: ${item.Predictions}"),
                                            Text(
                                                "APISME Count: ${item.Predictions}"),
                                            Text(
                                                "OSMACO Count: ${item.Predictions}"),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  title: ChartTitle(
                                    text: 'GRAPH FOR INSECT COUNT',
                                    textStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),

                                  series: <ChartSeries<apiData, String>>[
                                    LineSeries<apiData, String>(
                                      name: 'BOMUTE',
                                      markerSettings: const MarkerSettings(
                                        height: 3.0,
                                        width: 3.0,
                                        borderColor: Colors.green,
                                        isVisible: true,
                                      ),
                                      dataSource: chartData1,
                                      xValueMapper: (apiData sales, _) =>
                                          sales.TimeStamp,
                                      yValueMapper: (apiData sales, _) =>
                                          sales.Predictions,
                                      dataLabelSettings:
                                          DataLabelSettings(isVisible: false),
                                      enableTooltip: true,
                                      animationDuration: 0,
                                      color: Colors.green,
                                    ),
                                    LineSeries<apiData, String>(
                                      // Text("Class: ${item.Class}"),
                                      // name: apiData.Class as dynamic,
                                      // name: 'Apis Mellifera',
                                      name: 'APISME',
                                      markerSettings: const MarkerSettings(
                                        height: 3.0,
                                        width: 3.0,
                                        borderColor: Colors.red,
                                        isVisible: true,
                                      ),
                                      dataSource: chartData2,
                                      xValueMapper: (apiData sales, _) =>
                                          sales.TimeStamp,
                                      yValueMapper: (apiData sales, _) =>
                                          sales.Predictions,

                                      dataLabelSettings:
                                          DataLabelSettings(isVisible: false),
                                      enableTooltip: true,
                                      animationDuration: 0,
                                      color: Colors.red,
                                    ),
                                    LineSeries<apiData, String>(
                                      // Text("Class: ${item.Class}"),
                                      // name: apiData.Class as dynamic,
                                      // name: 'Apis Mellifera',
                                      name: 'OSMACO',
                                      markerSettings: const MarkerSettings(
                                        height: 3.0,
                                        width: 3.0,
                                        borderColor: Colors.blue,
                                        isVisible: true,
                                      ),
                                      dataSource: chartData3,
                                      xValueMapper: (apiData sales, _) =>
                                          sales.TimeStamp,
                                      yValueMapper: (apiData sales, _) =>
                                          sales.Predictions,
                                      // yValueMapper: (apiData sales, _) {
                                      //   final apismeValue = sales.Predictions["APISME"];
                                      //   print("APISME Value: $apismeValue");
                                      //   return apismeValue != null
                                      //       ? int.parse(apismeValue)
                                      //       : 0;
                                      // },

                                      // double.parse(sales.Predictions['OSMACO'].toString()),
                                      // name: ((apiData sales, _) => sales.TimeStamp) [0],
                                      // name: apiData.Class,
                                      // legendItemText: (apiData sales, _) => sales.Class,
                                      dataLabelSettings:
                                          DataLabelSettings(isVisible: false),
                                      enableTooltip: true,
                                      animationDuration: 0,
                                      color: Colors.blue,
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
                                // color: Color.fromARGB(255, 85, 146, 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        //c7 main
                        height: 500,
                        width: double.infinity,
                        color: Color.fromARGB(255, 126, 161, 169),
                        child: Row(
                          children: [
                            // Container(
                            // height: 20,
                            // width: (screenWidth* 0.5)-20 ,
                            // ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      insetPadding: EdgeInsets.all(10),
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: FullScreenChart4(
                                            imageUrls: imageUrls),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                //c7

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

                                height: 450,
                                width: (screenWidth * 0.5) - 20,

                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "IMAGES",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(""),
                                      Row(children: [
                                        Expanded(
                                          child: Text(
                                            'Total Images: ${imageUrls.length}',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: _refreshData,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromARGB(
                                                  255,
                                                  207,
                                                  235,
                                                  176), // Set button's background color to blue
                                            ),
                                            icon: Icon(Icons
                                                .refresh), // Add refresh icon
                                            label: Text('Get images'),
                                          ),
                                        ),
                                      ]),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: imageUrls.length,
                                          itemBuilder: (context, index) {
                                            // Calculate the reversed index
                                            int reversedIndex =
                                                imageUrls.length - 1 - index;
                                            return ListTile(
                                              title: Image.network(
                                                  imageUrls[reversedIndex]),
                                            );
                                          },
                                        ),
                                      ),
                                      Row(children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                _downloadAllImagesaszip(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromARGB(
                                                  255, 207, 235, 176),
                                              // Set button's background color to green
                                            ),
                                            child: Text('Download Images'),
                                          ),
                                        ),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _downloadAllurl(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromARGB(
                                                  255, 207, 235, 176),
                                              // Set button's background color to green
                                            ),
                                            child: Text('Links for Images'),
                                          ),
                                        ),
                                      ]),
                                    ]),
                                // color: Color.fromARGB(255, 15, 140, 193),
                              ),
                            ),
                            Container(
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
                              margin: EdgeInsets.all(20),
                              height: 450,
                              width: (screenWidth * 0.5) - 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Feedback',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: TextField(
                                      maxLines: 6,
                                      decoration: InputDecoration(
                                        hintText: 'Enter your feedback here',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Handle feedback submission
                                      },
                                      child: Text('Submit'),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }
              return Container();
            } else if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}'),
              );
            }
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }),
        ));
  }
}

class apiData {
  apiData(this.TimeStamp, this.Light_intensity, this.Temperature,
      this.Relative_Humidity, this.battery_percentage, this.Predictions);

  final String TimeStamp;
  final String Light_intensity;
  final String Temperature;
  final String Relative_Humidity;
  final String battery_percentage;
  final int Predictions;

  factory apiData.fromJson(dynamic parsedJson, count) {
    return apiData(
      parsedJson['TimeStamp'].toString(),
      parsedJson['Light_intensity(Lux)'].toString(),
      parsedJson['Temperature(C)'].toString(),
      parsedJson['Relative_Humidity(%)'].toString(),
      parsedJson['battery_percentage'].toString(),
      count,
    );
  }
}
