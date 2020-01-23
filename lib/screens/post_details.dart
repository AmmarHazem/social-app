import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/post_commnets.dart';
import '../providers/posts.dart';
import '../helpers.dart';
import '../widgets/like_button.dart';
import '../widgets/add_post_comment.dart';

class PostDetails extends StatelessWidget {
  static const routeName = 'post-details';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    return Scaffold(
      appBar: AppBar(
        title: Text(args['title']),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future:
              Provider.of<PostsProvider>(context).getPostDetails(args['url']),
          builder: (cxt, snapshot) {
            if (snapshot.hasData) {
              final Post post = snapshot.data;
              final List<Widget> listViewContent = [
                Text(
                  post.content,
                  style: Theme.of(context).textTheme.subtitle,
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Text(
                      getUsernameFromUrl(post.user),
                      style: Theme.of(context).textTheme.caption,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      getDateTimeFromString(post.created),
                      style: Theme.of(context).textTheme.caption,
                    ),
                    Spacer(),
                    Consumer<PostsProvider>(
                      builder: (cxt, postsProvider, child) {
                        return LikePostButton(postUrl: post.url);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AddPostComment(postUrl: args['url']),
                const SizedBox(height: 20),
                PostComments(postUrl: args['url']),
              ];
              return ListView.builder(
                itemBuilder: (cxt, index) => listViewContent[index],
                itemCount: listViewContent.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 20,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error'));
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

// class PostDetails extends StatefulWidget {
//   static const routeName = 'post-details';

//   @override
//   _PostDetailsState createState() => _PostDetailsState();
// }

// class _PostDetailsState extends State<PostDetails> {
//   Post _post;
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();

//     Future.delayed(Duration.zero, () async {
//       final args =
//           ModalRoute.of(context).settings.arguments as Map<String, String>;
//       final post = await Provider.of<PostsProvider>(
//         context,
//         listen: false,
//       ).getPostDetails(args['url']);
//       setState(() {
//         _post = post;
//         _loading = false;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final args =
//         ModalRoute.of(context).settings.arguments as Map<String, String>;
//     final List<Widget> listViewContent = _post == null
//         ? []
//         : [
//             Text(
//               _post.content,
//               style: Theme.of(context).textTheme.subtitle,
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: <Widget>[
//                 Text(
//                   getUsernameFromUrl(_post.user),
//                   style: Theme.of(context).textTheme.caption,
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   getDateTimeFromString(_post.created),
//                   style: Theme.of(context).textTheme.caption,
//                 ),
//                 Spacer(),
//                 Consumer<PostsProvider>(
//                   builder: (cxt, postsProvider, child) {
//                     return LikePostButton(postUrl: _post.url);
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.comment),
//                   onPressed: () {},
//                 ),
//               ],
//             ),
//           ];
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(args['title']),
//       ),
//       body: SafeArea(
//         child: _loading
//             ? Center(child: CircularProgressIndicator())
//             : ListView.builder(
//                 itemBuilder: (cxt, index) => listViewContent[index],
//                 itemCount: listViewContent.length,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 15,
//                   vertical: 20,
//                 ),
//               ),
//       ),
//     );
//   }
// }
