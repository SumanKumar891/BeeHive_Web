import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Map Page'),
        backgroundColor: Color.fromARGB(255, 152, 207, 158,),
      ),
      body: Container(
        color: Color.fromARGB(255, 152, 207, 158,),
        child: Center(
          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("All Devices",
                              style:TextStyle(fontSize: 30,fontWeight: FontWeight.bold,) ,)
                              .animate()
                              .fade(delay: 300.ms)
                              .slideX()
                              ,
                              // SizedBox(height: 10,),
                            
                             Expanded(
                              // height: 530,
                              child: FlutterMap(
                                options: MapOptions(
                                  center: LatLng(20.5937, 78.9629),
                                  zoom: 5.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                              
                                ),],
                    ),
                      // color: Color.fromARGB(255, 15, 140, 193),
                    ),
      ),
    );
  }

} 