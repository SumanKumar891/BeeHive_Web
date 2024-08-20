
// import 'dart:convert';
// import 'dart:typed_data';
// import 'dart:html' as html;
// import 'package:http/http.dart' as http; 
// // import 'package:syngenta/images_fullscrn4.dart';

// import 'package:archive/archive.dart';

// // import 'package:syngenta/homepage.dart';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// class FullScreenChart4 extends StatelessWidget {
//   final List<String>imageUrls;
//    void _downloadAllImagesaszip() async {      //code for downloading zip file of images
//   final archive = Archive();

//   for (String url in imageUrls) {
//     // Fetch the image
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       // Add the image to the archive
//       final filename = url.split('/').last;
//       final fileBytes = response.bodyBytes;
//       final archiveFile = ArchiveFile.noCompress(filename, fileBytes.length, fileBytes);
//       archive.addFile(archiveFile);
//     } else {
//       print('Failed to download image: $url');
//     }
//   }

//   // Encode the archive to zip format
//   final zipEncoder = ZipEncoder();
//   final zipData = zipEncoder.encode(archive);

//   // Convert the zip data to Uint8List
//   final zipBytes = Uint8List.fromList(zipData!);

//   // Create a blob URL for the zip file
//   final blob = html.Blob([zipBytes]);
//   final blobUrl = html.Url.createObjectUrlFromBlob(blob);

//   // Create an anchor element for download
//   final anchorElement = html.AnchorElement(href: blobUrl)
//     ..setAttribute('download', 'images.zip')
//     ..click();

//   // Revoke the blob URL
//   html.Url.revokeObjectUrl(blobUrl);
// }
// void _downloadAllurl() {                                           //for downloading urls of images
//     // Generate text file content with total count and image URLs
//     int totalCount = imageUrls.length;
//     String concatenatedUrls = imageUrls.join('\n');
//     String fileContent = 'Total Images: $totalCount\n$concatenatedUrls';

//     // Encode content as UTF-8
//     List<int> encodedContent = utf8.encode(fileContent);

//     // Create blob URL for download
//     String blobUrl = 'data:application/octet-stream;charset=utf-8;base64,' +
//         base64Encode(encodedContent);

//     // Create anchor element for download
//     html.AnchorElement anchorElement = html.AnchorElement(href: blobUrl)
//       ..setAttribute('download', 'images.txt');

//     // Trigger download
//     anchorElement.click();
//   }


//   FullScreenChart4({required this.imageUrls});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('IMAGES'),
//       ),
//       body: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             // Text("IMAGES", style: TextStyle(fontWeight: FontWeight.bold),),
                            
                            
                                
//                     Expanded(
                                                     
                                                     
//                                     child: ListView.builder(
                                      
//                                       itemCount: imageUrls.length,
//                                       itemBuilder: (context, index) {
//                                                    // Calculate the reversed index
//                                                    int reversedIndex = imageUrls.length - 1 - index;
//                                                    return ListTile(
//                                                      title: Image.network(imageUrls[reversedIndex]),
//                                                    );
//                                       },
//                                     ),
//                                   ),
//                                   Row(
//                                     children: [
//                                   Expanded(
//                                       child: ElevatedButton(
//                                                         onPressed: () =>  _downloadAllImagesaszip(),
//                                                         style: ElevatedButton.styleFrom(
//                                                           backgroundColor: const Color.fromARGB(255, 183, 170, 166),
//                                                           // Set button's background color to green
//                                                         ),
//                                                         child: Text('Download Images'),
//                                                       ),
//                                     ),

//                                      Expanded(
//                                        child: ElevatedButton(
//                                                          onPressed: () => _downloadAllurl(),
//                                                          style: ElevatedButton.styleFrom(
//                                                            backgroundColor: const Color.fromARGB(255, 183, 170, 166),
//                                                            // Set button's background color to green
//                                                          ),
//                                                          child: Text('Links for Images'),
//                                                        ),
//                                      ),]
//                                   ),
                                                   
//                              ]
//                   ),
//     );
//   }
// }
