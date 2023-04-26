import 'package:fpdart/fpdart.dart';
import 'package:jana_soz/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;