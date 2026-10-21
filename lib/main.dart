import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

/// ============================================
/// PONTO DE ENTRADA DO NUTRIFLOW
/// ============================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⚠️ INICIALIZA O SUPABASE
  await Supabase.initialize(
    url: 'https://omkxnqyvpuirxfksfskq.supabase.co' ,
    anonKey: 'sb_publishable_g_7yS7U3J91avgNAbYqCAw_-WUVhGiv',
  );

  runApp(const NutriFlowApp());
}