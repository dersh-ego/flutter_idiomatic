import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

T getBloc<T extends Cubit<Object>>(BuildContext context) =>
    BlocProvider.of<T>(context);

T getRepository<T>(BuildContext context) => RepositoryProvider.of<T>(context);

void out(dynamic value) {
  if (kDebugMode) debugPrint('$value');
}

class ValidationException implements Exception {
  ValidationException(this.message);

  final String message;

  @override
  String toString() {
    return message;
  }
}

Future<void> load(Future<void> Function() future) async {
  await Future.delayed(Duration.zero); // for render initial state
  try {
    await future();
  } catch (error) {
    BotToast.showNotification(
      crossPage: false,
      title: (_) => Text('$error'),
      trailing: (Function close) => FlatButton(
        onLongPress: () {}, // чтобы сократить время для splashColor
        onPressed: () {
          close();
          load(future);
        },
        child: Text('Repeat'.toUpperCase()),
      ),
    );
    return Future.error(error);
  }
}

Future<void> save(Future<void> Function() future) async {
  BotToast.showLoading();
  try {
    await future();
  } on ValidationException catch (error) {
    BotToast.showNotification(
      crossPage: false,
      title: (_) => Text('$error'),
    );
    return Future.error(error);
  } catch (error) {
    BotToast.showNotification(
      // crossPage: true, // !!!!
      title: (_) => Text('$error'),
      trailing: (Function close) => FlatButton(
        onLongPress: () {}, // чтобы сократить время для splashColor
        onPressed: () {
          close();
          save(future);
        },
        child: Text('Repeat'.toUpperCase()),
      ),
    );
    return Future.error(error);
  } finally {
    BotToast.closeAllLoading();
  }
}
