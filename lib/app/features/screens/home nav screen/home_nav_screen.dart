import 'package:flutter/material.dart';
import 'package:qibla_compass_app/app/core/colors.dart';
import 'package:qibla_compass_app/app/features/screens/home%20nav%20screen/bottom%20navigation%20screen/compass_screen.dart';
import 'package:qibla_compass_app/app/features/screens/home%20nav%20screen/bottom%20navigation%20screen/mosques_screen.dart';
import 'package:qibla_compass_app/app/features/screens/home%20nav%20screen/bottom%20navigation%20screen/prayers_screen.dart';
import 'package:qibla_compass_app/app/features/screens/home%20nav%20screen/bottom%20navigation%20screen/settings_screen.dart';

class HomeNav extends StatefulWidget {
  final int initialIndex;

  const HomeNav({super.key, this.initialIndex = 0});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> with TickerProviderStateMixin {
  late TabController _tabController;
  int tab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    tab = widget.initialIndex;
    _tabController.addListener(() {
      setState(() {
        tab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x400991ff),
              offset: Offset(0, -2),
              spreadRadius: 0,
              blurRadius: 4,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          dividerColor: white,
          labelColor: primary ,
          unselectedLabelColor: Color(0xff065F46),
          indicatorColor: primary,
          labelPadding: EdgeInsets.symmetric(horizontal: 4),
          isScrollable: false,
          tabs: [
            Tab(
              icon: Icon(Icons.compass_calibration,
                  color: tab == 0 ? primary : greenAccent),
              text: 'Compass' ,
              
            ),
            Tab(
              icon: Icon(Icons.panorama_fisheye_rounded,
                  color: tab == 1 ? primary : greenAccent),
              text: 'Prayers',
            ),
           
            Tab(
              icon: Icon(Icons.mosque,
                  color: tab == 2 ? primary : greenAccent),
              text: 'Mosques',
            ),
            Tab(
              icon: Icon(Icons.settings,
                  color: tab == 3 ? primary : greenAccent),
              text: 'Settings',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
        CompassScreen(),
        PrayersScreen(),
        MosquesScreen(),
        SettingsScreen(),
        ],
      ),
    );
  }
}
