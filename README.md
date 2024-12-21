# Alquran Cloud Scripts

A collection of useful scripts to fetch and store data from the [Alquran Cloud API](https://alquran.cloud/api) in SQLite format.

## Configuration

The script uses a Quran identifier to specify which edition of the Quran to fetch. You can configure this by modifying the `QURAN_IDENTIFIER` constant in `bin/alquran_cloud_scripts.dart`:

```dart
const QURAN_IDENTIFIER = "quran-uthmani-min";
```

You can use any valid identifier from the [Alquran Cloud Editions API](https://api.alquran.cloud/v1/edition) for translation, tafseer, etc.

## Features

- Fetches Quran data from Alquran Cloud API
- Stores data in SQLite format for easy access and querying
- Configurable Quran edition support

## Getting Started

1. Ensure you have Dart SDK installed
2. Clone this repository
3. Run `dart pub get` to install dependencies
4. Configure the desired Quran identifier
5. Run the script using `dart run`