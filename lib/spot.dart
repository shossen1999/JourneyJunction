import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart'; // Import HomePage

class SpotPage extends StatefulWidget {
  @override
  _SpotPageState createState() => _SpotPageState();
}

class _SpotPageState extends State<SpotPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedSpotId;
  bool _isEditing = false;

  Future<void> _addOrUpdateTouristSpot() async {
    try {
      if (_isEditing && _selectedSpotId != null) {
        await _firestore.collection('spot').doc(_selectedSpotId).update({
          'Tourist_spot_name': _nameController.text,
          'country_name': _countryController.text,
          'location': _locationController.text,
          'ImageUrl': _imageUrlController.text,
          'description': _descriptionController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Tourist spot updated successfully!'),
        ));
      } else {
        await _firestore.collection('spot').add({
          'Tourist_spot_name': _nameController.text,
          'country_name': _countryController.text,
          'location': _locationController.text,
          'ImageUrl': _imageUrlController.text,
          'description': _descriptionController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Tourist spot added successfully!'),
        ));
      }

      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save tourist spot: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _clearFields() {
    _nameController.clear();
    _countryController.clear();
    _locationController.clear();
    _imageUrlController.clear();
    _descriptionController.clear();
    setState(() {
      _isEditing = false;
      _selectedSpotId = null;
    });
  }

  void _editSpot(String spotId) async {
    DocumentSnapshot doc =
        await _firestore.collection('spot').doc(spotId).get();
    var data = doc.data() as Map<String, dynamic>;
    _nameController.text = data['Tourist_spot_name'] ?? '';
    _countryController.text = data['country_name'] ?? '';
    _locationController.text = data['location'] ?? '';
    _imageUrlController.text = data['ImageUrl'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    setState(() {
      _isEditing = true;
      _selectedSpotId = spotId;
    });
  }

  Future<void> _deleteSpot(String spotId) async {
    try {
      await _firestore.collection('spot').doc(spotId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Tourist spot deleted successfully!'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete tourist spot: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tourist Spots'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Tourist Spot Name'),
                  ),
                  SizedBox(height: 12.0),
                  TextField(
                    controller: _countryController,
                    decoration: InputDecoration(labelText: 'Country Name'),
                  ),
                  SizedBox(height: 12.0),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: 'Location'),
                  ),
                  SizedBox(height: 12.0),
                  TextField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(labelText: 'Image URL'),
                  ),
                  SizedBox(height: 12.0),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  SizedBox(height: 12.0),
                  ElevatedButton(
                    onPressed: _addOrUpdateTouristSpot,
                    child: Text(_isEditing
                        ? 'Update Tourist Spot'
                        : 'Add Tourist Spot'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              padding: EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('spot').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No tourist spots available'));
                  }

                  var spots = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Country')),
                        DataColumn(label: Text('Location')),
                        DataColumn(label: Text('Image URL')),
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: spots.map((spot) {
                        var data = spot.data() as Map<String, dynamic>;
                        return DataRow(
                          cells: [
                            DataCell(Text(data['Tourist_spot_name'] ?? '')),
                            DataCell(Text(data['country_name'] ?? '')),
                            DataCell(Text(data['location'] ?? '')),
                            DataCell(Text(data['ImageUrl'] ?? '')),
                            DataCell(Text(data['description'] ?? '')),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editSpot(spot.id),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteSpot(spot.id),
                                ),
                              ],
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
