import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/rating/rating_state.dart';

class RatingCubit extends StoreCubit<RatingState> {
  RatingCubit(this.bookId) : super(RatingState.from(LibraryStore.instance, bookId));

  final int bookId;

  @override
  void refresh() => emit(RatingState.from(store, bookId, stars: state.stars));

  void selectStars(int stars) => emit(RatingState.from(store, bookId, stars: stars));

  void save(String comment) => store.rateBook(bookId, state.stars, comment: comment);

  void delete(int ratingId) => store.deleteRating(ratingId);
}
