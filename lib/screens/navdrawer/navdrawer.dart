import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../style.dart';

class NavDrawer extends StatelessWidget {
  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          ListTile(
              leading: Icon(
                Icons.headset,
                color: AppTextColor,
              ),
              title: Text('Live')),
          ListTile(
              leading: Icon(
                Icons.insights,
                color: AppTextColor,
              ),
              title: Text('Stock Mentions')),
          ListTile(
              leading: Icon(
                Icons.settings,
                color: AppTextColor,
              ),
              title: Text('Settings')),
          // InkWell(
          //     onTap: () =>
          //         _launchUrl('https://www.paypal.com/paypalme/buckey5266'),
          //     child: ListTile(
          //         leading: Icon(
          //           Icons.link,
          //           color: AppTextColor,
          //         ),
          //         title: Text('Donate'))),
          InkWell(
              onTap: () =>
                  _launchUrl('https://www.reddit.com/r/wallstreetbets'),
              child: ListTile(
                  leading: Icon(
                    Icons.link,
                    color: AppTextColor,
                  ),
                  title: Text('r/wallstreetbets'))),
          ListTile(title: Center(child: Text('v1.0.0')))
        ],
      ),
    );
  }
}
