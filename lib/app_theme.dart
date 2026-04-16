import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0C0F1A);
  static const card = Color(0xFF13172A);
  static const cardHover = Color(0xFF1A1F35);
  static const inputBg = Color(0xFF0E1224);
  static const text = Color(0xFFF0F2FF);
  static const muted = Color(0xFF7B82A8);
  static const border = Color(0xFF6C8EFF);

  static const gold = Color(0xFFF4C06F);
  static const blue = Color(0xFF6C8EFF);
  static const purple = Color(0xFFA78BFA);
}

class AppWidgets {
  static Widget backAndBadge({
    required BuildContext context,
    required String badgeLabel,
    required Color badgeColor,
    required VoidCallback onBack,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              border: Border.all(color: AppColors.blue.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, size: 14, color: AppColors.blue),
                const SizedBox(width: 6),
                const Text('Change role',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.blue)),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.1),
            border: Border.all(color: badgeColor.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(width: 6, height: 6,
                  decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(badgeLabel,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: badgeColor)),
            ],
          ),
        ),
      ],
    );
  }

  static Widget headline(String line1, String line2, Color accentColor) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'DMSerifDisplay',
          fontSize: 32, color: AppColors.text, height: 1.2,
        ),
        children: [
          TextSpan(text: '$line1\n'),
          TextSpan(text: line2,
              style: TextStyle(fontStyle: FontStyle.italic, color: accentColor)),
        ],
      ),
    );
  }

  static Widget fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text.toUpperCase(),
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w500,
            color: AppColors.muted, letterSpacing: 0.06)),
  );

  static Widget inputField({
    required IconData icon,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.inputBg,
          border: Border.all(color: AppColors.blue.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.muted.withOpacity(0.5), fontSize: 13),
            prefixIcon: Icon(icon, color: AppColors.muted, size: 18),
            suffixIcon: suffix,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  static Widget primaryButton(String text, Color color, VoidCallback onTap) {
    // Decide text color: dark on gold, white on blue/purple
    final textColor = color == AppColors.gold ? const Color(0xFF1A0E00) : Colors.white;
    return SizedBox(
      width: double.infinity, height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(text,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
      ),
    );
  }

  static Widget secondaryButton(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.3)),
          backgroundColor: color.withOpacity(0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(text,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
      ),
    );
  }

  static Widget footerNote(String plain, String link, VoidCallback? onTap) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
            children: [
              TextSpan(text: plain),
              TextSpan(text: link,
                  style: const TextStyle(color: AppColors.blue)),
            ],
          ),
        ),
      ),
    );
  }

  static Widget screenShell({required Widget child}) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: child,
        ),
      ),
    );
  }
}