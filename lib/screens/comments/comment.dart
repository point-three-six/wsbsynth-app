import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../style.dart';

class Comment extends StatelessWidget {
  final String id;
  final String author;
  final String flair;
  final String body;
  final String permalink;
  final String audio;
  final symbols;

  Comment(this.id, this.author, this.flair, this.body, this.permalink,
      this.symbols, this.audio);

  void _launchUrl(String url) async {
    print(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 2, color: AppPrimaryColor)),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.fromLTRB(7, 15, 0, 5),
                    child: Row(
                      children: [
                        Text(author,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .apply(color: AppTextColor)),
                        Text(flair,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .apply(color: AppLightColor))
                      ],
                    )),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 7, 5),
                  child: InkWell(
                    child: Icon(
                      Icons.link,
                      color: AppTextColor,
                    ),
                    onTap: () =>
                        _launchUrl(('https://www.reddit.com' + permalink)),
                  ),
                )
              ]),
              Container(
                  margin: EdgeInsets.fromLTRB(7, 0, 7, 15),
                  child:
                      Text(body, style: Theme.of(context).textTheme.bodyText1))
            ]));
  }
}
