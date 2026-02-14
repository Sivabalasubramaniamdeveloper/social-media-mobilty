import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:mineai/core/network/alice.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await dioProvider.dio.get(
        'https://fakesoreapi.com/products',
      );
      setState(() {
        products = response.data;
        isLoading = false;
      });
    } on DioException catch (e) {
      debugPrint('❌ Error: ${e.message}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: fetchProducts,
          child: const Text('Fake Store'),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: Image.network(product['image'], height: 50),
                  title: Text(product['title']),
                  subtitle: Text('\$${product['price']}'),
                );
              },
            ),
    );
  }
}
