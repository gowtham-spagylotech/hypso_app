import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hypso/blocs/bloc.dart';
import 'package:hypso/configs/config.dart';
import 'package:hypso/repository/list_repository.dart';

import 'cubit.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(InitialSearchState());
  Timer? timer;

  void onSearch(String keyword) async {
    if (keyword.isNotEmpty) {
      timer?.cancel();
      timer = Timer(const Duration(milliseconds: 500), () async {
        emit(SearchLoading());
        final result = await ListRepository.loadList(
          keyword: keyword,
          perPage: Application.setting.perPage,
          page: 1,
        );
        if (result != null) {
          emit(SearchSuccess(list: result[0]));
        }
      });
    }
  }

  void onClear() {
    emit(InitialSearchState());
  }
}
