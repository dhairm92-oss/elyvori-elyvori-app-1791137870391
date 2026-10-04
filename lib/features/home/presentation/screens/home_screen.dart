import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/neon_background.dart';
import '../../../registry.dart';
import '../widgets/modules_grid.dart';

/// Home of a standalone (offline-first) app: one tile per module.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider).valueOrNull ?? true;
    final title = ref.watch(appConfigProvider).appName;
    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            children: [
              ShaderMask(
                shaderCallback: (b) => AppColors.neonGradient.createShader(b),
                child: Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
              const SizedBox(height: 4),
              Text(
                online ? 'Everything is saved on your device and works offline.' : 'Offline — your data is safe on this device.',
                style: TextStyle(color: online ? AppColors.textSecondary : AppColors.amber),
              ),
              const SizedBox(height: 20),
              if (appResources.isEmpty)
                const GlassContainer(child: Text('No modules yet.'))
              else
                const ModulesGrid(modules: appResources),
            ],
          ),
        ),
      ),
    );
  }
}
