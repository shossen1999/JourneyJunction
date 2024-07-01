import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart'; // Import HomePage

class ProfilePage extends StatelessWidget {
  final String userEmail;

  ProfilePage({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to HomePage and remove ProfilePage from stack
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false, // Remove all routes in the stack
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Sign out the user
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage()), // Navigate to HomePage
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users_profile')
              .where('email', isEqualTo: userEmail)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No profile data available'));
            }

            var userData =
                snapshot.data!.docs.first.data() as Map<String, dynamic>;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(userData['image'] ??
                          'https://via.placeholder.com/150'),
                    ),
                  ),
                  SizedBox(height: 20),
                  ProfileCard(
                    label: 'Name',
                    value: userData['name'] ?? 'No name available',
                    icon: Icons.person,
                  ),
                  SizedBox(height: 20),
                  ProfileCard(
                    label: 'Email',
                    value: userData['email'] ?? 'No email available',
                    icon: Icons.email,
                  ),
                  SizedBox(height: 20),
                  ProfileCard(
                    label: 'Phone',
                    value: userData['phone'] ?? 'No phone available',
                    icon: Icons.phone,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  ProfileCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.blue,
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700]),
                ),
                SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
