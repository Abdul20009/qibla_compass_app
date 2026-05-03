import 'package:flutter/material.dart';
import 'package:qibla_compass_app/app/core/colors.dart';

class CompassScreen extends StatelessWidget {
  const CompassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroud,
      appBar: AppBar(
        backgroundColor:appBarColor,
        elevation: 0,
        centerTitle: false,
        leading: Icon(
          Icons.menu,
          color: primary,
        ),
        title:  Text(
          'Al-Qibla',
          style: TextStyle(color: primary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: greenAccent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary, width: 1),
              ),
              child: Center(
                child: Padding(padding: EdgeInsetsGeometry.all(10), child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: primary,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                     Text(
                      'London, UK',
                      style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),),
              ),
            ),
          ),
          SizedBox(width: 4,)
        ],
      ),
      body: SafeArea(child: 
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '119°',
                style: TextStyle(color: primary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 5,),
              Text(
                'SE',
                style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.bold),
              )

            ],
          ),
          SizedBox(height: 10,),
          Text(
            'BERING TO MAKKAH',
            style: TextStyle(color: primary, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 20,),
          Image.asset(
            'assets/images/qibla comapss.png',
          ),
        ],
      ))
    );
  }
}