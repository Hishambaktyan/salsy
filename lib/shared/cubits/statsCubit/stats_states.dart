abstract class StatsStates {}

class StatsInitial extends StatsStates {}

class StatsLoaded extends StatsStates {}

class StatsError extends StatsStates {
  final String message;
  StatsError(this.message);
}