import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';
import 'spot.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of image URLs for the slider
  final List<String> _imageUrls = [
    'https://images.pexels.com/photos/2105416/pexels-photo-2105416.jpeg',
    'https://images.pexels.com/photos/629162/pexels-photo-629162.jpeg',
    'https://images.pexels.com/photos/1424239/pexels-photo-1424239.jpeg',
  ];

  // Function to fetch tourist spots from Firestore collection
  Widget _buildTouristSpotList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('spot').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No tourist spots found.'));
        }

        return ListView(
          scrollDirection: Axis.horizontal,
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Card(
              child: Column(
                children: [
                  Image.network(
                    data['ImageUrl'] ?? 'https://via.placeholder.com/150',
                    width: 150,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(data['Tourist_spot_name']),
                        Text(data['country_name']),
                        Text(data['location']),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigate to HomePage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else if (index == 1) {
      // Navigate to ProfilePage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            userEmail: FirebaseAuth.instance.currentUser?.email ?? '',
          ),
        ),
      );
    } else if (index == 2) {
      // Navigate to SpotPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpotPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.place),
              title: Text('Tourist Spot'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(2);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Image slider
          Container(
            height: 200,
            child: PageView.builder(
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {
                return Image.network(
                  _imageUrls[index],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          SizedBox(height: 10),
          // Display tourist spots
          Expanded(
            child: _selectedIndex == 0
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Tourist Spots:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12.0),
                        Expanded(
                          child: _buildTouristSpotList(),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      _selectedIndex == 1
                          ? 'Profile Page'
                          : 'Tourist Spot Page',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place),
            label: 'Tourist Spot',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _onItemTapped(index);
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
