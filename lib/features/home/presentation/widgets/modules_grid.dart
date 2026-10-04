import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../records/domain/entities/resource_spec.dart';
import '../../../records/presentation/widgets/resource_icons.dart';

class ModulesGrid extends StatelessWidget {
  const ModulesGrid({super.key, required this.modules});

  final List<ResourceSpec> modules;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 700 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, i) {
            final m = modules[i];
            return GlassContainer(
              onTap: () => context.push('/records/${m.key}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: AppColors.neonGradient,
                    ),
                    child: Icon(resourceIcon(m.icon), color: AppColors.obsidian),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      if (m.description.isNotEmpty)
                        Text(
                          m.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (50 * i).ms, duration: 300.ms).scaleXY(begin: 0.96);
          },
        );
      },
    );
  }
}
