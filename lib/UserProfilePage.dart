import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _username = 'John Doe';
  String _email = 'john.doe@example.com';
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationEnabled = true;
  bool _biometricAuthEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Profile',
          style:
              TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w200),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout logic
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                        'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement edit profile logic
                    },
                    icon: Icon(Icons.edit),
                    label: Text(
                      'Edit Profile',
                      style: TextStyle(fontFamily: 'Montserrat'),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Text(
                'Personal Information',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Name', style: TextStyle(fontFamily: 'Montserrat')),
                subtitle:
                    Text(_username, style: TextStyle(fontFamily: 'Montserrat')),
              ),
              ListTile(
                leading: Icon(Icons.email),
                title:
                    Text('Email', style: TextStyle(fontFamily: 'Montserrat')),
                subtitle:
                    Text(_email, style: TextStyle(fontFamily: 'Montserrat')),
              ),
              SizedBox(height: 32),
              Text(
                'Settings',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              SwitchListTile(
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                title: Text('Enable Notifications',
                    style: TextStyle(fontFamily: 'Montserrat')),
                secondary: Icon(Icons.notifications),
              ),
              SwitchListTile(
                value: _locationEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                },
                title: Text('Location Services',
                    style: TextStyle(fontFamily: 'Montserrat')),
                secondary: Icon(Icons.location_on),
              ),
              SwitchListTile(
                value: _biometricAuthEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _biometricAuthEnabled = value;
                  });
                },
                title: Text('Biometric Authentication',
                    style: TextStyle(fontFamily: 'Montserrat')),
                secondary: Icon(Icons.fingerprint),
              ),
              SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Read our privacy policy to learn how we collect and use your data.',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
// TODO: Implement privacy policy logic
                            },
                            child: Text(
                              'Read',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
