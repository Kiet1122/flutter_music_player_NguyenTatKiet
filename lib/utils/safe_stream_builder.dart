import 'package:flutter/material.dart';

class SafeStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final T initialData;
  final Widget Function(BuildContext, AsyncSnapshot<T>) builder;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  const SafeStreamBuilder({
    super.key,
    required this.stream,
    required this.initialData,
    required this.builder,
    this.errorWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Stream error: ${snapshot.error}');
          return errorWidget ?? Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? const Center(
            child: CircularProgressIndicator(),
          );
        }

        return builder(context, snapshot);
      },
    );
  }
}