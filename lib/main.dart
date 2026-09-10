import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inneed/providers/emergency_contact_provider/emergency_provider.dart';
import 'package:inneed/providers/firstaid_provider/firstaid_provider.dart';
import 'package:inneed/providers/hospital_provider/hospital_provider.dart';
import 'package:inneed/views/splash_screen/splash_screen.dart';
import 'package:inneed/constant/color.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
//load the dotenv first so api can run before starting the app
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Dotenv load error: $e");
  }

  // Firebase initialize
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmergencyProvider()),
        ChangeNotifierProvider(create: (_) => FirstAidProvider()),
        ChangeNotifierProvider(create: (_) => HospitalProvider()),
      ],
      child: MaterialApp(
          title: 'IN NEED',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            primaryColor: AppColors.primaryRed,
            scaffoldBackgroundColor: AppColors.backgroundLight,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryRed),
          ),
          home: const SplashScreen()
      ),
    );
  }
}