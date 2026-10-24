// Barra de navegación inferior reutilizable
// Muestra tabs según el rol: Reportante o Soporte Técnico
// Usa AppProvider para cambiar de tab activo

import 'package:flutter/material.dart';
import 'package:uts_qr_mantenimiento/logic/types.dart';
import 'package:uts_qr_mantenimiento/providers/app_provider.dart';

class AppBottomNav extends StatelessWidget {
  final AppProvider appProvider;
  final UserSession user;
  const AppBottomNav({super.key, required this.appProvider, required this.user});

  @override
  Widget build(BuildContext context) {
    final isSoporte = user.role == Role.soporteTecnico;
    // Items según rol
    final items = <_NavItem>[
      const _NavItem(key: 'home', icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Inicio'),
      if (!isSoporte)
        const _NavItem(key: 'scan', icon: Icons.qr_code_scanner_outlined, activeIcon: Icons.qr_code_scanner, label: 'Escanear'),
      if (isSoporte)
        const _NavItem(key: 'generate-qr', icon: Icons.qr_code_outlined, activeIcon: Icons.qr_code, label: 'Generar QR'),
      const _NavItem(key: 'reports', icon: Icons.assignment_outlined, activeIcon: Icons.assignment, label: 'Reportes'),
      if (isSoporte)
        const _NavItem(key: 'maint', icon: Icons.build_outlined, activeIcon: Icons.build, label: 'Mantenimiento'),
      if (isSoporte)
        const _NavItem(key: 'stats', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Indicadores'),
      const _NavItem(key: 'profile', icon: Icons.person_outline, activeIcon: Icons.person, label: 'Perfil'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final active = appProvider.activeTab == item.key;
              return InkWell(
                onTap: () => appProvider.setActiveTab(item.key),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? item.activeIcon : item.icon,
                        size: 22,
                        color: active ? const Color(0xFF0F766E) : Colors.black54,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          color: active ? const Color(0xFF0F766E) : Colors.black54,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// Modelo interno para items de navegación
class _NavItem {
  final String key;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.key, required this.icon, required this.activeIcon, required this.label});
}
