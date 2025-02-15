import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:tako_play/models/bookmark.dart';
import 'package:tako_play/screens/about_app_screen.dart';
import 'package:tako_play/screens/main_screen.dart';
import 'package:tako_play/screens/media_fetch_screen.dart';
import 'package:tako_play/screens/video_player_screen.dart';
import 'package:tako_play/screens/webview_screen.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/video_list_screen.dart';
import '../services/request_service.dart';
import '../theme/tako_theme.dart';
import '../utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  _setUpLogging();
  runApp(const MyApp());
}

void _setUpLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((rec) {
    // ignore: avoid_print
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => RequestService.create(),
          dispose: (_, RequestService service) => service.client.dispose(),
        ),
        ChangeNotifierProvider(create: (_) => BookMarkProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 764),
        builder: () => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TakoPlay',
          theme: TakoTheme.dark(),
          initialRoute: '/',
          getPages: [
            GetPage(
              name: Routes.mainScreen,
              page: () => const MainScreen(),
            ),
            GetPage(
              name: Routes.homeScreen,
              page: () => const HomeScreen(),
            ),
            GetPage(
              name: Routes.aboutAppScreen,
              page: () => const AboutAppScreen(),
            ),
            GetPage(
              name: Routes.searchScreen,
              page: () => const SearchScreen(),
            ),
            GetPage(
              name: Routes.videoListScreen,
              page: () => const VideoListScreen(),
            ),
            GetPage(
              name: Routes.mediaFetchScreen,
              page: () => const MediaFetchScreen(),
            ),
            GetPage(
                name: Routes.videoPlayerScreen,
                page: () => const VideoPlayerScreen()),
            GetPage(
              name: Routes.webViewScreen,
              page: () => const WebViewScreen(),
            )
          ],
        ),
      ),
    );
  }
}
