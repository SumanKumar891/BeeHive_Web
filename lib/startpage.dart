import 'dart:ui'; // Import for ImageFilter
import 'package:flutter/material.dart';
import 'package:syngenta/homepage.dart';
import 'package:syngenta/weather.dart';
import 'package:syngenta/birdnet.dart';
import 'package:syngenta/BeeActivityPage.dart';

class StartPage extends StatelessWidget {
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
    return Scaffold(
      body: Stack(
        children: [
          // Background image with blur effect
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images.jpg', // Path to your background image
                  fit: BoxFit.cover,
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 5.0, sigmaY: 5.0), // Adjust blur strength
                  child: Container(
                    color: Colors.black.withOpacity(0), // Transparent overlay
                  ),
                ),
              ],
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top image and quote with additional top spacing
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 60.0), // Add top padding here
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: ClipOval(
                              child: Image.asset(
                                "assets/beeee.jpg",
                                width: 270,
                                height: 270,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Center(
                              child: Text(
                                '“If the bee disappeared off the surface of the globe, then man would have only four years of life left. No more bees, no more pollination, no more plants, no more animals, no more man.”',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 35,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 48.0), // Adding top padding to the cards
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCard(
                          title: 'Bee Hive Status',
                          content: 'Four States Of Bees:',
                          icon: Icons.bar_chart_sharp,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => BeeActivityPage()),
                            );
                          },
                          color: Color.fromARGB(255, 144, 212, 243),
                          states: [
                            'Queen Not Present',
                            'Queen Present and Newly Accepted',
                            'Queen Present and Rejected',
                            'Queen Present or Original Queen'
                          ],
                          colors: [
                            Colors.red,
                            Colors.green,
                            Colors.orange,
                            const Color.fromARGB(255, 149, 33, 243)
                          ],
                        ),
                        _buildCard(
                          title: 'Weather',
                          content:
                              'Temperature: 25°C\nHumidity: 60%\nWind Speed: 5 km/h',
                          icon: Icons.wb_sunny,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => Weather()),
                            );
                          },
                          color: Color.fromARGB(255, 236, 137, 137),
                        ),
                        _buildCard(
                          title: 'Download Audio Data',
                          content: '',
                          icon: Icons.download,
                          isButton: true,
                          onPressed: () {
                            _openBirdNetDialog(context);
                          },
                          color: Color.fromARGB(255, 139, 235, 147),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 170.0, right: 170.0, top: 120.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What Will You Get ?',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(235, 0, 0, 0),
                                ),
                              ),
                              SizedBox(height: 16),
                              _buildDescriptionCard(
                                title: 'Bee Activity Monitoring',
                                content:
                                    'Queen Bee Status: You will be able to monitor if queen is present, accepted or\nrejected including the response of colony to a new or original queen and\nany signs of health issues or rejection.\n\nBee Related Activity: Datewise Activity is shown on the calendar.\n\nBee Frequency : You will be able to know the bee frequency per day.',
                                titleFontSize: 20,
                                contentFontSize: 18,
                              ),
                              _buildDescriptionCard(
                                title: 'Weather Data Integration',
                                content:
                                    'Real-Time Weather Updates: The app displays current weather conditions in\nhive such as temperature, humidity, etc to predict or analyse bee activities.\n\nNavigation to Detailed Weather Data: Users can access more detailed weather\ninformation by navigating to a dedicated weather page.',
                                titleFontSize: 20,
                                contentFontSize: 18,
                              ),
                              _buildDescriptionCard(
                                title: 'Audio Data Management',
                                content:
                                    'Download Audio Files: This app allows the users to download audio recordings\nrelated to bee activity directly to their devices.\n\nSearch and Filter: Users can search for specific timestamps to find and\ndownload the corresponding audio files quickly.',
                                titleFontSize: 20,
                                contentFontSize: 18,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 500,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/bee2.jpg'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                      height: 78), // Increased space between content and footer
                  // Footer content included in the scrollable area with background color
                  Container(
                    color: const Color.fromARGB(
                        255, 41, 40, 40), // Dark background color for footer
                    padding: const EdgeInsets.all(16.0),
                    width: double.infinity, // Cover full width
                    child: Column(
                      children: [
                        Text(
                          'Contact Us',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // White text color
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Email: contact.awadh@iitrpr.ac.in',
                          style: TextStyle(
                              color: Colors.white), // White text color
                        ),
                        Text(
                          'Phone: 01881 - 232601',
                          style: TextStyle(
                              color: Colors.white), // White text color
                        ),
                        Text(
                          'Address: IIT Ropar TIF (AWaDH), 214 / M. Visvesvaraya Block, Indian Institute of Technology Ropar, Rupnagar - 140001, Punjab',
                          style: TextStyle(
                              color: Colors.white), // White text color
                        ),
                      ],
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

  Widget _buildCard({
    required String title,
    required String content,
    bool isButton = false,
    VoidCallback? onPressed,
    IconData? icon,
    double width = 380,
    double height = 350,
    Color? color,
    List<String>? states,
    List<Color>? colors,
  }) {
    return Card(
      color: color,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () {
          if (onPressed != null) {
            onPressed();
          }
        },
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, size: 48),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              if (states != null && colors != null)
                Expanded(
                  child: ListView.builder(
                    itemCount: states.length,
                    itemBuilder: (context, index) {
                      return Text(
                        states[index],
                        style: TextStyle(
                          fontSize: 18,
                          color: colors[index],
                        ),
                      );
                    },
                  ),
                )
              else
                Text(
                  content,
                  style: TextStyle(
                      fontSize: 18, color: const Color.fromARGB(255, 0, 0, 0)),
                  textAlign: TextAlign.left,
                ),
              if (isButton)
                ElevatedButton(
                  onPressed: onPressed,
                  child: Text('Download'),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionCard({
    required String title,
    required String content,
    double titleFontSize = 20,
    double contentFontSize = 18,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 148, 146, 146),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 53, 53, 53).withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 8,
            offset: Offset(0, 4), // Offset of the shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: contentFontSize,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
