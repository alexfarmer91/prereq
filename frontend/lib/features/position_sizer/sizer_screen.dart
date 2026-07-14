import 'package:flutter/material.dart';

import 'kelly_sizer.dart';

/// Standalone `/sizer` route hosting the Kelly sizer without market context.
class SizerScreen extends StatelessWidget {
  const SizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Position sizer')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: const KellySizer(),
          ),
        ),
      ),
    );
  }
}
