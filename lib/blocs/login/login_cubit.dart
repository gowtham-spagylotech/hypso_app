import 'package:bloc/bloc.dart';
import 'package:hypso/blocs/app_bloc.dart';
import 'package:hypso/blocs/bloc.dart';
import 'package:hypso/configs/config.dart';
import 'package:hypso/repository/repository.dart';
import 'package:hypso/utils/utils.dart';

enum LoginState {
  init,
  loading,
  success,
  fail,
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState.init);

  void onLogin({
    required String username,
    required String password,
  }) async {
    ///Notify
    emit(LoginState.loading);

    ///Set Device Token
    Application.device?.token = await Utils.getDeviceToken();

    ///login via repository
    final result = await UserRepository.login(
      username: username,
      password: password,
    );

    if (result != null) {
      ///Begin start Auth flow
      await AppBloc.authenticateCubit.onSave(result);

      ///Notify
      emit(LoginState.success);
    } else {
      ///Notify
      emit(LoginState.fail);
    }
  }

  void onLogout() async {
    ///Begin start auth flow
    emit(LoginState.init);
    AppBloc.authenticateCubit.onClear();
  }

  void onDeactivate() async {
    final result = await UserRepository.deactivate();
    if (result) {
      AppBloc.authenticateCubit.onClear();
    }
  }
}
