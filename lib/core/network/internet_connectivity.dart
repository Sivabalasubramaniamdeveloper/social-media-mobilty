import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectivityStatus { connected, disconnected }

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityCubit() : super(ConnectivityStatus.connected) {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result.first == ConnectivityResult.none) {
        emit(ConnectivityStatus.disconnected);
      } else {
        emit(ConnectivityStatus.connected);
      }
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
