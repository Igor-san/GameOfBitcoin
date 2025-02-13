import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class DbFailure extends Failure {
  const DbFailure(super.message);
}

class FileFailure extends Failure {
  const FileFailure(super.message);
}
