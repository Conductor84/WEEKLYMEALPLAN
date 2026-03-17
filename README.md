# Weekly Meal Plan

A Flutter meal planning app with calorie tracking and exercise integration.

## Features

- **Home** – Dashboard with navigation to all sections
- **Weekly Planner** – Plan meals for each day of the week with calorie totals
- **Grocery List** – Auto-generate shopping lists from your meal plan
- **Recipes** – Create and browse recipes (27 built-in seed recipes)
- **Ingredients** – Manage ingredient library with calorie/protein data
- **Exercise** – Daily step tracking with calorie burn deducted from your planner total

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0+)
- Android emulator or physical device running **Android 5.0+ (API level 21 minimum)**

### Setup

```bash
# Clone the repo
git clone https://github.com/Conductor84/WEEKLYMEALPLAN.git
cd WEEKLYMEALPLAN

# Install dependencies and generate platform files
flutter pub get

# Run on Android emulator
flutter run
```

### Android Permissions

The app uses the phone's built-in step counter. On first launch, Android 10+ will prompt for **Activity Recognition** permission. Grant it to enable step tracking.

## Tech Stack

- **Flutter** + Material 3
- **Hive** (local NoSQL database – no server required)
- **Pedometer** (native step counter integration)

## Project Structure

```
lib/
  main.dart              # App entry point + bottom navigation
  models/                # Data classes (Recipe, Ingredient, MealPlan, etc.)
  pages/                 # 6 main screens
  services/              # Hive persistence + business logic
  widgets/               # Reusable UI components
android/                 # Android project files
```

