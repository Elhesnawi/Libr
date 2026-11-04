import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/splash/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashState()) {
    _timer = Timer(duration, skip);
  }

  static const Duration duration = Duration(milliseconds: 3200);
  Timer? _timer;

  /// الانتقال الآن (بالضغط) أو عند انتهاء المهلة.
  void skip() {
    if (state.finished || isClosed) return;
    emit(const SplashState(finished: true));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
