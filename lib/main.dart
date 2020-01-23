import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/profile.dart';
import './screens/login_register.dart';
import './providers/auth.dart';
import './screens/timeline.dart';
import './screens/splash.dart';
import './providers/posts.dart';
import './screens/post_details.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, PostsProvider>(
          update: (cxt, authProvider, prevPostsProvider) => PostsProvider(
            prevPostsProvider.posts,
            prevPostsProvider.postsCount,
            prevPostsProvider.nextUrl,
            prevPostsProvider.prevUrl,
            authProvider.userData,
            authProvider.getUsernameFromPrefs,
          ),
          create: (cxt) => PostsProvider([], 0, '', '', {}, (){}),
        ),
        // ChangeNotifierProvider.value(value: PostsProvider(null)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Social App',
        theme: ThemeData.dark().copyWith(
          accentColor: Colors.amber,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.amber,
          ),
        ),
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (cxt) => SplashScreen(),
          LoginRegisterScreen.routeName: (cxt) => LoginRegisterScreen(),
          TimelineScreen.routeName: (cxt) => TimelineScreen(),
          PostDetails.routeName: (cxt) => PostDetails(),
          ProfileScreen.routeName: (cxt) => ProfileScreen(),
        },
      ),
    );
  }
}
