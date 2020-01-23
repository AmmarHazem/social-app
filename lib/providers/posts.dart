import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../constants.dart';

// 401 error is an invalid or messing token error
class PostsProvider with ChangeNotifier {
  List<Post> _posts = [];
  int _postsCount = 0;
  String _nextUrl = '';
  String _prevUrl = '';
  final Dio dio = Dio();
  final Map<String, dynamic> _userData;
  final Function getUserNameFromPrefs;

  PostsProvider(
    this._posts,
    this._postsCount,
    this._nextUrl,
    this._prevUrl,
    this._userData,
    this.getUserNameFromPrefs,
  );

  List<Post> get posts => _posts;
  int get postsCount => _postsCount;
  String get nextUrl => _nextUrl;
  String get prevUrl => _prevUrl;

  Future<void> addComment(String content, String postUrl) async {
    final post = _posts.firstWhere((post) => post.url == postUrl);
    final headrs = await _getAuthHeaders();
    try{
      final res = await dio.post('$API_URL/api/posts/post-comment/', options: Options(headers: headrs), data: {
        'content': content,
        'post': postUrl,
      });
      final Map<String, dynamic> data = res.data;
      post.comments.add(data['url']);
      notifyListeners();
    }
    catch(e){
      print('--- add commmet error');
      print(e);
      return null;
    }
  }

  Future<Comment> getComment(String commentUrl) async {
    try{
      final res = await dio.get(commentUrl);
      final Map<String, dynamic> data = res.data;
      return Comment(
        content: data['content'],
        created: data['created'],
        postUrl: data['post'],
        userUrl: data['user'],
      );
    }
    catch(e){
      print('--- get comment error');
      print(e);
      return null;
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {'Authorization': 'Token $token'};
  }

  Future<bool> togglePostLike(String postUrl) async {
    final authHeaders = await _getAuthHeaders();
    final post = _posts.firstWhere((post) => post.url == postUrl);
    final username = await getUserNameFromPrefs();
    if (post.likes.contains(username)) {
      post.likes.remove(username);
    } else {
      post.likes.add(username);
    }
    notifyListeners();
    try {
      await dio.post(
        '$API_URL/api/posts/like/',
        options: Options(headers: authHeaders),
        data: {'post': postUrl},
      );
      return true;
    } catch (e) {
      if (post.likes.contains(username)) {
        post.likes.remove(username);
      } else {
        post.likes.add(username);
      }
      print('--- error like post');
      print(e);
      return false;
    }
  }

  Future<Post> createPost(String title, String content, bool published) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final res = await dio.post('$API_URL/api/posts/',
          data: {
            'title': title,
            'content': content,
            'published': published,
          },
          options: Options(headers: authHeaders));
      final data = res.data as Map<String, dynamic>;
      final post = Post(
        content: data['content'],
        created: data['created'],
        published: data['published'],
        title: data['title'],
        url: data['url'],
        user: data['user'],
        comments: data['comments'],
        likes: data['likes'],
        slug: data['slug'],
      );
      _posts.insert(0, post);
      notifyListeners();
      return post;
    } catch (e) {
      print('--- create post error');
      print(e);
      return null;
    }
  }

  Future<Post> getPostDetails(String postUrl) async {
    try {
      final res = await dio.get(postUrl);
      final data = res.data as Map<String, dynamic>;
      return Post(
        content: data['content'],
        created: data['created'],
        published: data['published'],
        title: data['title'],
        url: data['url'],
        user: data['user'],
        comments: data['comments'],
        likes: data['likes'],
        slug: data['slug'],
      );
    } catch (e) {
      print('--- get post detials error');
      print(e);
      return null;
    }
  }

  Future<void> getTimeline() async {
    final authHeaders = await _getAuthHeaders();
    try {
      final res = await dio.get(
        '$API_URL/api/timeline/',
        options: Options(headers: authHeaders),
      );
      _postsCount = res.data['count'];
      _nextUrl = res.data['next'];
      _prevUrl = res.data['previous'];
      _posts = res.data['results']
          .map<Post>((postData) => Post(
                content: postData['content'],
                title: postData['title'],
                created: postData['created'],
                published: postData['published'],
                url: postData['url'],
                user: postData['user'],
                comments: postData['comments'],
                likes: postData['likes'],
                slug: postData['slug'],
              ))
          .toList();
      notifyListeners();
      return;
    } catch (e) {
      print('--- get timeline error');
      print(e);
      return null;
    }
  }
}

class Comment {
  final String content;
  final String postUrl;
  final String userUrl;
  final String created;

  Comment({
    @required this.postUrl,
    @required this.created,
    @required this.content,
    @required this.userUrl,
  });
}

class Post {
  final String url;
  final String title;
  final String slug;
  final String content;
  final String user;
  final String created;
  final bool published;
  final List<dynamic> comments;
  final List<dynamic> likes;

  Post({
    @required this.title,
    @required this.url,
    @required this.content,
    @required this.user,
    @required this.created,
    @required this.published,
    this.comments,
    this.likes,
    this.slug,
  });
}
