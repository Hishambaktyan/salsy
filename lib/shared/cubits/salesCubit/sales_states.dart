abstract class SalesStates {}

class SalesInitial extends SalesStates {}

class SalesLoaded extends SalesStates {}

class SalesError extends SalesStates {
  final String message;
  SalesError(this.message);
}