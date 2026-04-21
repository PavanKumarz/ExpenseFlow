import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFF2F4F7),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _section("APPEARANCE", [
              _tile(
                icon: Icons.wb_sunny_outlined,
                title: "Dark Mode",
                trailing: Transform.scale(
                  scale: 0.85,
                  child: Switch(value: false, onChanged: (v) {}),
                ),
              ),
            ]),

            const SizedBox(height: 20),

            _section("GENERAL", [
              _tile(
                icon: Icons.attach_money,
                title: "Currency",
                trailing: const Text(
                  "USD",
                  style: TextStyle(fontSize: 14, color: Color(0xFF667085)),
                ),
              ),
              _divider(),
              _tile(icon: Icons.sell_outlined, title: "Categories"),
            ]),

            const SizedBox(height: 20),

            _section("DATA MANAGEMENT", [
              _tile(
                icon: Icons.download_outlined,
                title: "Export Data",
                subtitle: "Save backup to device",
              ),
              _divider(),
              _tile(
                icon: Icons.upload_outlined,
                title: "Import Data",
                subtitle: "Restore from backup",
              ),
              _divider(),
              _tile(
                icon: Icons.delete_outline,
                title: "Reset All Data",
                subtitle: "Delete all transactions",
                titleColor: Colors.red,
                iconBg: const Color(0xFFFEE4E2),
                iconColor: Colors.red,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF667085),
            ),
          ),
        ),
        Container(
          decoration: _card(),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    Color? iconBg,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: iconBg ?? const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? const Color(0xFF344054),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? const Color(0xFF101828),
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          trailing ??
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFF98A2B3),
              ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 0.8,
      indent: 70,
      color: Color(0xFFE4E7EC),
    );
  }

  BoxDecoration _card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
