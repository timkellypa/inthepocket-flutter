import 'package:flutter/material.dart';
import 'package:in_the_pocket/services/service_locator.dart';
import 'package:in_the_pocket/ui/navigation/application_router.dart';

void main() async {
  setupServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        onGenerateRoute: ApplicationRouter.onGenerateRoute,
        initialRoute: ApplicationRouter.initialRoute,
        routes: ApplicationRouter.routes,
        debugShowCheckedModeBanner: false,
        title: 'In the Pocket',
        theme: ThemeData(
            primarySwatch: Colors.indigo, canvasColor: Colors.transparent));
  }
}
