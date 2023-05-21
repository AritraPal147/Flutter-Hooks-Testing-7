import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Hooks Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    debugShowCheckedModeBanner: false,
    home: const HomePage(),
  ));
}

/// Reducer is something that takes the current state and a provided action and
/// produces the current state

const url = 'https://bit.ly/3x7J5Qt';

/// [Action] stores the actions that the buttons on the screen can do
///
/// [rotateLeft] will rotate the image to left
/// [rotateRight] will rotate the image to right
/// [moreVisible] will increase opacity
/// [lessVisible] will decrease opacity
enum Action {
  rotateLeft,
  rotateRight,
  moreVisible,
  lessVisible,
}

/// [State] holds and controls the state of the app
///
/// [rotationDeg] stores the rotation angle in degrees
/// [alpha] stores the opacity
///
/// [rotateRight] returns a state with rotation angle increased by 10
/// [rotateLeft] returns a state with rotation angle decreased by 10
/// [increaseAlpha] returns a state with opacity increased by 0.1, but maximum opacity is 1
/// [decreaseAlpha] returns a state with opacity decreased by 0.1, but minimum opacity is 0
@immutable
class State {
  final double rotationDeg;
  final double alpha;

  const State({
    required this.rotationDeg,
    required this.alpha,
  });

  /// Initial state
  const State.zero()
      : rotationDeg = 0.0,
        alpha = 1.0;

  State rotateRight() => State(
        alpha: alpha,
        rotationDeg: rotationDeg + 10,
      );

  State rotateLeft() => State(
        alpha: alpha,
        rotationDeg: rotationDeg - 10,
      );

  State increaseAlpha() => State(
        alpha: min(alpha + 0.1, 1.0),
        rotationDeg: rotationDeg,
      );

  State decreaseAlpha() => State(
        alpha: max(alpha - 0.1, 0.0),
        rotationDeg: rotationDeg,
      );
}

/// [reducer] takes in an old state ([oldState]) and an [action] (part of enum [Action])
/// an returns a new [State].
State reducer(State oldState, Action? action) {
  switch (action) {
    case Action.rotateLeft:
      return oldState.rotateLeft();
    case Action.rotateRight:
      return oldState.rotateRight();
    case Action.moreVisible:
      return oldState.increaseAlpha();
    case Action.lessVisible:
      return oldState.decreaseAlpha();
    case null:
      return oldState;
  }
}

class HomePage extends HookWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// useReducer rebuilds the widgets based on the actions sent to it
    final store = useReducer<State, Action?>(
        (state, action) => reducer(state, action),
        initialState: const State.zero(),
        initialAction: null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              RotateLeftButton(store: store),
              RotateRightButton(store: store),
              DecreaseOpacityButton(store: store),
              IncreaseOpacityButton(store: store),
            ],
          ),
          const SizedBox(height: 100),
          Opacity(
            opacity: store.state.alpha,
            child: RotationTransition(
                turns: AlwaysStoppedAnimation(
                  store.state.rotationDeg / 360,
                ),
                child: Image.network(url)),
          ),
        ],
      ),
    );
  }
}

class IncreaseOpacityButton extends StatelessWidget {
  const IncreaseOpacityButton({
    super.key,
    required this.store,
  });

  final Store<State, Action?> store;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => store.dispatch(Action.moreVisible),
      child: const Text('+ Opacity'),
    );
  }
}

class DecreaseOpacityButton extends StatelessWidget {
  const DecreaseOpacityButton({
    super.key,
    required this.store,
  });

  final Store<State, Action?> store;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => store.dispatch(Action.lessVisible),
      child: const Text('- Opacity'),
    );
  }
}

class RotateRightButton extends StatelessWidget {
  const RotateRightButton({
    super.key,
    required this.store,
  });

  final Store<State, Action?> store;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => store.dispatch(Action.rotateRight),
      child: const Text('Rotate Right'),
    );
  }
}

class RotateLeftButton extends StatelessWidget {
  const RotateLeftButton({
    super.key,
    required this.store,
  });

  final Store<State, Action?> store;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => store.dispatch(Action.rotateLeft),
      child: const Text('Rotate Left'),
    );
  }
}
