abstract class ProductsStates {}

class ProductsInitial extends ProductsStates {}

class ProductsLoading extends ProductsStates {}

class ProductsLoaded extends ProductsStates {}

class ProductsError extends ProductsStates {
  final String message;
  ProductsError(this.message);
}
