import 'package:flutter/material.dart';

import '../providers/posts.dart';
import '../screens/post_details.dart';
import '../helpers.dart';
import './like_button.dart';

class PostListTile extends StatelessWidget {
  const PostListTile({
    Key key,
    @required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(post.title),
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(getUsernameFromUrl(post.user)),
          const SizedBox(width: 10),
          Text(getDateTimeFromString(post.created)),
        ],
      ),
      trailing: SizedBox(
        width: 80,
        child: Row(
          children: <Widget>[
            LikePostButton(postUrl: post.url),
            const SizedBox(width: 5),
            Column(
              children: <Widget>[
                Icon(Icons.comment),
                const SizedBox(height: 5),
                Text(post.comments.length.toString()),
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.pushNamed(context, PostDetails.routeName, arguments: {
          'url': post.url,
          'title': post.title,
        });
      },
    );
  }
}
