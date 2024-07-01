import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsSpotPage extends StatelessWidget {
  final String spotId;

  DetailsSpotPage({required this.spotId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spot Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('spot').doc(spotId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Spot not found.'));
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  data['ImageUrl'] ?? 'https://via.placeholder.com/600x400',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
                SizedBox(height: 16),
                Text(
                  data['Tourist_spot_name'] ?? 'No name',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Country: ${data['country_name'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Location: ${data['location'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 16),
                Text(
                  'Description:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  data['description'] ?? 'No description',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
