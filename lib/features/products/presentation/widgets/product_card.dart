import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductData product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Image.network(
          product.image!,
          width: 56,
          height: 56,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
        ),
        title: Text(
          product.title!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${product.category} • ⭐ ${product.model} (${product.discount})',
        ),
        trailing: Text(
          '\$${product.price!.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () {
          context.pushReplacementNamed(
            "sss",
            pathParameters: {'id': product.title!},
          );
          // Navigate to details if you add a details page later
        },
      ),
    );
  }
}
