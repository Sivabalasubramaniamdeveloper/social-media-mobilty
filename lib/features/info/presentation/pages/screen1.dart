import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/base/abstract/base_screen.dart';

class Screen1 extends BaseScreen {
  const Screen1({super.key});

  @override
  Widget buildBody(BuildContext context) {
    return AnimatedBoxScreen();
  }

  @override
  List<Widget>? get actions => [
    IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
  ];

  @override
  Widget? get floatingActionButton =>
      FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add));

  @override
  // TODO: implement title
  String get title => "sssssssss";
  @override
  // TODO: implement backgroundColor
  Color? get backgroundColor => Colors.green;
}

class AnimatedBoxScreen extends HookWidget {
  const AnimatedBoxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create AnimationController
    final controller = useAnimationController(
      duration: const Duration(seconds: 2),
    );

    // Create a tween animation from 0 → 200
    final animation = Tween<double>(begin: 0, end: 200).animate(controller);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated box
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              width: animation.value,
              height: animation.value,
              color: Colors.blue,
            );
          },
        ),
        const SizedBox(height: 20),

        // Buttons to control animation
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => controller.forward(),
              child: const Text("Play"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => controller.reverse(),
              child: const Text("Reverse"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => controller.repeat(reverse: true),
              child: const Text("Loop"),
            ),
          ],
        ),
      ],
    );
  }
}
