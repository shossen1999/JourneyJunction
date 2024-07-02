import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';
import 'spot.dart';
import 'detailsSpot.dart'; // Import the detailsSpot.dart file

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<String> _imageUrls = [
    'https://images.pexels.com/photos/2105416/pexels-photo-2105416.jpeg',
    'https://images.pexels.com/photos/629162/pexels-photo-629162.jpeg',
    'https://images.pexels.com/photos/1424239/pexels-photo-1424239.jpeg',
  ];

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
            String spotId = doc.id;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsSpotPage(spotId: spotId),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.all(10),
                width: 320, // Increased width
                height: 150, // Decreased height
                decoration: BoxDecoration(
                  color: Colors.transparent, // Transparent background for card
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        data['ImageUrl'] ??
                            'https://via.placeholder.com/320x150',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        color: Colors.black.withOpacity(
                            0.5), // Semi-transparent black background
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          data['Tourist_spot_name'] ?? 'No name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            userEmail: FirebaseAuth.instance.currentUser?.email ?? '',
          ),
        ),
      );
    } else if (index == 2) {
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
                'Journey Junction',
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
