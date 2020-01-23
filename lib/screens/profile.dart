import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/helpers.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/circle_image.dart';
import '../widgets/my_drawer.dart';
import '../providers/auth.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = 'profile-screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showFollowing = true;

  List<Widget> _getListTileItems(List<String> userUrls) {
    return userUrls
        .map((userUrl) => ListTile(
              title: Text(getUsernameFromUrl(userUrl)),
            ))
        .toList();
  }

  void _showEditModal() {
    showModalBottomSheet(
      builder: (cxt) => EditModal(),
      context: context,
      isScrollControlled: true,
    );
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (cxt, authProvider, child) {
        return Scaffold(
          drawer: MyDrawer(),
          appBar: AppBar(
            title: FutureBuilder(
              future: authProvider.getProfile(),
              builder: (cxt, snapshot) {
                if (snapshot.hasData) {
                  final Profile profile = snapshot.data;
                  return Text(profile.username);
                }
                return Text('');
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _showEditModal(),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: FutureBuilder(
                future: authProvider.getProfile(),
                builder: (cxt, snapshot) {
                  if (snapshot.hasData) {
                    final Profile profile = snapshot.data;
                    return Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleImage(
                              imageUrl: profile.image,
                              radius: 80,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  profile.username,
                                  style: Theme.of(context).textTheme.title,
                                ),
                                if (profile.bio.isNotEmpty)
                                  const SizedBox(height: 10),
                                if (profile.bio.isNotEmpty) Text(profile.bio)
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            FlatButton(
                              child:
                                  Text('Following ${profile.following.length}'),
                              onPressed: () {
                                if (!_showFollowing) {
                                  setState(() {
                                    _showFollowing = !_showFollowing;
                                  });
                                }
                              },
                            ),
                            FlatButton(
                              child:
                                  Text('Followers ${profile.followers.length}'),
                              onPressed: () {
                                if (_showFollowing) {
                                  setState(() {
                                    _showFollowing = !_showFollowing;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        FutureBuilder(
                          future: authProvider.getProfile(),
                          builder: (cxt, snapshot) {
                            if (snapshot.hasData) {
                              final Profile profile = snapshot.data;
                              return Expanded(
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 200),
                                  child: _showFollowing
                                      ? FollowingUsers(
                                          usersList: _getListTileItems(
                                              profile.following))
                                      : Followers(
                                          usersList: _getListTileItems(
                                              profile.followers)),
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                      ],
                    );
                  }
                  return Column();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class EditModal extends StatefulWidget {
  @override
  _EditModalState createState() => _EditModalState();
}

class _EditModalState extends State<EditModal> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};
  TextEditingController _nameFieldController;
  TextEditingController _bioFieldController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      final profile =
          await Provider.of<AuthProvider>(context, listen: false).getProfile();
      _nameFieldController = TextEditingController(text: profile.name);
      _bioFieldController = TextEditingController(text: profile.bio);
    });
  }

  void _saveForm() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    setState(() {
      _loading = true;
    });
    _formKey.currentState.save();
    final success =
        await Provider.of<AuthProvider>(context, listen: false).saveProfile(
      _formData['name'],
      _formData['bio'],
    );
    setState(() {
      _loading = false;
    });
    if (success) {
      Navigator.pop(context);
    }
  }

  void _pickImage() async {
    final image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _loading = true;
    });
    final success = await Provider.of<AuthProvider>(context, listen: false).saveProvilePicture(image.path);
    setState(() {
      _loading = false;
    });
    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (cxt, authProvider, child) {
        return FutureBuilder(
          builder: (cxt, snapshot) {
            if (snapshot.hasData) {
              final Profile profile = snapshot.data;
              return Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 50),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircleImage(
                          imageUrl: profile.image,
                          radius: 80,
                        ),
                        const SizedBox(width: 15),
                        RaisedButton(
                          onPressed: _pickImage,
                          child: Text('Change image'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            onSaved: (value) {
                              _formData['name'] = value;
                            },
                            validator: (value) {
                              if (value.length > 100) {
                                return 'Name cant be longer that 100 characters';
                              }
                              return null;
                            },
                            controller: _nameFieldController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Name',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            onSaved: (value) {
                              _formData['bio'] = value;
                            },
                            controller: _bioFieldController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Bio',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: _loading ? null : _saveForm,
                        child: _loading
                            ? CircularProgressIndicator()
                            : Text('Save'),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
          future: authProvider.getProfile(),
        );
      },
    );
  }
}

class FollowingUsers extends StatelessWidget {
  final List<Widget> usersList;

  FollowingUsers({@required this.usersList});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (cxt, index) => usersList[index],
      itemCount: usersList.length,
      separatorBuilder: (cxt, index) => const SizedBox(height: 5),
    );
  }
}

class Followers extends StatelessWidget {
  final List<Widget> usersList;

  Followers({@required this.usersList});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (cxt, index) => usersList[index],
      itemCount: usersList.length,
      separatorBuilder: (cxt, index) => const SizedBox(height: 5),
    );
  }
}
