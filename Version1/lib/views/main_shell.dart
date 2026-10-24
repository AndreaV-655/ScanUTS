// Shell principal con AppBar, cuerpo dinámico por tab y bottom nav
// Usa AnimatedBuilder con AppProvider para reactividad

import 'package:flutter/material.dart';
import 'package:uts_qr_mantenimiento/logic/types.dart';
import 'package:uts_qr_mantenimiento/providers/app_provider.dart';
import 'package:uts_qr_mantenimiento/components/app_bottom_nav.dart';
import 'package:uts_qr_mantenimiento/views/home/home_view.dart';
import 'package:uts_qr_mantenimiento/views/scan/scan_view.dart';
import 'package:uts_qr_mantenimiento/views/generate_qr/generate_qr_view.dart';
import 'package:uts_qr_mantenimiento/views/reports/reports_view.dart';
import 'package:uts_qr_mantenimiento/views/maint/maint_view.dart';
import 'package:uts_qr_mantenimiento/views/stats/stats_view.dart';
import 'package:uts_qr_mantenimiento/views/profile/profile_view.dart';

class MainShell extends StatelessWidget {
  final AppProvider appProvider;
  const MainShell({super.key, required this.appProvider});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appProvider,
      builder: (context, _) {
        final user = appProvider.user;
        if (user == null) return const SizedBox.shrink();

        // Selecciona vista según tab activo
        Widget body;
        switch (appProvider.activeTab) {
          case 'scan':
            body = ScanView(appProvider: appProvider);
            break;
          case 'generate-qr':
            body = GenerateQrView(appProvider: appProvider);
            break;
          case 'reports':
            body = ReportsView(appProvider: appProvider);
            break;
          case 'maint':
            body = MaintView(appProvider: appProvider);
            break;
          case 'stats':
            body = StatsView(appProvider: appProvider);
            break;
          case 'profile':
            body = ProfileView(appProvider: appProvider);
            break;
          case 'home':
          default:
            body = HomeView(appProvider: appProvider);
            break;
        }

        // Títulos del AppBar
        final titles = <String, String>{
          'home': 'UTS QR Mantenimiento',
          'scan': 'Escanear QR',
          'generate-qr': 'Generar código QR',
          'reports': 'Reportes',
          'maint': 'Órdenes de trabajo',
          'stats': 'Indicadores',
          'profile': 'Mi Perfil',
        };

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UTS',
                  style: TextStyle(fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
                Text(
                  titles[appProvider.activeTab] ?? 'UTS QR Mantenimiento',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => appProvider.setActiveTab('profile'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFF0F766E),
                          child: Text(
                            user.name.isNotEmpty ? user.name.split(' ').first[0] : 'U',
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          user.name.split(' ').first,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: body,
            ),
          ),
          bottomNavigationBar: AppBottomNav(appProvider: appProvider, user: user),
        );
      },
    );
  }
}
