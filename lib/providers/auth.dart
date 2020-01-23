import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../screens/timeline.dart';
import '../screens/login_register.dart';
import '../constants.dart';

class AuthProvider with ChangeNotifier {
  final Dio dio = Dio();
  Map<String, dynamic> _userData = {};

  Map<String, dynamic> get userData => _userData;

  Future<bool> saveProvilePicture(String picturePath) async {
    final username = await getUsernameFromPrefs();
    final fileExtension = getFileExtension(picturePath);
    print('--- extension $fileExtension');
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        picturePath,
        filename: '$username-profile-picture.$fileExtension',
      )
    });
    final profile = await getProfile();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final res = await dio.put(
        '$API_URL/api/users/${profile.username}/',
        options: Options(headers: {
          'Authorization': 'Token $token',
        }),
        data: formData,
        onSendProgress: (sent, total){
          print('--- progress ${(sent / total) /~ 100}');
        }
      );
      final Map<String, dynamic> userData = res.data;
      setUserData(userData);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userData', json.encode(userData));
      return true;
    } catch (e) {
      print('--- error upload image');
      print(e);
      return false;
    }
  }

  String getFileExtension(String fileName) {
    for (var i = fileName.length - 1; i >= 0; i--) {
      if (fileName[i] == '.') {
        return fileName.substring(i + 1);
      }
    }
    return null;
  }

  Future<bool> saveProfile(String name, String bio) async {
    final profile = await getProfile();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final res = await dio.put(
        '$API_URL/api/users/${profile.username}/',
        options: Options(headers: {
          'Authorization': 'Token $token',
        }),
        data: {
          'name': name,
          'bio': bio,
        },
      );
      final Map<String, dynamic> userData = res.data;
      setUserData(userData);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userData', json.encode(userData));
      return true;
    } catch (e) {
      print('--- error save profile');
      print(e);
      return false;
    }
  }

  Future<Profile> getProfile() async {
    final userData = await getUserDataFromPrefs();
    return Profile(
      bio: userData['bio'],
      created: userData['created'],
      followers: <String>[...userData['followers']],
      following: <String>[...userData['following']],
      image: userData['image'],
      name: userData['name'],
      url: userData['url'],
      username: userData['username'],
    );
  }

  Future<Map<String, dynamic>> getUserDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString('userData'));
  }

  Future<String> getUsernameFromPrefs() async {
    final userData = await getUserDataFromPrefs();
    return userData['username'];
  }

  void setUserData(Map<String, dynamic> newUserData) async {
    _userData = newUserData;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userData');
  }

  Future<bool> register(String username, String password) async {
    try {
      final res = await dio.post('$API_URL/api/register/', data: {
        'username': username,
        'password1': password,
        'password2': password,
      });
      _userData = res.data;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', _userData['token']);
      prefs.setString('userData', json.encode(_userData['user']));
      return true;
    } catch (e) {
      print('--- register error ');
      print(e);
      return false;
    }
  }

  Future<String> tryLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      return LoginRegisterScreen.routeName;
    }
    try {
      final res = await dio.get(
        '$API_URL/api/profile/',
        options: Options(headers: {
          'Authorization': 'Token $token',
        }),
      );
      final Map<String, dynamic> userData = {
        'user': res.data,
        'token': token,
      };
      setUserData(userData);
      return TimelineScreen.routeName;
    } catch (e) {
      print('--- get profile error');
      print(e);
      return LoginRegisterScreen.routeName;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final res = await dio.post('$API_URL/api/login/', data: {
        'username': username,
        'password': password,
      });
      final Map<String, dynamic> data = res.data;
      final prefs = await SharedPreferences.getInstance();
      _userData = data;
      prefs.setString('token', data['token']);
      prefs.setString('userData', json.encode(_userData['user']));
      return true;
    } catch (e) {
      print('--- login error');
      print(e);
      return false;
    }
  }
}

class Profile {
  final String url;
  final String name;
  final String username;
  final String image;
  final String bio;
  final List<String> following;
  final List<String> followers;
  final String created;

  Profile({
    @required this.name,
    @required this.username,
    @required this.url,
    @required this.bio,
    @required this.image,
    @required this.created,
    @required this.followers,
    @required this.following,
  });
}
