import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../providers/posts.dart';
import '../widgets/post_list_tile.dart';
import '../widgets/my_drawer.dart';

class TimelineScreen extends StatelessWidget {
  static const routeName = 'timeline';

  Future<void> _getTimeline(BuildContext context) {
    return Provider.of<PostsProvider>(context, listen: false).getTimeline();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('Timeline'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                builder: (cxt) => Container(
                  child: CreatePostModal(),
                ),
                context: context,
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _getTimeline(context),
        child: SafeArea(
          child: FutureBuilder(
            future: _getTimeline(context),
            builder: (cxt, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Consumer<PostsProvider>(
                  builder: (cxt, _postsProvider, _) {
                    final posts = _postsProvider.posts;
                    if (posts == null) {
                      return Center(child: Text('Error'));
                    } else if (posts.isEmpty) {
                      return Center(
                        child: Text(
                            'No posts yet. Follow someone to see their posts.'),
                      );
                    }
                    final List<Widget> listViewContent =
                        posts.map((post) => PostListTile(post: post)).toList();
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 20,
                      ),
                      itemBuilder: (cxt, index) => listViewContent[index],
                      itemCount: listViewContent.length,
                      separatorBuilder: (cxt, index) =>
                          const SizedBox(height: 20),
                    );
                  },
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CreatePostModal extends StatefulWidget {
  @override
  _CreatePostModalState createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final Map<String, dynamic> _postData = {
    'published': true,
  };
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  void _createPost(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _loading = true;
    });
    final post = await Provider.of<PostsProvider>(context, listen: false).createPost(
        _postData['title'], _postData['content'], _postData['published']);
    setState(() {
      _loading = false;
    });
    if (post != null) {
      Navigator.pop(context);
      Toast.show('Post added successfuly', context);
    } else {
      Toast.show('Error', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 80,
          bottom: 20,
        ),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter a title';
                }
                return null;
              },
              onSaved: (value) => _postData['title'] = value,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              maxLines: 6,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter a content';
                }
                return null;
              },
              onSaved: (value) => _postData['content'] = value,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Content',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Published:'),
                Checkbox(
                  onChanged: (value) => setState(() {
                    _postData['published'] = value;
                  }),
                  value: _postData['published'],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: RaisedButton(
                onPressed: _loading ? null : () => _createPost(context),
                child: Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
