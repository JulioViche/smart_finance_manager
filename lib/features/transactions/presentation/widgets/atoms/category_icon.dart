// Atoms - Category Icon
// Ícono de categoría con color personalizado
import 'package:flutter/material.dart';

/// Widget que muestra el ícono de una categoría con su color
class CategoryIcon extends StatelessWidget {
  final String iconCode;
  final String colorHex;
  final double size;
  final bool showBackground;

  const CategoryIcon({
    super.key,
    required this.iconCode,
    required this.colorHex,
    this.size = 40,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(colorHex);
    final iconData = _getIconData(iconCode);

    if (showBackground) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          iconData,
          color: color,
          size: size * 0.5,
        ),
      );
    }

    return Icon(
      iconData,
      color: color,
      size: size * 0.6,
    );
  }

  Color _parseColor(String hex) {
    try {
      final hexCode = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) {
      return const Color(0xFF6366F1); // Índigo por defecto
    }
  }

  /// Mapea códigos de íconos a Material Icons elegantes
  IconData _getIconData(String code) {
    switch (code.toLowerCase()) {
      // Gastos comunes
      case 'food':
      case 'comida':
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'shopping':
      case 'compras':
        return Icons.shopping_bag_rounded;
      case 'transport':
      case 'transporte':
        return Icons.directions_car_rounded;
      case 'entertainment':
      case 'entretenimiento':
        return Icons.movie_rounded;
      case 'health':
      case 'salud':
        return Icons.medical_services_rounded;
      case 'education':
      case 'educacion':
        return Icons.school_rounded;
      case 'home':
      case 'hogar':
        return Icons.home_rounded;
      case 'utilities':
      case 'servicios':
        return Icons.power_rounded;
      case 'subscriptions':
      case 'suscripciones':
        return Icons.subscriptions_rounded;
      case 'gift':
      case 'regalo':
        return Icons.card_giftcard_rounded;
      case 'travel':
      case 'viaje':
        return Icons.flight_rounded;
      case 'fitness':
      case 'gym':
        return Icons.fitness_center_rounded;
      case 'pet':
      case 'mascota':
        return Icons.pets_rounded;
      case 'coffee':
      case 'cafe':
        return Icons.coffee_rounded;
      case 'gas':
      case 'gasolina':
        return Icons.local_gas_station_rounded;
      case 'insurance':
      case 'seguro':
        return Icons.shield_rounded;
      case 'savings':
      case 'ahorro':
        return Icons.savings_rounded;
      case 'investment':
      case 'inversion':
        return Icons.trending_up_rounded;
      // Ingresos
      case 'salary':
      case 'salario':
        return Icons.account_balance_wallet_rounded;
      case 'freelance':
        return Icons.laptop_mac_rounded;
      case 'bonus':
      case 'bono':
        return Icons.card_membership_rounded;
      case 'rental':
      case 'alquiler':
        return Icons.apartment_rounded;
      case 'other':
      case 'otro':
        return Icons.more_horiz_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }
}
