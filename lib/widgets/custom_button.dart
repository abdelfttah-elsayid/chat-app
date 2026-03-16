  import 'package:flutter/material.dart';

  class CustomButton extends StatelessWidget {
    final String text;
    final VoidCallback? onTap;
    final IconData icon;

    const CustomButton({
      super.key,
      required this.text,
      required this.icon,
      this.onTap,
    });

    @override
    Widget build(BuildContext context) {
      return Center(
        child: Container(
          width: 350,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white, // لون الكونتينر
            borderRadius: BorderRadius.circular(25), // نفس حواف الزرار
          ),
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent, // خليه شفاف عشان يبان لون الكونتينر
              shadowColor: Colors.transparent,     // شيل الضل عشان ميبوظش الشكل
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Pacifico',
                    color: Color(0xff2B475E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),


                Icon(
                  icon,
                  color: const Color(0xff2B475E),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }