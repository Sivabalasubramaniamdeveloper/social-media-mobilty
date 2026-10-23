import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/features/subscription/models/subscription_plan.dart';
import '../models/vault_item_model.dart';
import '../services/vault_database_service.dart';
import 'vault_state.dart';

class VaultCubit extends Cubit<VaultState> {
  final VaultDatabaseService _dbService;

  VaultCubit({VaultDatabaseService? dbService})
      : _dbService = dbService ?? VaultDatabaseService.instance,
        super(const VaultInitial());

  Future<void> loadVault({
    String filter = 'all',
    required PlanTier tier,
  }) async {
    emit(const VaultLoading());
    try {
      final userId = await UserHelper.getCurrentUserId();
      final items = await _dbService.getItems(userId, type: filter);

      final passwords = await _dbService.getItemCount(userId, 'password');
      final photos = await _dbService.getItemCount(userId, 'photo');
      final docs = await _dbService.getItemCount(userId, 'document');

      emit(VaultLoaded(
        items: items,
        currentFilter: filter,
        passwordCount: passwords,
        photoCount: photos,
        maxPhotos: _dbService.getMaxPhotos(tier),
        documentCount: docs,
        maxDocuments: _dbService.getMaxDocuments(tier),
      ));
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }

  Future<bool> saveItem(
    VaultItemModel item, {
    required PlanTier tier,
    String currentFilter = 'all',
  }) async {
    try {
      final userId = await UserHelper.getCurrentUserId();
      final canAdd = await _dbService.canAddItem(userId, item.type, tier);
      if (!canAdd) {
        if (tier == PlanTier.basic) {
          emit(const VaultError(
            'Private Photos and Documents are available exclusively on Pro and Premium plans. Free plan allows password storage only.',
          ));
        } else if (item.type == 'photo') {
          final max = _dbService.getMaxPhotos(tier);
          emit(VaultError(
            'Photo limit reached for your plan ($max photos max). Upgrade to Premium for 20 photos.',
          ));
        } else {
          final max = _dbService.getMaxDocuments(tier);
          emit(VaultError(
            'Document limit reached for your plan ($max docs max). Upgrade to Premium for 30 documents.',
          ));
        }
        return false;
      }

      await _dbService.insertItem(item);
      await loadVault(filter: currentFilter, tier: tier);
      return true;
    } catch (e) {
      emit(VaultError(e.toString()));
      return false;
    }
  }

  Future<void> deleteItem(
    VaultItemModel item, {
    required PlanTier tier,
    String currentFilter = 'all',
  }) async {
    try {
      await _dbService.deleteItem(item);
      await loadVault(filter: currentFilter, tier: tier);
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }
}
