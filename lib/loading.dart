import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Flex(
        direction: Axis.horizontal,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: appWidth,
            child: Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(value: null),
              ),
            ),
          ),
        ],
      ),
    );
  }
}