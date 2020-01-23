import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import './timeline.dart';
import '../providers/auth.dart';

class LoginRegisterScreen extends StatefulWidget {

  static const routeName = 'auth';

  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

enum AuthMode {
  Login,
  Signup,
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {};
  bool _loading = false;

  void _submitForm() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    if(_authMode == AuthMode.Login){
      login();
    }
    else{
      register();
    }
  }

  void register() async {
    final authProvider = Provider.of<AuthProvider>(context);
    setState(() {
      _loading = true;
    });
    final authResult = await authProvider.register(_authData['username'], _authData['password']);
    setState(() {
      _loading = false;
    });
    if(authResult){
      Navigator.pushReplacementNamed(context, TimelineScreen.routeName);
    }
    else{
      Toast.show("Invalid info", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
    }
  }

  void login() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _loading = true;
    });
    final authSuccess = await authProvider.login(_authData['username'], _authData['password']);
    setState(() {
      _loading = false;
    });
    if(authSuccess){
      Navigator.pushReplacementNamed(context, TimelineScreen.routeName);
    }
    else{
      Toast.show("Incorrect credentials", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (cxt, constraints) => SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      validator: (value){
                        if(value.isEmpty){
                          return 'Please enter a username';
                        }
                        return null;
                      },
                      onChanged: (value){
                        _authData['username'] = value;
                      },
                      onSaved: (value) {
                        _authData['username'] = value;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      obscureText: true,
                      onChanged: (value){
                        _authData['password'] = value;
                      },
                      validator: (value) {
                        if (value.length < 4) {
                          return 'Password must be longer than 6 characters';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _authData['password'] = value;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                    const SizedBox(height: 20),
                    if(_authMode == AuthMode.Signup)TextFormField(
                      obscureText: true,
                      validator: (value) {
                        if(_authData['password'] != value){
                          return 'Password fields does not match';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Confirm Password',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      child: RaisedButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: _loading ? CircularProgressIndicator() : Text(
                            _authMode == AuthMode.Login ? 'Login' : 'Signup'),
                        onPressed: _loading ? null : _submitForm,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FlatButton(
                      child: Text(_authMode == AuthMode.Login ? 'Or signup instead' : 'Login'),
                      onPressed: _loading ? null : (){
                        if(_authMode == AuthMode.Login){
                          setState(() {
                            _authMode = AuthMode.Signup;
                          });
                        }
                        else{
                          setState(() {
                            _authMode = AuthMode.Login;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
