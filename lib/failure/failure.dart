import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String errorMessage;
  const Failure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({
    String message = "Local database operation failure",
  }) : super(errorMessage: message);
}

class ApiFailure extends Failure {
  final int? statusCode;

  const ApiFailure({this.statusCode, required String message})
    : super(errorMessage: message);
}

class GeneralFailure extends Failure {
  const GeneralFailure(String message) : super(errorMessage: message);
}