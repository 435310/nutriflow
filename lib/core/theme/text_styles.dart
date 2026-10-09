import 'package:flutter/material.dart';
import 'colors.dart';

/// ============================================
/// ESTILOS DE TEXTO DO NUTRIFLOW
/// ============================================
/// Cada estilo tem um propósito. Use o nome semântico,
/// não o tamanho (ex: use `AppTextStyles.h1`, não `fontSize: 32`).
class AppTextStyles {
  AppTextStyles._();

  // Título grande (nome do app, telas iniciais)
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Título de seção
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Título de card
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Texto padrão de corpo
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Texto secundário (descrições, subtítulos)
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Texto pequeno (legendas, rodapés)
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  // Texto de botão (ação)
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Texto de link (esqueci senha, criar conta)
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // Texto de campo de input
  static const TextStyle input = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  // Texto de erro (validação de formulário)
  static const TextStyle error = TextStyle(
    fontSize: 13,
    color: AppColors.error,
  );
}