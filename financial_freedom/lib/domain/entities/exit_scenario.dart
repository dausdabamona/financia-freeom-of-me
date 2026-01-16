import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Exit Scenario represents a "What If" scenario for the exit simulation.
///
/// Philosophy: Every scenario is a potential future you can choose.
/// Not to scare, but to empower decision-making.
class ExitScenario extends Equatable {
  final String id;
  final String name;
  final String description;
  final double weeklyBurnModifier; // Multiplier (e.g., 0.9 = 10% reduction)
  final double weeklyIncomeModifier; // Addition (e.g., 250000 = +1jt/month)
  final double debtReductionAmount; // One-time debt payoff
  final bool isDefault;
  final bool isBaseline;
  final DateTime createdAt;

  const ExitScenario({
    required this.id,
    required this.name,
    required this.description,
    this.weeklyBurnModifier = 1.0,
    this.weeklyIncomeModifier = 0.0,
    this.debtReductionAmount = 0.0,
    this.isDefault = false,
    this.isBaseline = false,
    required this.createdAt,
  });

  /// Default scenarios that ship with the app
  static List<ExitScenario> get defaultScenarios => [
        ExitScenario(
          id: 'baseline',
          name: 'Tanpa Gaji',
          description: 'Simulasi jika gaji berhenti hari ini, tanpa perubahan lain.',
          weeklyBurnModifier: 1.0,
          weeklyIncomeModifier: 0.0,
          isDefault: true,
          isBaseline: true,
          createdAt: DateTime.now(),
        ),
        ExitScenario(
          id: 'reduce_10',
          name: 'Biaya Turun 10%',
          description: 'Bagaimana jika kamu berhemat 10% dari pengeluaran?',
          weeklyBurnModifier: 0.9,
          weeklyIncomeModifier: 0.0,
          isDefault: true,
          createdAt: DateTime.now(),
        ),
        ExitScenario(
          id: 'add_income',
          name: 'Tambah Income Alternatif',
          description: 'Bagaimana jika ada pemasukan tambahan Rp 1 juta/bulan?',
          weeklyBurnModifier: 1.0,
          weeklyIncomeModifier: 1000000 / 4.33, // ~230k per week
          isDefault: true,
          createdAt: DateTime.now(),
        ),
        ExitScenario(
          id: 'pay_debt',
          name: 'Lunasi Satu Hutang',
          description: 'Bagaimana jika cicilan bulanan berkurang?',
          weeklyBurnModifier: 0.85, // Assume debt is ~15% of burn
          weeklyIncomeModifier: 0.0,
          isDefault: true,
          createdAt: DateTime.now(),
        ),
      ];

  /// Icon for this scenario
  IconData get icon {
    if (isBaseline) return Icons.remove_circle_outline;
    if (weeklyBurnModifier < 1.0) return Icons.trending_down;
    if (weeklyIncomeModifier > 0) return Icons.trending_up;
    if (debtReductionAmount > 0) return Icons.credit_card_off;
    return Icons.compare_arrows;
  }

  /// Color for this scenario
  Color get color {
    if (isBaseline) return Colors.grey;
    if (weeklyBurnModifier < 1.0) return Colors.blue;
    if (weeklyIncomeModifier > 0) return Colors.green;
    if (debtReductionAmount > 0) return Colors.purple;
    return Colors.teal;
  }

  /// Human-readable impact description
  String get impactDescription {
    final parts = <String>[];

    if (weeklyBurnModifier != 1.0) {
      final percent = ((1 - weeklyBurnModifier) * 100).abs().toStringAsFixed(0);
      if (weeklyBurnModifier < 1.0) {
        parts.add('Pengeluaran -$percent%');
      } else {
        parts.add('Pengeluaran +$percent%');
      }
    }

    if (weeklyIncomeModifier != 0) {
      final monthly = (weeklyIncomeModifier * 4.33).round();
      if (monthly >= 1000000) {
        parts.add('Income +Rp ${(monthly / 1000000).toStringAsFixed(1)}Jt/bln');
      } else {
        parts.add('Income +Rp ${(monthly / 1000).toStringAsFixed(0)}Rb/bln');
      }
    }

    if (debtReductionAmount > 0) {
      parts.add('Hutang lunas Rp ${(debtReductionAmount / 1000000).toStringAsFixed(1)}Jt');
    }

    if (parts.isEmpty) {
      return 'Tanpa perubahan';
    }

    return parts.join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        weeklyBurnModifier,
        weeklyIncomeModifier,
        debtReductionAmount,
        isDefault,
        isBaseline,
        createdAt,
      ];

  ExitScenario copyWith({
    String? id,
    String? name,
    String? description,
    double? weeklyBurnModifier,
    double? weeklyIncomeModifier,
    double? debtReductionAmount,
    bool? isDefault,
    bool? isBaseline,
    DateTime? createdAt,
  }) {
    return ExitScenario(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      weeklyBurnModifier: weeklyBurnModifier ?? this.weeklyBurnModifier,
      weeklyIncomeModifier: weeklyIncomeModifier ?? this.weeklyIncomeModifier,
      debtReductionAmount: debtReductionAmount ?? this.debtReductionAmount,
      isDefault: isDefault ?? this.isDefault,
      isBaseline: isBaseline ?? this.isBaseline,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
