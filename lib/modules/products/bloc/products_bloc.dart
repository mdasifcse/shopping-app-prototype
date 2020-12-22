import 'package:meta/meta.dart';

import 'package:best_buy_api/best_buy_api.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rxdart/rxdart.dart';

import 'package:shopping_app_prototype/modules/products/repositories/products_repository.dart';

part 'products_state.dart';
part 'products_event.dart';
part 'products_bloc.freezed.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc({
    @required this.repository,
  }) : super(ProductsState.initial());

  final ProductsRepository repository;

  @override
  Stream<Transition<ProductsEvent, ProductsState>> transformEvents(
    Stream<ProductsEvent> events,
    TransitionFunction<ProductsEvent, ProductsState> transitionFn,
  ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }

  @override
  Stream<ProductsState> mapEventToState(ProductsEvent event) => event.map(
        loadStarted: _mapLoadStartedToState,
      );

  Stream<ProductsState> _mapLoadStartedToState(_) async* {
    final loadedProducts = state.maybeWhen<BuiltList<Product>>(
      loadSuccess: (products, _) => products,
      orElse: () => BuiltList<Product>(),
    );

    try {
      final productsData =
          await repository.getProductsData(loadedProducts.length);

      yield ProductsState.loadSuccess(
        products:
            loadedProducts.rebuild((b) => b.addAll(productsData.products)),
        total: productsData.total,
      );
    } catch (_) {
      yield ProductsState.loadFailure();
    }
  }
}
