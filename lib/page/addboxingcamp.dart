import 'dart:io'; // Import for File
import 'package:image_picker/image_picker.dart'; // Import for ImagePicker
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_picker_page.dart';

class AddCampPage extends StatefulWidget {
  const AddCampPage({super.key});

  @override
  State<AddCampPage> createState() => _AddCampPageState();
}

class _AddCampPageState extends State<AddCampPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  LatLng? _selectedLocation;
  File? _image; // Variable to store the selected image

  Future<void> _selectLocation() async {
    final location = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerPage()),
    );
    if (location != null) {
      setState(() {
        _selectedLocation = location;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _submitData() async {
    if (_formKey.currentState?.validate() ?? false) {
      final campData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'location': {
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
        },
      };

      final response = await http.post(
        Uri.parse('http://localhost:3000/addcamp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(campData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('บันทึกค่ายมวยสำเร็จ')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('เกิดข้อผิดพลาด: ${response.reasonPhrase}')));
      }
    }
  }

  void _cancel() {
    Navigator.pop(context); // กลับไปหน้าก่อนหน้า
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'เพิ่มค่ายมวย',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        backgroundColor: Color.fromARGB(248, 226, 131, 53),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 450), // Reduce maxWidth to make it more compact
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Picker Box
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFED673), // Background color #FED673
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3), // Shadow color
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: Offset(4, 6), // Shadow position (right, bottom)
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5), // Inner light shadow
                              spreadRadius: -1,
                              blurRadius: 15,
                              offset: Offset(-4, -4), // Shadow position (left, top)
                            ),
                          ],
                        ),
                        width: double.infinity,
                        height: 150, // Reduce height for a more compact look
                        child: Center(
                          child: _image == null
                              ? Text(
                                  'แตะเพื่อเลือกรูปภาพ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                )
                              : Image.file(
                                  _image!,
                                  width: double.infinity,
                                  height: 150, // Adjusted height to match container
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Camp Name Input
                    Text(
                      'ชื่อค่าย',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'ใส่ชื่อค่าย',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Adjusted padding
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาใส่ชื่อค่าย';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    // Description Input
                    Text(
                      'คำอธิบายค่าย',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'ใส่คำอธิบายค่าย',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Adjusted padding
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาใส่คำอธิบายค่าย';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    // Location Picker
                    Text(
                      'ตำแหน่ง',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectLocation,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3), // Shadow color
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: Offset(4, 6), // Shadow position (right, bottom)
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5), // Inner light shadow
                              spreadRadius: -1,
                              blurRadius: 15,
                              offset: Offset(-4, -4), // Shadow position (left, top)
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(14), // Adjust padding to make it more compact
                        child: Text(
                          _selectedLocation == null
                              ? 'แตะเพื่อเลือกตำแหน่ง'
                              : 'ตำแหน่ง: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Submit and Cancel Buttons
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _submitData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 59, 218, 64), // Green color
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22), // Adjusted padding
                            ),
                            child: Text(
                              'บันทึกข้อมูล',
                              style: TextStyle(color: Colors.black, fontSize: 16), // Black text
                            ),
                          ),
                          SizedBox(width: 16), // Space between buttons
                          ElevatedButton(
                            onPressed: _cancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 241, 116, 116), // Red color
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22), // Adjusted padding
                            ),
                            child: Text(
                              'ยกเลิก',
                              style: TextStyle(color: Colors.black, fontSize: 16), // Black text
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
