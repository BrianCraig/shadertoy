import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shader_toy/shader_library.dart';

class TruchetTillingScreen extends StatelessWidget {
  const TruchetTillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Truchet Tilling Shader',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(
            height: 16,
          ),
          Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints.tight(const Size(400, 60)),
              child: OutlinedButton(
                onPressed: () => Navigator.pop(
                  context,
                ),
                style: const ButtonStyle(),
                child: Text(
                  'Back',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          )
        ],
      ),
    );

    return Scaffold(
      body: FragmentProgramBuilder(
        future: FragmentProgram.fromAsset(
            'assets/flutter-shaders/truchet_tiling.glsl'),
        builder: (BuildContext context, FragmentProgram fragmentProgram) =>
            FragmentShaderPaint(
          fragmentProgram: fragmentProgram,
          uniforms: (BuildContext context, double time) => FragmentUniforms(
            transformation: Matrix4.identity()
            ..scale(40.0)
            ..translate(time*.1, time*.1),
            time: time,
          ),
          child: child,
        ),
        child: child,
      ),
    );
  }
}
