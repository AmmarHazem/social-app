import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/posts.dart';

class AddPostComment extends StatelessWidget {

  final String postUrl;
  final TextEditingController _contentController = TextEditingController();

  AddPostComment({
    @required this.postUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _contentController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Write a comment',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () => Provider.of<PostsProvider>(context, listen: false).addComment(_contentController.text, postUrl),
          ),
        ],
      ),
    );
  }
}
