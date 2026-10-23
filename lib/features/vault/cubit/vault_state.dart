import 'package:equatable/equatable.dart';
import '../models/vault_item_model.dart';

abstract class VaultState extends Equatable {
  const VaultState();

  @override
  List<Object?> get props => [];
}

class VaultInitial extends VaultState {
  const VaultInitial();
}

class VaultLoading extends VaultState {
  const VaultLoading();
}

class VaultLoaded extends VaultState {
  final List<VaultItemModel> items;
  final String currentFilter; // 'all', 'password', 'photo', 'document'
  final int passwordCount;
  final int photoCount;
  final int maxPhotos;
  final int documentCount;
  final int maxDocuments;

  const VaultLoaded({
    required this.items,
    required this.currentFilter,
    required this.passwordCount,
    required this.photoCount,
    required this.maxPhotos,
    required this.documentCount,
    required this.maxDocuments,
  });

  @override
  List<Object?> get props => [
        items,
        currentFilter,
        passwordCount,
        photoCount,
        maxPhotos,
        documentCount,
        maxDocuments,
      ];
}

class VaultError extends VaultState {
  final String message;
  const VaultError(this.message);

  @override
  List<Object?> get props => [message];
}
