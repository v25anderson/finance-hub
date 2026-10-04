import 'package:flutter/material.dart';

/// Ícone de uma categoria a partir do nome salvo (categorias novas usam `category`).
IconData categoryIcon(String? name) => switch (name) {
      'home' => Icons.home_rounded,
      'restaurant' => Icons.restaurant_rounded,
      'directions_car' => Icons.directions_car_rounded,
      'subscriptions' => Icons.subscriptions_rounded,
      'favorite' => Icons.favorite_rounded,
      'school' => Icons.school_rounded,
      'sports_esports' => Icons.sports_esports_rounded,
      'shopping_bag' => Icons.shopping_bag_rounded,
      'account_balance' => Icons.account_balance_rounded,
      'trending_up' => Icons.trending_up_rounded,
      _ => Icons.category_rounded,
    };
