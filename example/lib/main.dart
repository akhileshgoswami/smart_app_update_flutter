import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_app_update_flutter/smart_app_update_flutter.dart';
// import 'package:smart_app_update_flutter/smart_app_update.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Check for update on app start (without custom API)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppUpdateManager.checkAndPrompt(
          forceUpdate: false, repeat_totalminutes: 60, notes: "");
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed &&
        !UpdateBottomSheet.isUpdateDialogShowing.value) {
      AppUpdateManager.checkAndPrompt(
          forceUpdate: false, repeat_totalminutes: 60, notes: "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart App Update Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Smart App Update Demo')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await AppUpdateManager.checkAndPrompt(
                  forceUpdate: false,
                  repeat_totalminutes: 60,
                  notes: "Akhilesh");
            },
            child: const Text('Check for Update'),
          ),
        ),
      ),
    );
  }
}
