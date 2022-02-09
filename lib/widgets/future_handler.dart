import 'package:flutter/material.dart';

class FutureHandler extends StatelessWidget {
  FutureHandler({
    this.future,
    @required this.onDone,
    this.onError,
    this.onNotDone,
  });

  final Future future;
  final Widget Function() onNotDone;
  final Widget Function() onDone;
  final Widget Function() onError;

  @override
  Widget build(BuildContext context) {
    if (future == null) {
      return onDone();
    }

    if(!bool.fromEnvironment('dart.vm.product')){
      future.catchError((e) => throw e);
    }

    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return onError != null
              ? onError()
              : Center(
                  child: Text(snapshot.error.toString()),
                );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return onNotDone != null
              ? onNotDone()
              : Center(
                  child: CircularProgressIndicator(),
                );
        }
        return onDone();
      },
    );
  }
}
