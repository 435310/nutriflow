import 'package:flutter/material.dart';

/// ============================================
/// AVATAR DO USUÁRIO (com iniciais)
/// ============================================
/// Mostra as iniciais do nome em um círculo colorido.
/// A cor é gerada automaticamente a partir do nome.
class UserAvatar extends StatelessWidget {
  final String name;
  final UserAvatarSize size;
  final Color? customColor;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = UserAvatarSize.medium,
    this.customColor,
  });

  // ============================================
  // PALETA DE CORES
  // ============================================
  // 8 cores distintas e harmônicas. A cor do avatar
  // é escolhida com base no nome do usuário.
  static const List<Color> _palette = [
    Color(0xFF1FA774), // Verde NutriFlow
    Color(0xFF2F80ED), // Azul
    Color(0xFF9B51E0), // Roxo
    Color(0xFFF2994A), // Laranja
    Color(0xFFEB5757), // Vermelho
    Color(0xFF2D9CDB), // Azul claro
    Color(0xFF27AE60), // Verde escuro
    Color(0xFFBB6BD9), // Lilás
  ];

  // ============================================
  // PEGA AS INICIAIS DO NOME
  // ============================================
  // "Maria Silva"     → "MS"
  // "João Pedro S."   → "JP"
  // "Ana"             → "AN"
  // ""                → "?" (fallback)
  String _getInitials() {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';

    final parts = trimmed.split(RegExp(r'\s+'));

    // Se só tem uma palavra, pega as 2 primeiras letras
    if (parts.length == 1) {
      final word = parts[0];
      if (word.length >= 2) {
        return word.substring(0, 2).toUpperCase();
      }
      return word.toUpperCase();
    }

    // Se tem 2+ palavras, pega a 1ª letra da primeira e da última
    final first = parts.first[0];
    final last = parts.last[0];
    return '$first$last'.toUpperCase();
  }

  // ============================================
  // ESCOLHE A COR BASEADA NO NOME
  // ============================================
  Color _getColor() {
    if (customColor != null) return customColor!;

    final trimmed = name.trim();
    if (trimmed.isEmpty) return _palette[0];

    // Pega o código Unicode do primeiro caractere
    final code = trimmed.codeUnitAt(0);
    // Aplica módulo para escolher uma cor da paleta
    return _palette[code % _palette.length];
  }

  // ============================================
  // TAMANHO EM PIXELS
  // ============================================
  double _getDiameter() {
    switch (size) {
      case UserAvatarSize.small:
        return 40;
      case UserAvatarSize.medium:
        return 56;
      case UserAvatarSize.large:
        return 96;
    }
  }

  double _getFontSize() {
    switch (size) {
      case UserAvatarSize.small:
        return 14;
      case UserAvatarSize.medium:
        return 20;
      case UserAvatarSize.large:
        return 32;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final diameter = _getDiameter();
    final fontSize = _getFontSize();

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: diameter / 4,
            offset: Offset(0, diameter / 12),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _getInitials(),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ============================================
// TAMANHOS DISPONÍVEIS
// ============================================
enum UserAvatarSize {
  small,  // 40px — listas
  medium, // 56px — header
  large,  // 96px — perfil
}