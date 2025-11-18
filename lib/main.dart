import 'dart:convert';

import 'package:expense_tracker/core/constants/colors.dart';
import 'package:expense_tracker/features/auth_onboarding/data/models/user_model.dart';
import 'package:expense_tracker/features/auth_onboarding/data/repositories/auth_repository_impl.dart';
import 'package:expense_tracker/features/auth_onboarding/domain/usecases/add_wallet.dart';
import 'package:expense_tracker/features/auth_onboarding/domain/usecases/set_pin.dart';
import 'package:expense_tracker/features/auth_onboarding/domain/usecases/signup.dart';
import 'package:expense_tracker/features/auth_onboarding/domain/usecases/verify_otp.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/landing_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/auth_onboarding/data/datasources/local_auth_datasource.dart';
import 'core/utils/secure_pin_manager.dart';
import 'features/auth_onboarding/presentation/pages/pin_unlock_page.dart';
import 'routing/app_router.dart';
import 'features/home/data/models/txn_model.dart';
import 'features/home/data/repositories/home_repository.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/home/presentation/bloc/home_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:month_year_picker/month_year_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  await Firebase.initializeApp();

  await Hive.initFlutter();

  Hive.registerAdapter(WalletModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(TxnModelAdapter());

  const secure = FlutterSecureStorage();

  String? key = await secure.read(key: "hive_key");
  if (key == null) {
    final generated = Hive.generateSecureKey();
    await secure.write(key: "hive_key", value: base64UrlEncode(generated));
    key = await secure.read(key: "hive_key");
  }

  final encryptionKey = base64Url.decode(key!);

  await Hive.openBox<UserModel>(
    'userBox',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
  await Hive.openBox(
    'settingsBox',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
  await Hive.openBox<TxnModel>(
    'txnsBox',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
  // Ensure we have a Firebase user for Firestore streams during development
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }

  // Build repositories and blocs once at app start so hot reload doesn't recreate them
  final local = LocalAuthDataSourceImpl(
    userBox: Hive.box<UserModel>('userBox'),
    settingsBox: Hive.box('settingsBox'),
  );
  final authRepo = AuthRepositoryImpl(local);
  final signup = SignupUseCase(authRepo);
  final verify = VerifyOtpUseCase();
  final setPin = SetPinUseCase(SecurePinManager());
  final addWallet = AddWalletUseCase(authRepo);
  final homeRepo = HomeRepositoryFirestore();

  runApp(
    MultiRepositoryProvider(
      providers: [RepositoryProvider<HomeRepository>(create: (_) => homeRepo)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => OnboardingBloc(
              signupUseCase: signup,
              verifyOtpUseCase: verify,
              setPinUseCase: setPin,
              addWalletUseCase: addWallet,
            ),
          ),
          BlocProvider(
            create: (ctx) =>
                HomeBloc(ctx.read<HomeRepository>(), FirebaseAuth.instance)
                  ..add(LoadInitialHome()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  bool _wasPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      // 2. Set the flag when the app goes into the deep background.
      // This state usually indicates the user has left the app (e.g., pressed Home).
      _wasPaused = true;
    } else if (state == AppLifecycleState.resumed) {
      // 3. Only trigger the PIN check if the app is resuming
      // AND was previously in the deep background state.
      if (_wasPaused) {
        _handleResume();
      }
      // Reset the flag immediately after checking.
      _wasPaused = false;
    }
    // Note: AppLifecycleState.inactive is often used when an overlay appears,
    // but the app doesn't usually hit AppLifecycleState.paused in that scenario.
  }

  Future<void> _handleResume() async {
    if (_navKey.currentState?.widget.pages.any(
          (page) => page.runtimeType == PinUnlockPage,
        ) ??
        false) {
      return;
    }

    final hasPin = await SecurePinManager().hasPin();
    if (!hasPin) return;

    final nav = _navKey.currentState;
    if (nav == null) return;

    nav.push(MaterialPageRoute(builder: (_) => const PinUnlockPage()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: LandingScreen(),
    );
  }
}
