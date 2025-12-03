import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Earnings'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body:Column(
        children: [
           const IconAndTextWidget(
              icon: Icons.arrow_back_ios,
              text: 'Back to home',
              iconColor: Colors.blueGrey,
              isBackArrow: true,
            ),
          SizedBox(height: 30.h),
            Center(
        child: Text('Earnings Page Content Here'),
      ),
        ],
      )
     
    );
  }
}