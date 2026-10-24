import 'package:flutter_test/flutter_test.dart';
import 'package:mineai/features/news/models/news_article_model.dart';
import 'package:mineai/features/tasks/models/task_model.dart';
import 'package:mineai/features/subscription/models/subscription_plan.dart';

void main() {
  group('NewsArticleModel Unit Tests', () {
    test('Correctly parses complete JSON with imageUrl', () {
      final json = {
        'id': 'art_123',
        'title': 'Chennai Metro Extends Service',
        'link': 'https://example.com/metro',
        'pubDate': 'Sat, 24 Oct 2026 10:00:00 GMT',
        'source': 'The Times',
        'snippet': 'Metro trains will operate till midnight.',
        'city': 'Chennai',
        'imageUrl': 'https://static.toiimg.com/photo/123.cms',
      };

      final article = NewsArticleModel.fromJson(json);

      expect(article.id, equals('art_123'));
      expect(article.title, equals('Chennai Metro Extends Service'));
      expect(article.source, equals('The Times'));
      expect(article.city, equals('Chennai'));
      expect(article.imageUrl, equals('https://static.toiimg.com/photo/123.cms'));
    });

    test('Provides sensible defaults for missing/null fields', () {
      final emptyJson = <String, dynamic>{};
      final article = NewsArticleModel.fromJson(emptyJson);

      expect(article.id, isEmpty);
      expect(article.title, equals('Untitled'));
      expect(article.source, equals('Local News'));
      expect(article.city, equals('Chennai'));
      expect(article.imageUrl, isNull);
    });
  });

  group('TaskModel Unit Tests', () {
    test('Serializes to map and deserializes from map correctly', () {
      final task = TaskModel(
        id: 42,
        userId: 'user_abc_789',
        title: 'Team Sprint Planning',
        category: 'Work',
        dateDisplay: 'Tomorrow',
        dateIso: '2026-10-25',
        timeDisplay: '11:00 AM',
        timeIso: '11:00:00',
        location: 'Conference Room B',
        details: 'Review Q4 deliverables and backlog.',
        isCompleted: true,
        createdAt: '2026-10-24T12:00:00Z',
      );

      final map = task.toMap();
      expect(map['id'], equals(42));
      expect(map['user_id'], equals('user_abc_789'));
      expect(map['is_completed'], equals(1));

      final restored = TaskModel.fromMap(map);
      expect(restored.id, equals(42));
      expect(restored.userId, equals('user_abc_789'));
      expect(restored.title, equals('Team Sprint Planning'));
      expect(restored.category, equals('Work'));
      expect(restored.isCompleted, isTrue);
    });

    test('Defaults uncompleted task properly', () {
      final task = TaskModel(
        userId: 'user_1',
        title: 'Buy groceries',
        category: 'Personal',
        dateDisplay: 'Today',
        timeDisplay: '5:00 PM',
        createdAt: '2026-10-24T15:00:00Z',
      );

      expect(task.isCompleted, isFalse);
      expect(task.toMap()['is_completed'], equals(0));
    });
  });

  group('SubscriptionPlan Unit Tests', () {
    test('Tier code 0 maps to Basic plan with expected quotas', () {
      final plan = SubscriptionPlan.fromTierCode(0);

      expect(plan.tier, equals(PlanTier.basic));
      expect(plan.dailyCredits, equals(100));
      expect(plan.maxBudgets, equals(4));
      expect(plan.cloudSyncEnabled, isFalse);
      expect(plan.diaryImageLimit, equals(5));
      expect(plan.isMonthlyImageLimit, isFalse);
      expect(plan.dailyScrapes, equals(2));
    });

    test('Tier code 1 maps to Pro plan with cloud sync enabled', () {
      final plan = SubscriptionPlan.fromTierCode(1);

      expect(plan.tier, equals(PlanTier.pro));
      expect(plan.dailyCredits, equals(1000));
      expect(plan.maxBudgets, equals(10));
      expect(plan.cloudSyncEnabled, isTrue);
      expect(plan.diaryImageLimit, equals(10));
      expect(plan.isMonthlyImageLimit, isTrue);
      expect(plan.dailyScrapes, equals(10));
    });

    test('Tier code 2 maps to Premium plan with highest quotas', () {
      final plan = SubscriptionPlan.fromTierCode(2);

      expect(plan.tier, equals(PlanTier.premium));
      expect(plan.dailyCredits, equals(5000));
      expect(plan.maxBudgets, equals(30));
      expect(plan.cloudSyncEnabled, isTrue);
      expect(plan.diaryImageLimit, equals(30));
      expect(plan.isMonthlyImageLimit, isTrue);
      expect(plan.dailyScrapes, equals(25));
    });
  });
}
