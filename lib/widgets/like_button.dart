import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/posts.dart';
import '../providers/auth.dart';

class LikePostButton extends StatelessWidget {
  final String postUrl;

  LikePostButton({@required this.postUrl});

  Future<bool> _checkLiked(BuildContext context) async {
    final Post post = Provider.of<PostsProvider>(context)
        .posts
        .firstWhere((post) => post.url == postUrl);
    final username = await Provider.of<AuthProvider>(
      context,
      listen: false,
    ).getUsernameFromPrefs();
    return post.likes.contains(username);
  }

  @override
  Widget build(BuildContext context) {
    final postsProvider = Provider.of<PostsProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        FutureBuilder(
          future: _checkLiked(context),
          builder: (cxt, snapshot) {
            bool liked = snapshot.data;
            liked = liked == null ? false : liked;
            return SizedBox(
              height: 40,
              child: IconButton(
                padding: const EdgeInsets.all(0),
                icon: Icon(
                  Icons.favorite,
                  color: liked ? Colors.red : Colors.white,
                ),
                onPressed: () => postsProvider.togglePostLike(postUrl),
              ),
            );
          },
        ),
        Text(postsProvider.posts
            .firstWhere((post) => post.url == postUrl)
            .likes
            .length
            .toString()),
      ],
    );
  }
}
