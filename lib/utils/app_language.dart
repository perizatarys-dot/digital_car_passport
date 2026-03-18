import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { en, ru, kk }

extension AppLanguageX on AppLanguage {
  String get label {
    switch (this) {
      case AppLanguage.en:
        return 'English';
      case AppLanguage.ru:
        return 'Russian';
      case AppLanguage.kk:
        return 'Kazakh';
    }
  }
}

final appLanguageProvider = StateProvider<AppLanguage>((ref) => AppLanguage.en);

abstract class AppStrings {
  static String appTitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Digital Car Passport';
      case AppLanguage.ru:
        return 'Цифровой Паспорт Авто';
      case AppLanguage.kk:
        return 'Сандық Көлік Паспорты';
    }
  }

  static String home(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Home';
      case AppLanguage.ru:
        return 'Главная';
      case AppLanguage.kk:
        return 'Басты бет';
    }
  }

  static String reports(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Reports';
      case AppLanguage.ru:
        return 'Отчеты';
      case AppLanguage.kk:
        return 'Есептер';
    }
  }

  static String saved(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Saved';
      case AppLanguage.ru:
        return 'Сохранено';
      case AppLanguage.kk:
        return 'Сақталған';
    }
  }

  static String profile(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Profile';
      case AppLanguage.ru:
        return 'Профиль';
      case AppLanguage.kk:
        return 'Профиль';
    }
  }

  static String settings(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Settings';
      case AppLanguage.ru:
        return 'Настройки';
      case AppLanguage.kk:
        return 'Баптаулар';
    }
  }

  static String settingsSubtitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Language, privacy, support, notifications, and product preferences.';
      case AppLanguage.ru:
        return 'Язык, приватность, поддержка, уведомления и настройки приложения.';
      case AppLanguage.kk:
        return 'Тіл, құпиялылық, қолдау, хабарламалар және қолданба баптаулары.';
    }
  }

  static String language(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Language';
      case AppLanguage.ru:
        return 'Язык';
      case AppLanguage.kk:
        return 'Тіл';
    }
  }

  static String preferences(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Preferences';
      case AppLanguage.ru:
        return 'Предпочтения';
      case AppLanguage.kk:
        return 'Теңшелімдер';
    }
  }

  static String supportAndLegal(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Support and legal';
      case AppLanguage.ru:
        return 'Поддержка и документы';
      case AppLanguage.kk:
        return 'Қолдау және құжаттар';
    }
  }

  static String pushNotifications(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Push notifications';
      case AppLanguage.ru:
        return 'Push-уведомления';
      case AppLanguage.kk:
        return 'Push хабарламалар';
    }
  }

  static String privacyFirstMasking(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Privacy-first masking';
      case AppLanguage.ru:
        return 'Скрытие персональных данных';
      case AppLanguage.kk:
        return 'Жеке деректерді жасыру';
    }
  }

  static String darkMode(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Dark mode';
      case AppLanguage.ru:
        return 'Темная тема';
      case AppLanguage.kk:
        return 'Қараңғы режим';
    }
  }

  static String helpCenter(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Help center';
      case AppLanguage.ru:
        return 'Центр помощи';
      case AppLanguage.kk:
        return 'Көмек орталығы';
    }
  }

  static String faq(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'FAQ';
      case AppLanguage.ru:
        return 'FAQ';
      case AppLanguage.kk:
        return 'FAQ';
    }
  }

  static String terms(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Terms and conditions';
      case AppLanguage.ru:
        return 'Условия использования';
      case AppLanguage.kk:
        return 'Қолдану шарттары';
    }
  }

  static String privacyPolicy(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Privacy policy';
      case AppLanguage.ru:
        return 'Политика конфиденциальности';
      case AppLanguage.kk:
        return 'Құпиялылық саясаты';
    }
  }

  static String dashboardHeadline(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Know your car\'s full story before you buy';
      case AppLanguage.ru:
        return 'Узнайте полную историю автомобиля до покупки';
      case AppLanguage.kk:
        return 'Сатып алар алдында көліктің толық тарихын біліңіз';
    }
  }

  static String quickActions(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Quick Actions';
      case AppLanguage.ru:
        return 'Быстрые действия';
      case AppLanguage.kk:
        return 'Жылдам әрекеттер';
    }
  }

  static String recentSearches(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Recent Searches';
      case AppLanguage.ru:
        return 'Недавние проверки';
      case AppLanguage.kk:
        return 'Соңғы іздеулер';
    }
  }
}
