import 'package:async_redux/async_redux.dart';
import '/cloudnet.dart';
import '/feature/node/node_handler.dart';
import '/state/app_state.dart';
import '/state/persistor.dart';
import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';

Future<void> main() async {
  I18n.observeLocale =
      ({required Locale oldLocale, required Locale newLocale})
  => print("Changed from $oldLocale to $newLocale.");
  await nodeHandler.load();
  final persistor = AppPersistor();
  final initialState = await persistor.readState();
  final store = Store<AppState>(
    persistor: persistor,
    initialState: initialState,
  );
  runApp(StoreProvider<AppState>(store: store, child: const CloudNet()));
}
