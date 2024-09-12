import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tea_kadai_split/presentation/components/navigation_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ////HexColor('#fd784c'),
                  HexColor('#fe8953'),
                  HexColor('#fd9957'),
                  HexColor('#fcc364'),
                ],
              ),
            ),
          ),
          Column(
            children: [],
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}
