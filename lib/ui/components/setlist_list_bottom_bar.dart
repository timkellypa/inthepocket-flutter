import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_the_pocket/ui/navigation/application_router.dart';

/// This is the bottom button bar for the home page.  This has a link to a standalone metronome.
/// And settings will go here eventually as well.
class SetlistListBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        decoration: const BoxDecoration(
            border: Border(
          top: BorderSide(color: Colors.grey, width: 0.3),
        )),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Make this button bigger and more obvious
            MaterialButton(
              child: Column(
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/images/metronome-icon.svg',
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary, BlendMode.srcIn),
                  ),
                  Text(
                    'Metronome',
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary),
                  )
                ],
              ),
              onPressed: () {
                Navigator.pushNamed(context, ApplicationRouter.ROUTE_METRONOME);
              },
            ),
          ],
        ),
      ),
    );
  }
}
