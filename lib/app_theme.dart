import 'package:flutter/material.dart';

// ── Static accent colors (same in both modes) ──────────────────────────────
class AppColors {
  static const gold   = Color(0xFFF4C06F);
  static const blue   = Color(0xFF6C8EFF);
  static const purple = Color(0xFFA78BFA);

  // ── Dark palette ───────────────────────────────────────────────────────
  static const _darkBg       = Color(0xFF0C0F1A);
  static const _darkCard     = Color(0xFF13172A);
  static const _darkInputBg  = Color(0xFF0E1224);
  static const _darkText     = Color(0xFFF0F2FF);
  static const _darkMuted    = Color(0xFF7B82A8);
  static const _darkBorder   = Color(0xFF6C8EFF);

  // ── Light palette ──────────────────────────────────────────────────────
  static const _lightBg      = Color(0xFFF4F6FF);
  static const _lightCard    = Color(0xFFFFFFFF);
  static const _lightInputBg = Color(0xFFEDF0FF);
  static const _lightText    = Color(0xFF0D1030);
  static const _lightMuted   = Color(0xFF6B7280);
  static const _lightBorder  = Color(0xFF6C8EFF);

  // ── Context-aware accessors ────────────────────────────────────────────
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bg(BuildContext context) =>
      _isDark(context) ? _darkBg : _lightBg;

  static Color card(BuildContext context) =>
      _isDark(context) ? _darkCard : _lightCard;

  static Color inputBg(BuildContext context) =>
      _isDark(context) ? _darkInputBg : _lightInputBg;

  static Color text(BuildContext context) =>
      _isDark(context) ? _darkText : _lightText;

  static Color muted(BuildContext context) =>
      _isDark(context) ? _darkMuted : _lightMuted;

  static Color border(BuildContext context) =>
      _isDark(context) ? _darkBorder : _lightBorder;
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
            child: const Row(
              children: [
                Icon(Icons.arrow_back, size: 14, color: AppColors.blue),
                SizedBox(width: 6),
                Text(
                  'Change role',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.blue,
                  ),
                ),
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
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                badgeLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: badgeColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget headline(
      BuildContext context,
      String line1,
      String line2,
      Color accentColor,
      ) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'DMSerifDisplay',
          fontSize: 32,
          color: AppColors.text(context),
          height: 1.2,
        ),
        children: [
          TextSpan(text: '$line1\n'),
          TextSpan(
            text: line2,
            style: TextStyle(fontStyle: FontStyle.italic, color: accentColor),
          ),
        ],
      ),
    );
  }

  static Widget fieldLabel(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.muted(context),
        letterSpacing: 0.06,
      ),
    ),
  );

  static Widget inputField(
      BuildContext context, {
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
          color: AppColors.inputBg(context),
          border: Border.all(color: AppColors.border(context).withOpacity(0.2)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: TextStyle(color: AppColors.text(context), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.muted(context).withOpacity(0.5),
              fontSize: 13,
            ),
            prefixIcon: Icon(icon, color: AppColors.muted(context), size: 18),
            suffixIcon: suffix,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  static Widget primaryButton(String text, Color color, VoidCallback onTap) {
    final textColor =
    color == AppColors.gold ? const Color(0xFF1A0E00) : Colors.white;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  static Widget secondaryButton(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.3)),
          backgroundColor: color.withOpacity(0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color),
        ),
      ),
    );
  }

  static Widget footerNote(
      BuildContext context,
      String plain,
      String link,
      VoidCallback? onTap,
      ) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 12, color: AppColors.muted(context)),
            children: [
              TextSpan(text: plain),
              TextSpan(
                text: link,
                style: const TextStyle(color: AppColors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget screenShell({
    required BuildContext context,
    required Widget child,
  }) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: child,
        ),
      ),
    );
  }
}