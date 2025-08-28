import 'package:flutter/cupertino.dart';
import 'package:flutter_automation/core/base/abstract/base_screen.dart';

class SingleProduct extends BaseScreen {
  final String productId;
  const SingleProduct({super.key, required this.productId});

  @override
  Widget buildBody(BuildContext context) {
    return SingleProductBody(productId: productId);
  }

  @override
  // TODO: implement title
  String get title => "Single";
}

class SingleProductBody extends StatefulWidget {
  final String productId;
  const SingleProductBody({super.key, required this.productId});

  @override
  State<SingleProductBody> createState() => _SingleProductBodyState();
}

class _SingleProductBodyState extends State<SingleProductBody> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.productId);
  }
}
