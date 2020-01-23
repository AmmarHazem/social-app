import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers.dart';
import '../providers/posts.dart';

class PostComments extends StatelessWidget {
  final String postUrl;

  PostComments({
    @required this.postUrl,
  });

  Future<List<Comment>> _getComments(BuildContext context) {
    final postsProvider = Provider.of<PostsProvider>(context);
    final post = postsProvider.posts.firstWhere((post) => post.url == postUrl);
    final List<Future<Comment>> futures = post.comments
        .map((comment) => postsProvider.getComment(comment))
        .toList();
    return Future.wait<Comment>(futures);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getComments(context),
      builder: (cxt, snapshot) {
        if (snapshot.hasData) {
          final List<Comment> comments = snapshot.data;
          if (comments.length == 0) {
            return Text(
              'No comments yet!',
              style: TextStyle(color: Colors.grey),
            );
          }
          return Column(
            children: comments
                .map((comment) => ListTile(
                      title: Text(comment.content),
                      subtitle: Text(getUsernameFromUrl(comment.userUrl)),
                    ))
                .toList(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error'));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
