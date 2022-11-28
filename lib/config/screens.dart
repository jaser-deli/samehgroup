enum Screens { main, home, login, profile, language }

extension ScreenExtension on Screens {
  String get value {
    switch (this) {
      case Screens.main:
        return "/";
      case Screens.login:
        return "/login";
      case Screens.home:
        return "/home";
      case Screens.profile:
        return "/profile";
      case Screens.language:
        return "/language";
      default:
        return "/";
    }
  }
}
