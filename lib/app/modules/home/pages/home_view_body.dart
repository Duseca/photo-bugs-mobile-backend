// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../shared/widgets/optimized_animated_container.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final bool enableAnimations = !kIsWeb || !kReleaseMode;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return OptimizedAnimatedContainer(
            shouldAnimate: enableAnimations,
            child: _buildResponsiveLayout(constraints),
          );
        },
      ),
    );
  }

  Widget _buildResponsiveLayout(BoxConstraints constraints) {
    if (constraints.maxWidth >= 1200) {
      return _buildDesktopLayout();
    } else if (constraints.maxWidth >= 600) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildMobileLayout() {
    return CustomScrollView(
      // Use cacheExtent to improve scrolling performance
      cacheExtent: 100.0,
      slivers: [
        SliverToBoxAdapter(
          child: RepaintBoundary(
            child: Container(height: 200, color: Colors.blue),
          ),
        ),
        // Add more optimized widgets
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [Expanded(flex: 2, child: Container(color: Colors.blue))],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(flex: 1, child: Container(color: Colors.white)),
        Expanded(flex: 2, child: Container(color: Colors.blue)),
        Expanded(flex: 1, child: Container(color: Colors.white)),
      ],
    );
  }

  // Similar optimizations for tablet and desktop layouts...
}
