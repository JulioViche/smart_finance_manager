// Atoms - Budget Progress Bar
// Barra de progreso para mostrar gasto vs límite
import 'package:flutter/material.dart';

/// Barra de progreso para presupuestos
class BudgetProgressBar extends StatelessWidget {
  final double percentage;
  final double alertThreshold;
  final double height;

  const BudgetProgressBar({
    super.key,
    required this.percentage,
    required this.alertThreshold,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Determinar color según el porcentaje
    Color progressColor;
    if (percentage >= 1.0) {
      progressColor = const Color(0xFFEF4444); // Rojo - Excedido
    } else if (percentage >= alertThreshold) {
      progressColor = const Color(0xFFF59E0B); // Amarillo - Alerta
    } else {
      progressColor = const Color(0xFF10B981); // Verde - OK
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Barra de progreso
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: constraints.maxWidth * percentage.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
              // Indicador de umbral
              if (alertThreshold > 0 && alertThreshold < 1)
                Positioned(
                  left: constraints.maxWidth * alertThreshold - 1,
                  child: Container(
                    width: 2,
                    height: height,
                    color: colorScheme.outline.withAlpha(128),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
