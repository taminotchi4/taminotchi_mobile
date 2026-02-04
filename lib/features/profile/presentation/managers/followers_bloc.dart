import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_followers_usecase.dart';
import 'followers_event.dart';
import 'followers_state.dart';

class FollowersBloc extends Bloc<FollowersEvent, FollowersState> {
  final GetFollowersUseCase getFollowersUseCase;

  FollowersBloc({required this.getFollowersUseCase})
      : super(FollowersState.initial()) {
    on<FollowersStarted>(_onStarted);
    on<FollowersSearchChanged>(_onSearchChanged);
  }

  Future<void> _onStarted(
    FollowersStarted event,
    Emitter<FollowersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await getFollowersUseCase(event.sellerId);
    result.fold(
      (_) => emit(state.copyWith(isLoading: false)),
      (followers) => emit(state.copyWith(
        isLoading: false,
        followers: followers,
        filtered: followers,
      )),
    );
  }

  void _onSearchChanged(
    FollowersSearchChanged event,
    Emitter<FollowersState> emit,
  ) {
    final query = event.query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? state.followers
        : state.followers
            .where((item) => item.name.toLowerCase().contains(query))
            .toList();
    emit(state.copyWith(query: event.query, filtered: filtered));
  }
}
