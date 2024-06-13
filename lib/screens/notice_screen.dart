// lib/screens/notice_screen.dart
import 'package:flutter/material.dart';
import 'bottom_navigation.dart';
import 'home_screen.dart';
import '../colors.dart'; // Import your colors file

class NoticeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
      ),
      body: Container(
        color: AppColors.textWhite, // Set the background color here
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            _buildNoticeTile(context, 'Notice 1', 'All students are required to adhere to all the strict rules.'),
            _buildNoticeTile(context, 'Notice 2', 'All students are required to adhere to all the strict rules.'),
            _buildNoticeTile(context, 'Notice 3', 'All students are required to adhere to all the strict rules.'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 2,
        onTap: (index) {
          // Handle navigation based on index
          if (index == 0) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
          } else if (index == 2) {
            // Do nothing as it's the current screen
          }
        },
      ),
    );
  }

  Widget _buildNoticeTile(BuildContext context, String title, String subtitle) {
    return Card(
      color: AppColors.lightButtonColor, // Set the card background color here
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content: SingleChildScrollView(
                  child: Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                        'Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. '
                        'Sed nisi. Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. '
                        'Praesent mauris. Fusce nec tellus sed augue semper porta. '
                        'Mauris massa. Vestibulum lacinia arcu eget nulla.',
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(color: AppColors.textBlack),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
