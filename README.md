# NomzBank - Modern Banking App

A beautiful and modern banking mobile application built with Flutter, featuring light and dark mode support, smooth animations, and a professional UI design.

## Features

### 🎨 Modern Design
- **Light & Dark Mode**: Seamless theme switching with persistent preferences
- **Material Design 3**: Latest Material Design guidelines
- **Custom Theme**: Professional banking color scheme
- **Smooth Animations**: Fluid transitions and micro-interactions

### 📱 Screens
- **Onboarding**: Welcome screens with app introduction
- **Login**: Secure authentication with form validation
- **Dashboard**: Account overview with balance and quick actions
- **Accounts**: Account management (Coming Soon)
- **Transactions**: Transaction history (Coming Soon)
- **Cards**: Credit/Debit card management (Coming Soon)
- **Profile**: User profile and settings (Coming Soon)

### 🛠 Technical Features
- **State Management**: Provider pattern for theme management
- **Navigation**: Go Router for type-safe navigation
- **Responsive Design**: Works on all screen sizes
- **Custom Widgets**: Reusable UI components

## Getting Started

### Prerequisites
- Flutter SDK (3.5.4 or higher)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd nomzbank
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── theme/
│   └── app_theme.dart        # Theme configuration
├── providers/
│   └── theme_provider.dart   # Theme state management
├── routes/
│   └── app_router.dart       # Navigation configuration
├── screens/
│   ├── auth/
│   │   ├── onboarding_screen.dart
│   │   └── login_screen.dart
│   └── main/
│       ├── dashboard_screen.dart
│       ├── accounts_screen.dart
│       ├── transactions_screen.dart
│       ├── cards_screen.dart
│       └── profile_screen.dart
└── widgets/
    └── bottom_navigation.dart # Custom bottom navigation
```

## Dependencies

### Core Dependencies
- `flutter`: Flutter SDK
- `provider`: State management
- `go_router`: Navigation
- `shared_preferences`: Local storage

### UI Dependencies
- `flutter_svg`: SVG support
- `cached_network_image`: Image caching
- `font_awesome_flutter`: Additional icons
- `lottie`: Animation support

### Utility Dependencies
- `intl`: Internationalization
- `cupertino_icons`: iOS-style icons

## Customization

### Colors
Edit `lib/theme/app_theme.dart` to customize:
- Primary colors
- Secondary colors
- Background colors
- Text colors
- Success/Error/Warning colors

### Fonts
The app uses Poppins font family. To change:
1. Add font files to `assets/fonts/`
2. Update `pubspec.yaml` fonts section
3. Modify font family in theme files

### Icons
- Replace icons in screens and widgets
- Add custom SVG icons to `assets/icons/`
- Use Font Awesome icons for additional options

## Development

### Adding New Screens
1. Create screen file in `lib/screens/`
2. Add route in `lib/routes/app_router.dart`
3. Update navigation if needed

### Adding New Features
1. Create feature-specific folders
2. Follow existing naming conventions
3. Add proper documentation
4. Test on both light and dark themes

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

---

**Built with ❤️ using Flutter**
