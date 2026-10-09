import 'package:flutter/material.dart';

/// ============================================
/// PALETA DE CORES DO NUTRIFLOW
/// ============================================
/// Todas as cores do app estão centralizadas aqui.
/// Para mudar a identidade visual, altere apenas este arquivo.
class AppColors {
  AppColors._(); // impede instanciar a classe

  // Cores principais da marca
  static const Color primary = Color(0xFF1FA774);      // Verde NutriFlow
  static const Color secondary = Color(0xFF2F80ED);    // Azul (nutricionista)

  // Cores de fundo
  static const Color background = Color(0xFFF8FAFC);   // Cinza bem claro
  static const Color surface = Color(0xFFFFFFFF);      // Branco (cards)

  // Cores de texto
  static const Color textPrimary = Color(0xFF1F2937);   // Cinza escuro
  static const Color textSecondary = Color(0xFF64748B); // Cinza médio
  static const Color textHint = Color(0xFF94A3B8);      // Cinza claro

  // Cores de estado
  static const Color error = Color(0xFFEF4444);   // Vermelho
  static const Color success = Color(0xFF10B981); // Verde sucesso
  static const Color warning = Color(0xFFF59E0B); // Amarelo alerta

  // Cores de borda e divisor
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Cores de input (campos de texto)
  static const Color inputFill = Color(0xFFF8FAFC);
  static const Color inputBorder = Color(0xFFE2E8F0);
}