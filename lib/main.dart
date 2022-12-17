import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shader_toy/screens/shader_demo_screen.dart';
import 'package:shader_toy/screens/truchet_tiling_screen.dart';
import 'package:shader_toy/shaders/noise_gradient_painter.dart';
import 'package:shader_toy/time_animation_builder.dart';

late DateTime now;

late FragmentProgram fp;
late FragmentProgram noiseGradientProgram;
late FragmentProgram truchetTilingProgram;
late FragmentProgram debugProgram;

Future<T> debugTime<T>(Future<T> original, String name) async {
  final start = DateTime.now();
  final output = await original;
  print(
      '[$name] took ${DateTime.now().difference(start).inMicroseconds.toString()} microseconds');
  return output;
}

T debugTimeSync<T>(T Function() original, String name) {
  final start = DateTime.now();
  final output = original();
  print(
      '[$name] took ${DateTime.now().difference(start).inMicroseconds.toString()} microseconds');
  return output;
}

void main() async {
  now = DateTime.now();
  noiseGradientProgram = await debugTime(
    FragmentProgram.fromAsset(
        'assets/flutter-shaders/noise_gradient_fragment.glsl'),
    'ng fp',
  );
  truchetTilingProgram = await debugTime(
    FragmentProgram.fromAsset('assets/flutter-shaders/truchet_tiling.glsl'),
    'tt fp',
  );
  debugProgram = await debugTime(
    FragmentProgram.fromAsset('assets/flutter-shaders/debug.glsl'),
    'debug fp',
  );

  runApp(const FlutterApp());
}

final tweenScale = TweenSequence<double>(
  <TweenSequenceItem<double>>[
    TweenSequenceItem<double>(
      tween: Tween<double>(begin: 0.9, end: 1.2).chain(
        CurveTween(curve: Curves.ease),
      ),
      weight: 40.0,
    ),
    TweenSequenceItem<double>(
      tween: Tween<double>(begin: 1.2, end: 0.9).chain(
        CurveTween(curve: Curves.ease),
      ),
      weight: 40.0,
    ),
  ],
);

class FlutterApp extends StatelessWidget {
  const FlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: TimeAnimationBuilder(
          builder: (context, double time, child) => NoiseGradientPainterWidget(
            fragmentProgram: noiseGradientProgram,
            scale: tweenScale.transform(time / 6 % 1.0),
            offset: Offset(sin(time) * 0.1, time / 3),
            steps: ((sin(time) + 1) * 6.0 + 2.0).toInt(),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Shaders test',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16,),
                  Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints.tight(const Size(400, 60)),
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, _, __) =>
                                const TruchetTillingScreen(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        ),
                        style: const ButtonStyle(),
                        child: Text(
                          'See more shaders',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16,),
                  Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints.tight(const Size(400, 60)),
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, _, __) => ShaderDemoScreen(
                              fragmentProgram: debugProgram,
                            ),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        ),
                        style: const ButtonStyle(),
                        child: Text(
                          'See Debug shader',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedNoiseGradientPainterWidget extends AnimatedWidget {
  final Widget child;

  const AnimatedNoiseGradientPainterWidget({
    super.key,
    required this.child,
    required Animation<double> animation,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return NoiseGradientPainterWidget(
      fragmentProgram: noiseGradientProgram,
      scale: animation.value,
      child: child,
    );
  }
}
