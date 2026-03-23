sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok._;

  const factory Result.error(Exception error) = Error._;

  R fold<R>(R Function(Exception error) onError, R Function(T value) onSuccess);

  bool get isOk => this is Ok<T>;
  bool get isError => this is Error<T>;

  T? get data => fold((_) => null, (val) => val);
  Exception? get error => fold((err) => err, (_) => null);
}

final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  final T value;
  @override
  R fold<R>(
      R Function(Exception error) onError,
      R Function(T value) onSuccess,
      ) => onSuccess(value);
}

final class Error<T> extends Result<T> {
  const Error._(this.error);

  final Exception error;

  @override
  R fold<R>(
      R Function(Exception error) onError,
      R Function(T value) onSuccess,
      ) => onError(error);
}
