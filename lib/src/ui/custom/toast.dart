// import 'package:flutter/material.dart';

// void showSnackBar(
//   BuildContext context,
//   String message, {
//   Color color = const Color(0xffA855F7),
// }) {
//   ScaffoldMessenger.of(context).hideCurrentSnackBar();

//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       duration: const Duration(seconds: 1),
//       backgroundColor: const Color(0xFF1F1F1F),
//       content: Row(
//         children: [
//           Icon(
//             Icons.info_outline,
//             color: color,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               message,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }



import 'package:flutter/material.dart';
import 'package:landpage/src/utils/colors.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  Color color = AppColors.accentMid,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 1),
      backgroundColor: AppColors.snackBarBg,
      content: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}