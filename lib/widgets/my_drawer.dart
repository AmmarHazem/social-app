import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/timeline.dart';
import '../screens/login_register.dart';
import '../screens/profile.dart';
import '../providers/auth.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context).settings.name;
    return Drawer(
      child: LayoutBuilder(
        builder: (cxt, constraints) => Column(
          children: <Widget>[
            Container(
              height: constraints.maxHeight * 0.3,
              color: Colors.grey,
              alignment: Alignment.center,
              child: Text(
                'Social App',
                style: Theme.of(context).textTheme.title,
              ),
            ),
            const SizedBox(height: 20),
            FlatButton(
              color: currentRoute == ProfileScreen.routeName ? Colors.black : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0)
              ),
              onPressed: () {
                if(currentRoute != ProfileScreen.routeName){
                  Navigator.pushReplacementNamed(context, ProfileScreen.routeName);
                }
                else{
                  Navigator.pop(context);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Profile'),
                  Icon(Icons.person),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0)
              ),
              color: currentRoute == TimelineScreen.routeName ? Colors.black : null,
              onPressed: () {
                if(currentRoute != TimelineScreen.routeName){
                  Navigator.pushReplacementNamed(context, TimelineScreen.routeName);
                }
                else{
                  Navigator.pop(context);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Timeline'),
                  Icon(Icons.timeline),
                ],
              ),
            ),
            const SizedBox(height: 10),
            FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0)
              ),
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  LoginRegisterScreen.routeName,
                  (route) => false,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Logout'),
                  Icon(Icons.exit_to_app),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
