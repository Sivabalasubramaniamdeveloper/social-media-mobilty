import 'package:flutter/material.dart';
import 'package:flutter_automation/features/products/presentation/widgets/product_card.dart';
import 'package:flutter_automation/core/logger/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/responsive/responsive_config.dart';
import '../../../../core/base/abstract/base_screen.dart';
import '../../../../core/utils/secure_storage.dart';
import '../../../../core/utils/toast_helper.dart';
import '../../../../instance/app_lifecycle_handler.dart';
import '../../../../instance/locator.dart';
import '../../data/cubit/product_cubit.dart';
import '../../data/cubit/product_state.dart';

class ProductsPage extends BaseScreen {
  const ProductsPage({super.key});

  @override
  String get title => "Product page";

  @override
  List<Widget>? get actions => [
    IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
  ];

  @override
  Widget? get floatingActionButton =>
      FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add));

  @override
  Widget buildBody(BuildContext context) {
    return _ProductsBody();
  }
}

class _ProductsBody extends StatefulWidget {
  @override
  State<_ProductsBody> createState() => _ProductsBodyState();
}

class _ProductsBodyState extends State<_ProductsBody> {
  DateTime? _pausedTime;
  final Duration refreshAfter = const Duration(seconds: 10);
  ResponsiveConfig responsive = getIt<ResponsiveConfig>();
  CustomSecureStorage customSecureStorage = getIt<CustomSecureStorage>();

  @override
  void initState() {
    super.initState();

    AppLifecycleHandler(
      onChange: (state) {
        if (state == AppLifecycleState.resumed) {
          if (_pausedTime != null) {
            final diff = DateTime.now().difference(_pausedTime!);
            if (diff >= refreshAfter) {
              fetchData();
            }
          }
        } else if (state == AppLifecycleState.detached) {
          return;
        } else {
          _pausedTime = DateTime.now();
        }
      },
    );

    fetchData();
  }

  Future<void> fetchData() async {
    try {
      BlocProvider.of<ProductCubit>(context).fetchProducts();
      customSecureStorage.writeSecureData("sssssssssssss", "valuesssssssssss");
      String? value = await customSecureStorage.readSecureData("sssssssssssss");
      CustomAppLogger.appLogger("customSecureStorage", value!);
      CustomAppLogger.appLogger("Insert", "sss");
    } catch (err) {
      showErrorToast(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductErrorState) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, textAlign: TextAlign.center),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: fetchData,
                  child: Text("Refresh Again"),
                ),
              ],
            ),
          );
        } else if (state is ProductSuccessState) {
          final items = state.products.products;
          if (items.isEmpty) {
            return const Center(child: Text('No products found'));
          }
          return ResponsiveConfig.responsiveListOrGrid(
            context: context,
            itemBuilder: (_, i) => ProductCard(product: items[i]),
            itemCount: items.length,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
