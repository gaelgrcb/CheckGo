import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/service_locator.dart';
import 'features/attendance/presentation/pages/clock_in_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Establecer barra de estado translúcida/estilizada
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Inicializar Inyección de Dependencias (Incluye Isar)
  await initServiceLocator();

  runApp(const CheckGoApp());
}

class CheckGoApp extends StatelessWidget {
  const CheckGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E40AF); // Blue 800

    return MaterialApp(
      title: 'CheckGo - Control de Asistencia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
          primary: primaryColor,
          secondary: const Color(0xFF059669), // Emerald
          surface: const Color(0xFFF8FAFC), // Slate 50
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Slate 100
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.blueGrey.withValues(alpha: 0.12), width: 1),
          ),
          color: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: false,
        ),
      ),
      home: const ClockInPage(),
    );
  }
}
