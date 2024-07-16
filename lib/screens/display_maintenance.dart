import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottom_navigation.dart'; // Make sure the path is correct
import '../colors.dart'; // Make sure the path is correct
import 'maintenance.dart'; // Make sure the path is correct
import '../models/maintenance_service.dart'; // Ensure the path is correct

class MaintenanceRequestsListScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? roomData;

  const MaintenanceRequestsListScreen({Key? key, this.userData, this.roomData}) : super(key: key);

  @override
  _MaintenanceRequestsListScreenState createState() => _MaintenanceRequestsListScreenState();
}

class _MaintenanceRequestsListScreenState extends State<MaintenanceRequestsListScreen> {
  final MaintenanceService _maintenanceService = MaintenanceService();
  int _currentIndex = 0;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _fetchMaintenanceRequests();
  }

  Future<List<Map<String, dynamic>>> _fetchMaintenanceRequests() async {
    if (currentUser != null) {
      try {
        return await _maintenanceService.fetchMaintenanceRequestsByUserId(currentUser!.uid);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching maintenance requests: $e')),
        );
        return [];
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
      return [];
    }
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        Navigator.of(context).pushReplacementNamed('/notice');
      } else if (index == 1) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (index == 2) {
        Navigator.of(context).pushReplacementNamed('/profile');
      }
    });
  }

  void _showDetailsDialog(BuildContext context, String roomNumber, List<String> issues, String status, DateTime timestamp) {
    Color statusColor;
    if (status == 'pending') {
      statusColor = Colors.orange;
    } else if (status == 'resolved') {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.black; // default color
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Room $roomNumber - Details'),
          content: SingleChildScrollView(
            child: Table(
              columnWidths: {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              children: [
                TableRow(children: [
                  Text('Issues:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(issues.join(', ')),
                ]),
                TableRow(children: [
                  SizedBox(height: 16), // Add some spacing between rows
                  SizedBox(height: 16),
                ]),
                TableRow(children: [
                  Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(status, style: TextStyle(color: statusColor)),
                ]),
                TableRow(children: [
                  SizedBox(height: 16), // Add some spacing between rows
                  SizedBox(height: 16),
                ]),
                TableRow(children: [
                  Text('Requested on:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(timestamp.toString()),
                ]),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Maintenance Requests', style: TextStyle(color: AppColors.textBlack)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MaintenanceScreen(
                        userData: widget.userData,
                        roomData: widget.roomData,
                      ),
                    ),
                  );
                  setState(() {}); // Rebuild the widget to fetch data again
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.backgroundColor,
                ),
                child: Text('New Request', style: TextStyle(color: AppColors.textBlack)),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchMaintenanceRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No maintenance requests found.'));
                } else {
                  final maintenanceRequests = snapshot.data!;
                  return ListView.builder(
                    itemCount: maintenanceRequests.length,
                    itemBuilder: (context, index) {
                      final request = maintenanceRequests[index];
                      final issues = List<String>.from(request['issues'] ?? []);
                      final roomNumber = request['roomNumber'];
                      final status = request['status'];
                      final timestamp = request['timestamp'].toDate();

                      Color statusColor;
                      if (status == 'pending') {
                        statusColor = Colors.orange;
                      } else if (status == 'resolved') {
                        statusColor = Colors.green;
                      } else {
                        statusColor = Colors.black; // default color
                      }

                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Room $roomNumber \n${issues.join(', ')}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status: $status',
                                style: TextStyle(color: statusColor),
                              ),
                              Text('Requested on: $timestamp'),
                            ],
                          ),
                          onTap: () {
                            _showDetailsDialog(context, roomNumber, issues, status, timestamp);
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTap,
        context: context,
        notificationCount: 0, // Update this if you have a notification count
      ),
    );
  }
}
