import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tea_kadai_split/presentation/ui/dashboard/homescreen.dart';
import 'package:tea_kadai_split/presentation/ui/settings/settings.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
        // padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 25),
        decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Get.to(() => const HomeScreen());
              },
              icon: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: HexColor('#ff967a'),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.home),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: HexColor('#ff967a'),
                  shape: BoxShape.circle,
                ),
                child: Transform.rotate(
                  angle: 3.14 / 2,
                  // alignment: Alignment.center,
                  child: const Icon(Icons.sync_alt),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Get.to(() => const SettingsScreen());
              },
              icon: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: HexColor('#ff967a'),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.settings),
              ),
            ),
          ],
        ));
  }
}
