import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sqlite3/sqlite3.dart';

// pass any of the identifier from https://api.alquran.cloud/v1/edition here
const QURAN_IDENTIFIER = "quran-uthmani-min";

void main(List<String> arguments) async {
  final String sqliteDbPath = 'db-${QURAN_IDENTIFIER}-alquran.db';

  final baseUrl = 'https://api.alquran.cloud/v1/quran/${QURAN_IDENTIFIER}';

  final response = await http.get(Uri.parse(baseUrl));

  if (response.statusCode != 200) {
    print('Error: ${response.statusCode}');
    return;
  }

  final responseData = jsonDecode(response.body) as Map<String, dynamic>;
  final data = responseData['data']["surahs"] as List<dynamic>;

  final db = sqlite3.open(sqliteDbPath);

  // making surahs table
  db.execute('''
    CREATE TABLE IF NOT EXISTS surahs (
      number INTEGER PRIMARY KEY,
      name TEXT,
      englishName TEXT,
      englishNameTranslation TEXT,
      revelationType TEXT,
      numOfAyahs INTEGER
    )
  ''');

  // making ayahs table
  db.execute('''
    CREATE TABLE IF NOT EXISTS ayahs (
      number INTEGER PRIMARY KEY NOT NULL,
      text TEXT NOT NULL,
      numberInSurah INTEGER NOT NULL,
      juz INTEGER NOT NULL,
      manzil INTEGER NOT NULL,
      page INTEGER NOT NULL,
      ruku INTEGER NOT NULL,
      hizbQuarter INTEGER NOT NULL,
      sajda TEXT NOT NULL,
      surahNumber INTEGER NOT NULL,
      FOREIGN KEY (surahNumber) REFERENCES surahs (number)
    )
  ''');

  for (final surah in data) {
    final surahNumber = surah['number'];
    final surahName = surah['name'];
    final surahEnglishName = surah['englishName'];
    final surahEnglishNameTranslation = surah['englishNameTranslation'];
    final surahRevelationType = surah['revelationType'];

    final ayahs = surah['ayahs'] as List<dynamic>;

    db.execute('''
      INSERT INTO surahs (number, name, englishName, englishNameTranslation, revelationType, numOfAyahs)
      VALUES (?, ?, ?, ?, ?, ?)
    ''', [
      surahNumber,
      surahName,
      surahEnglishName,
      surahEnglishNameTranslation,
      surahRevelationType,
      ayahs.length
    ]);

    for (final ayah in ayahs) {
      final ayahNumber = ayah['number'];
      final ayahText = ayah['text'];
      final ayahNumberInSurah = ayah['numberInSurah'];
      final ayahJuz = ayah['juz'];
      final ayahManzil = ayah['manzil'];
      final ayahPage = ayah['page'];
      final ayahRuku = ayah['ruku'];
      final ayahHizbQuarter = ayah['hizbQuarter'];
      final ayahSajda = switch(ayah['sajda']){
        (final Map sajda) => sajda["recommended"] ? "recommended" : "obligatory",
        _ => "none"
      };

      print('Inserting ayah: $ayahNumber');

      db.execute('''
        INSERT INTO ayahs (number, text, numberInSurah, juz, manzil, page, ruku, hizbQuarter, sajda, surahNumber)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        ayahNumber,
        ayahText,
        ayahNumberInSurah,
        ayahJuz,
        ayahManzil,
        ayahPage,
        ayahRuku,
        ayahHizbQuarter,
        ayahSajda,
        surahNumber
      ]);
    }
  }
}