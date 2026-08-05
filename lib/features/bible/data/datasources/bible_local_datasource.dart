import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../core/constants/bible_constants.dart';
import '../models/book_model.dart';
import '../models/verse_model.dart';

abstract class BibleLocalDatasource {
  Future<List<BookModel>> getPreSeededBooks(String languageId);
  Future<List<VerseModel>> getPreSeededVerses({
    required String languageId,
    required String bookId,
    required int chapterNumber,
  });
}

class BibleLocalDatasourceImpl implements BibleLocalDatasource {
  final Map<String, Map<String, dynamic>> _bookJsonCache = {};
  final Map<String, Map<String, dynamic>> _kachinBookJsonCache = {};

  static const Map<String, Map<String, String>> _kachinBookNames = {
    'genesis': {'name': 'Ningpawt Ningchang', 'abbr': 'Ning'},
    'exodus': {'name': 'Pru Wa Ai Laika', 'abbr': 'Pru'},
    'leviticus': {'name': 'Nawku Hku-hka', 'abbr': 'Naw'},
    'numbers': {'name': 'Minami Laika', 'abbr': 'Min'},
    'deuteronomy': {'name': 'Tara Rap-a-ra', 'abbr': 'Tara'},
    'joshua': {'name': 'Yosua Laika', 'abbr': 'Yos'},
    'judges': {'name': 'Tara Daw Ai Ni', 'abbr': 'Jdg'},
    'ruth': {'name': 'Rut Laika', 'abbr': 'Rut'},
    '1samuel': {'name': '1 Samuel', 'abbr': '1Sa'},
    '2samuel': {'name': '2 Samuel', 'abbr': '2Sa'},
    '1kings': {'name': '1 Hki-ke', 'abbr': '1Ki'},
    '2kings': {'name': '2 Hki-ke', 'abbr': '2Ki'},
    '1chronicles': {'name': '1 Labau', 'abbr': '1Ch'},
    '2chronicles': {'name': '2 Labau', 'abbr': '2Ch'},
    'ezra': {'name': 'Esdra Laika', 'abbr': 'Ezr'},
    'nehemiah': {'name': 'Nehemia Laika', 'abbr': 'Neh'},
    'esther': {'name': 'Ester Laika', 'abbr': 'Est'},
    'job': {'name': 'Yob Laika', 'abbr': 'Yob'},
    'psalms': {'name': 'Mahkawn Mangkoi', 'abbr': 'Mah'},
    'proverbs': {'name': 'Ga Shagawp', 'abbr': 'GaS'},
    'ecclesiastes': {'name': 'Hpaji Htwi Laika', 'abbr': 'Hpa'},
    'songofsolomon': {'name': 'Mahkawn Ni A Mahkawn', 'abbr': 'Sng'},
    'isaiah': {'name': 'Esaia Myihtoi', 'abbr': 'Esa'},
    'jeremiah': {'name': 'Yeremia Myihtoi', 'abbr': 'Yer'},
    'lamentations': {'name': 'Kha-ku Ga', 'abbr': 'Kha'},
    'ezekiel': {'name': 'Ezekiel Myihtoi', 'abbr': 'Eze'},
    'daniel': {'name': 'Daniel Myihtoi', 'abbr': 'Dan'},
    'hosea': {'name': 'Hosea Myihtoi', 'abbr': 'Hos'},
    'joel': {'name': 'Yoela Myihtoi', 'abbr': 'Yoe'},
    'amos': {'name': 'Amos Myihtoi', 'abbr': 'Amo'},
    'obadiah': {'name': 'Obadia Myihtoi', 'abbr': 'Oba'},
    'jonah': {'name': 'Yona Myihtoi', 'abbr': 'Yon'},
    'micah': {'name': 'Mika Myihtoi', 'abbr': 'Mik'},
    'nahum': {'name': 'Nahum Myihtoi', 'abbr': 'Nah'},
    'habakkuk': {'name': 'Habakuk Myihtoi', 'abbr': 'Hab'},
    'zephaniah': {'name': 'Zepania Myihtoi', 'abbr': 'Zep'},
    'haggai': {'name': 'Hagai Myihtoi', 'abbr': 'Hag'},
    'zechariah': {'name': 'Zahkaria Myihtoi', 'abbr': 'Zah'},
    'malachi': {'name': 'Malaki Myihtoi', 'abbr': 'Mal'},
    'matthew': {'name': 'Mahte Chyum Laika', 'abbr': 'Mah'},
    'mark': {'name': 'Marku Chyum Laika', 'abbr': 'Mar'},
    'luke': {'name': 'Luka Chyum Laika', 'abbr': 'Luk'},
    'john': {'name': 'Yohan Chyum Laika', 'abbr': 'Yoh'},
    'acts': {'name': 'Kasa Laika', 'abbr': 'Kas'},
    'romans': {'name': 'Roma Shagu', 'abbr': 'Rom'},
    '1corinthians': {'name': '1 Korintu', 'abbr': '1Ko'},
    '2corinthians': {'name': '2 Korintu', 'abbr': '2Ko'},
    'galatians': {'name': 'Galati Shagu', 'abbr': 'Gal'},
    'ephesians': {'name': 'Ehpesu Shagu', 'abbr': 'Ehp'},
    'philippians': {'name': 'Hpilipi Shagu', 'abbr': 'Hpi'},
    'colossians': {'name': 'Kolose Shagu', 'abbr': 'Kol'},
    '1thessalonians': {'name': '1 Htesaloni', 'abbr': '1Ht'},
    '2thessalonians': {'name': '2 Htesaloni', 'abbr': '2Ht'},
    '1timothy': {'name': '1 Timote', 'abbr': '1Ti'},
    '2timothy': {'name': '2 Timote', 'abbr': '2Ti'},
    'titus': {'name': 'Titu Shagu', 'abbr': 'Tit'},
    'philemon': {'name': 'Hpilemon Shagu', 'abbr': 'Hpm'},
    'hebrews': {'name': 'Hebrew Shagu', 'abbr': 'Heb'},
    'james': {'name': 'Yakob Shagu', 'abbr': 'Yak'},
    '1peter': {'name': '1 Petru', 'abbr': '1Pe'},
    '2peter': {'name': '2 Petru', 'abbr': '2Pe'},
    '1john': {'name': '1 Yohan', 'abbr': '1Yo'},
    '2john': {'name': '2 Yohan', 'abbr': '2Yo'},
    '3john': {'name': '3 Yohan', 'abbr': '3Yo'},
    'jude': {'name': 'Yuda Shagu', 'abbr': 'Yud'},
    'revelation': {'name': 'Shingran Laika', 'abbr': 'Shi'},
  };

  static const List<Map<String, dynamic>> _all66BooksRaw = [
    // Old Testament (39 Books)
    {'id': 'genesis', 'en': 'Genesis', 'my': 'ကမ္ဘာဦးကျမ်း', 'abbrMy': 'ကမ္ဘာ', 'abbrEn': 'Gen', 'chapters': 50, 'testament': BibleTestament.old, 'order': 1},
    {'id': 'exodus', 'en': 'Exodus', 'my': 'ထွက်မြောက်ရာကျမ်း', 'abbrMy': 'ထွက်', 'abbrEn': 'Exo', 'chapters': 40, 'testament': BibleTestament.old, 'order': 2},
    {'id': 'leviticus', 'en': 'Leviticus', 'my': 'ဝတ်ပြုရာကျမ်း', 'abbrMy': 'ဝတ်', 'abbrEn': 'Lev', 'chapters': 27, 'testament': BibleTestament.old, 'order': 3},
    {'id': 'numbers', 'en': 'Numbers', 'my': 'တောလည်ရာကျမ်း', 'abbrMy': 'တော', 'abbrEn': 'Num', 'chapters': 36, 'testament': BibleTestament.old, 'order': 4},
    {'id': 'deuteronomy', 'en': 'Deuteronomy', 'my': 'တရားဟောရာကျမ်း', 'abbrMy': 'တရား', 'abbrEn': 'Deu', 'chapters': 34, 'testament': BibleTestament.old, 'order': 5},
    {'id': 'joshua', 'en': 'Joshua', 'my': 'ယောရှုမှတ်စာ', 'abbrMy': 'ယောရှု', 'abbrEn': 'Jos', 'chapters': 24, 'testament': BibleTestament.old, 'order': 6},
    {'id': 'judges', 'en': 'Judges', 'my': 'တရားသူကြီးမှတ်စာ', 'abbrMy': 'တရားသူ', 'abbrEn': 'Jdg', 'chapters': 21, 'testament': BibleTestament.old, 'order': 7},
    {'id': 'ruth', 'en': 'Ruth', 'my': 'ရုသမှတ်စာ', 'abbrMy': 'ရုသ', 'abbrEn': 'Rut', 'chapters': 4, 'testament': BibleTestament.old, 'order': 8},
    {'id': '1samuel', 'en': '1 Samuel', 'my': 'ဓမ္မရာဇဝင်ပထမစောင်', 'abbrMy': '၁ရာ', 'abbrEn': '1Sa', 'chapters': 31, 'testament': BibleTestament.old, 'order': 9},
    {'id': '2samuel', 'en': '2 Samuel', 'my': 'ဓမ္မရာဇဝင်ဒုတိယစောင်', 'abbrMy': '၂ရာ', 'abbrEn': '2Sa', 'chapters': 24, 'testament': BibleTestament.old, 'order': 10},
    {'id': '1kings', 'en': '1 Kings', 'my': 'ဓမ္မရာဇဝင်တတိယစောင်', 'abbrMy': '၃ရာ', 'abbrEn': '1Ki', 'chapters': 22, 'testament': BibleTestament.old, 'order': 11},
    {'id': '2kings', 'en': '2 Kings', 'my': 'ဓမ္မရာဇဝင်စတုတ္ထစောင်', 'abbrMy': '၄ရာ', 'abbrEn': '2Ki', 'chapters': 25, 'testament': BibleTestament.old, 'order': 12},
    {'id': '1chronicles', 'en': '1 Chronicles', 'my': 'ရာဇဝင်ချုပ်ပထမစောင်', 'abbrMy': '၁ချုပ်', 'abbrEn': '1Ch', 'chapters': 29, 'testament': BibleTestament.old, 'order': 13},
    {'id': '2chronicles', 'en': '2 Chronicles', 'my': 'ရာဇဝင်ချုပ်ဒုတိယစောင်', 'abbrMy': '၂ချုပ်', 'abbrEn': '2Ch', 'chapters': 36, 'testament': BibleTestament.old, 'order': 14},
    {'id': 'ezra', 'en': 'Ezra', 'my': 'ဧဇရမှတ်စာ', 'abbrMy': 'ဧဇရ', 'abbrEn': 'Ezr', 'chapters': 10, 'testament': BibleTestament.old, 'order': 15},
    {'id': 'nehemiah', 'en': 'Nehemiah', 'my': 'နေဟမိမှတ်စာ', 'abbrMy': 'နေဟမိ', 'abbrEn': 'Neh', 'chapters': 13, 'testament': BibleTestament.old, 'order': 16},
    {'id': 'esther', 'en': 'Esther', 'my': 'ဧသတာမှတ်စာ', 'abbrMy': 'ဧသတာ', 'abbrEn': 'Est', 'chapters': 10, 'testament': BibleTestament.old, 'order': 17},
    {'id': 'job', 'en': 'Job', 'my': 'ယောဘဝတ္ထု', 'abbrMy': 'ယောဘ', 'abbrEn': 'Job', 'chapters': 42, 'testament': BibleTestament.old, 'order': 18},
    {'id': 'psalms', 'en': 'Psalms', 'my': 'ဆာလံကျမ်း', 'abbrMy': 'ဆာ', 'abbrEn': 'Psa', 'chapters': 150, 'testament': BibleTestament.old, 'order': 19},
    {'id': 'proverbs', 'en': 'Proverbs', 'my': 'သုတ္တံကျမ်း', 'abbrMy': 'သု', 'abbrEn': 'Pro', 'chapters': 31, 'testament': BibleTestament.old, 'order': 20},
    {'id': 'ecclesiastes', 'en': 'Ecclesiastes', 'my': 'ဒေသိယဆရာကျမ်း', 'abbrMy': 'ဒေ', 'abbrEn': 'Ecc', 'chapters': 12, 'testament': BibleTestament.old, 'order': 21},
    {'id': 'songofsolomon', 'en': 'Song of Solomon', 'my': 'ရှောလမုန်းသီချင်း', 'abbrMy': 'ရှော', 'abbrEn': 'Sng', 'chapters': 8, 'testament': BibleTestament.old, 'order': 22},
    {'id': 'isaiah', 'en': 'Isaiah', 'my': 'ဟေရှာယအနာဂတ္တိကျမ်း', 'abbrMy': 'ဟေရှာ', 'abbrEn': 'Isa', 'chapters': 66, 'testament': BibleTestament.old, 'order': 23},
    {'id': 'jeremiah', 'en': 'Jeremiah', 'my': 'ယေရမိအနာဂတ္တိကျမ်း', 'abbrMy': 'ယေရမိ', 'abbrEn': 'Jer', 'chapters': 52, 'testament': BibleTestament.old, 'order': 24},
    {'id': 'lamentations', 'en': 'Lamentations', 'my': 'ယေရမိမြည်တမ်းစကား', 'abbrMy': 'မြည်', 'abbrEn': 'Lam', 'chapters': 5, 'testament': BibleTestament.old, 'order': 25},
    {'id': 'ezekiel', 'en': 'Ezekiel', 'my': 'ယေဇကျေလအနာဂတ္တိကျမ်း', 'abbrMy': 'ယေဇ', 'abbrEn': 'Ezk', 'chapters': 48, 'testament': BibleTestament.old, 'order': 26},
    {'id': 'daniel', 'en': 'Daniel', 'my': 'ဒံယေလအနာဂတ္တိကျမ်း', 'abbrMy': 'ဒံ', 'abbrEn': 'Dan', 'chapters': 12, 'testament': BibleTestament.old, 'order': 27},
    {'id': 'hosea', 'en': 'Hosea', 'my': 'ဟောရှေအနာဂတ္တိကျမ်း', 'abbrMy': 'ဟော', 'abbrEn': 'Hos', 'chapters': 14, 'testament': BibleTestament.old, 'order': 28},
    {'id': 'joel', 'en': 'Joel', 'my': 'ယောလအနာဂတ္တိကျမ်း', 'abbrMy': 'ယောလ', 'abbrEn': 'Jol', 'chapters': 3, 'testament': BibleTestament.old, 'order': 29},
    {'id': 'amos', 'en': 'Amos', 'my': 'အာမုတ်အနာဂတ္တိကျမ်း', 'abbrMy': 'အာမုတ်', 'abbrEn': 'Amo', 'chapters': 9, 'testament': BibleTestament.old, 'order': 30},
    {'id': 'obadiah', 'en': 'Obadiah', 'my': 'ဩဗဒိအနာဂတ္တိကျမ်း', 'abbrMy': 'ဩဗဒိ', 'abbrEn': 'Obad', 'chapters': 1, 'testament': BibleTestament.old, 'order': 31},
    {'id': 'jonah', 'en': 'Jonah', 'my': 'ယောနဝတ္ထု', 'abbrMy': 'ယောန', 'abbrEn': 'Jon', 'chapters': 4, 'testament': BibleTestament.old, 'order': 32},
    {'id': 'micah', 'en': 'Micah', 'my': 'မိက္ခာအနာဂတ္တိကျမ်း', 'abbrMy': 'မိက္ခာ', 'abbrEn': 'Mic', 'chapters': 7, 'testament': BibleTestament.old, 'order': 33},
    {'id': 'nahum', 'en': 'Nahum', 'my': 'နာဟုံအနာဂတ္တိကျမ်း', 'abbrMy': 'နာဟုံ', 'abbrEn': 'Nam', 'chapters': 3, 'testament': BibleTestament.old, 'order': 34},
    {'id': 'habakkuk', 'en': 'Habakkuk', 'my': 'ဟဗက္ကုတ်အနာဂတ္တိကျမ်း', 'abbrMy': 'ဟဗ', 'abbrEn': 'Hab', 'chapters': 3, 'testament': BibleTestament.old, 'order': 35},
    {'id': 'zephaniah', 'en': 'Zephaniah', 'my': 'ဇေဖနိအနာဂတ္တိကျမ်း', 'abbrMy': 'ဇေဖနိ', 'abbrEn': 'Zep', 'chapters': 3, 'testament': BibleTestament.old, 'order': 36},
    {'id': 'haggai', 'en': 'Haggai', 'my': 'ဟာဂဲအနာဂတ္တိကျမ်း', 'abbrMy': 'ဟာဂဲ', 'abbrEn': 'Hag', 'chapters': 2, 'testament': BibleTestament.old, 'order': 37},
    {'id': 'zechariah', 'en': 'Zechariah', 'my': 'ဇာခရိအနာဂတ္တိကျမ်း', 'abbrMy': 'ဇာခရိ', 'abbrEn': 'Zec', 'chapters': 14, 'testament': BibleTestament.old, 'order': 38},
    {'id': 'malachi', 'en': 'Malachi', 'my': 'မာလခိအနာဂတ္တိကျမ်း', 'abbrMy': 'မာလခိ', 'abbrEn': 'Mal', 'chapters': 4, 'testament': BibleTestament.old, 'order': 39},

    // New Testament (27 Books)
    {'id': 'matthew', 'en': 'Matthew', 'my': 'ရှင်မဿဲခရစ်ဝင်', 'abbrMy': 'မဿဲ', 'abbrEn': 'Mat', 'chapters': 28, 'testament': BibleTestament.newTestament, 'order': 40},
    {'id': 'mark', 'en': 'Mark', 'my': 'ရှင်မာကုခရစ်ဝင်', 'abbrMy': 'မာကု', 'abbrEn': 'Mrk', 'chapters': 16, 'testament': BibleTestament.newTestament, 'order': 41},
    {'id': 'luke', 'en': 'Luke', 'my': 'ရှင်လုကာခရစ်ဝင်', 'abbrMy': 'လုကာ', 'abbrEn': 'Luk', 'chapters': 24, 'testament': BibleTestament.newTestament, 'order': 42},
    {'id': 'john', 'en': 'John', 'my': 'ရှင်ယောဟန်ခရစ်ဝင်', 'abbrMy': 'ယော', 'abbrEn': 'Joh', 'chapters': 21, 'testament': BibleTestament.newTestament, 'order': 43},
    {'id': 'acts', 'en': 'Acts', 'my': 'တမန်တော်ဝတ္ထု', 'abbrMy': 'တမန်', 'abbrEn': 'Act', 'chapters': 28, 'testament': BibleTestament.newTestament, 'order': 44},
    {'id': 'romans', 'en': 'Romans', 'my': 'ရောမသြဝါဒစာ', 'abbrMy': 'ရော', 'abbrEn': 'Rom', 'chapters': 16, 'testament': BibleTestament.newTestament, 'order': 45},
    {'id': '1corinthians', 'en': '1 Corinthians', 'my': 'ကောရိန္သုဩဝါဒစာပထမစောင်', 'abbrMy': '၁ကော', 'abbrEn': '1Co', 'chapters': 16, 'testament': BibleTestament.newTestament, 'order': 46},
    {'id': '2corinthians', 'en': '2 Corinthians', 'my': 'ကောရိန္သုဩဝါဒစာဒုတိယစောင်', 'abbrMy': '၂ကော', 'abbrEn': '2Co', 'chapters': 13, 'testament': BibleTestament.newTestament, 'order': 47},
    {'id': 'galatians', 'en': 'Galatians', 'my': 'ဂလာတိဩဝါဒစာ', 'abbrMy': 'ဂလာ', 'abbrEn': 'Gal', 'chapters': 6, 'testament': BibleTestament.newTestament, 'order': 48},
    {'id': 'ephesians', 'en': 'Ephesians', 'my': 'ဧဖက်ဩဝါဒစာ', 'abbrMy': 'ဧဖက်', 'abbrEn': 'Eph', 'chapters': 6, 'testament': BibleTestament.newTestament, 'order': 49},
    {'id': 'philippians', 'en': 'Philippians', 'my': 'ဖိလိပ္ပိဩဝါဒစာ', 'abbrMy': 'ဖိလိပ္ပိ', 'abbrEn': 'Php', 'chapters': 4, 'testament': BibleTestament.newTestament, 'order': 50},
    {'id': 'colossians', 'en': 'Colossians', 'my': 'ကောလောသဲဩဝါဒစာ', 'abbrMy': 'ကောလော', 'abbrEn': 'Col', 'chapters': 4, 'testament': BibleTestament.newTestament, 'order': 51},
    {'id': '1thessalonians', 'en': '1 Thessalonians', 'my': 'သက်သာလောနိတ်ဩဝါဒစာပထမစောင်', 'abbrMy': '၁သက်', 'abbrEn': '1Th', 'chapters': 5, 'testament': BibleTestament.newTestament, 'order': 52},
    {'id': '2thessalonians', 'en': '2 Thessalonians', 'my': 'သက်သာလောနိတ်ဩဝါဒစာဒုတိယစောင်', 'abbrMy': '၂သက်', 'abbrEn': '2Th', 'chapters': 3, 'testament': BibleTestament.newTestament, 'order': 53},
    {'id': '1timothy', 'en': '1 Timothy', 'my': 'တိမောသေဩဝါဒစာပထမစောင်', 'abbrMy': '၁တိ', 'abbrEn': '1Ti', 'chapters': 6, 'testament': BibleTestament.newTestament, 'order': 54},
    {'id': '2timothy', 'en': '2 Timothy', 'my': 'တိမောသေဩဝါဒစာဒုတိယစောင်', 'abbrMy': '၂တိ', 'abbrEn': '2Ti', 'chapters': 4, 'testament': BibleTestament.newTestament, 'order': 55},
    {'id': 'titus', 'en': 'Titus', 'my': 'တိတုဩဝါဒစာ', 'abbrMy': 'တိတု', 'abbrEn': 'Tit', 'chapters': 3, 'testament': BibleTestament.newTestament, 'order': 56},
    {'id': 'philemon', 'en': 'Philemon', 'my': 'ဖိလေမုန်ဩဝါဒစာ', 'abbrMy': 'ဖိလေ', 'abbrEn': 'Phm', 'chapters': 1, 'testament': BibleTestament.newTestament, 'order': 57},
    {'id': 'hebrews', 'en': 'Hebrews', 'my': 'ဟေဗြဲဩဝါဒစာ', 'abbrMy': 'ဟေဗြဲ', 'abbrEn': 'Heb', 'chapters': 13, 'testament': BibleTestament.newTestament, 'order': 58},
    {'id': 'james', 'en': 'James', 'my': 'ရှင်ယာကုပ်ဩဝါဒစာ', 'abbrMy': 'ယာကုပ်', 'abbrEn': 'Jas', 'chapters': 5, 'testament': BibleTestament.newTestament, 'order': 59},
    {'id': '1peter', 'en': '1 Peter', 'my': 'ရှင်ပေတရုဩဝါဒစာပထမစောင်', 'abbrMy': '၁ပေ', 'abbrEn': '1Pe', 'chapters': 5, 'testament': BibleTestament.newTestament, 'order': 60},
    {'id': '2peter', 'en': '2 Peter', 'my': 'ရှင်ပေတရုဩဝါဒစာဒုတိယစောင်', 'abbrMy': '၂ပေ', 'abbrEn': '2Pe', 'chapters': 3, 'testament': BibleTestament.newTestament, 'order': 61},
    {'id': '1john', 'en': '1 John', 'my': 'ရှင်ယောဟန်ဩဝါဒစာပထမစောင်', 'abbrMy': '၁ယော', 'abbrEn': '1Jo', 'chapters': 5, 'testament': BibleTestament.newTestament, 'order': 62},
    {'id': '2john', 'en': '2 John', 'my': 'ရှင်ယောဟန်ဩဝါဒစာဒုတိယစောင်', 'abbrMy': '၂ယော', 'abbrEn': '2Jo', 'chapters': 1, 'testament': BibleTestament.newTestament, 'order': 63},
    {'id': '3john', 'en': '3 John', 'my': 'ရှင်ယောဟန်ဩဝါဒစာတတိယစောင်', 'abbrMy': '၃ယော', 'abbrEn': '3Jo', 'chapters': 1, 'testament': BibleTestament.newTestament, 'order': 64},
    {'id': 'jude', 'en': 'Jude', 'my': 'ရှင်ယုဒဩဝါဒစာ', 'abbrMy': 'ယုဒ', 'abbrEn': 'Jud', 'chapters': 1, 'testament': BibleTestament.newTestament, 'order': 65},
    {'id': 'revelation', 'en': 'Revelation', 'my': 'ဗျာဒိတ်ကျမ်း', 'abbrMy': 'ဗျာ', 'abbrEn': 'Rev', 'chapters': 22, 'testament': BibleTestament.newTestament, 'order': 66},
  ];

  Future<Map<String, dynamic>?> _loadBookJson(String bookId) async {
    if (_bookJsonCache.containsKey(bookId)) {
      return _bookJsonCache[bookId];
    }
    try {
      final jsonStr = await rootBundle.loadString('assets/data/judson/$bookId.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      _bookJsonCache[bookId] = data;
      return data;
    } catch (e) {
      debugPrint('Error loading Judson book $bookId: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _loadKachinBookJson(String bookId) async {
    if (_kachinBookJsonCache.containsKey(bookId)) {
      return _kachinBookJsonCache[bookId];
    }
    try {
      final jsonStr = await rootBundle.loadString('assets/data/kachin/$bookId.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      _kachinBookJsonCache[bookId] = data;
      return data;
    } catch (e) {
      debugPrint('No asset json for Kachin book $bookId: $e');
      return null;
    }
  }

  @override
  Future<List<BookModel>> getPreSeededBooks(String languageId) async {
    final isMyanmarScript = languageId == 'my_burmese' ||
        languageId == 'shan' ||
        languageId == 'karen_sgaw';
    final isKachin = languageId == 'kachin_jinghpaw';

    return _all66BooksRaw.map((data) {
      final bookId = data['id'] as String;
      String bookName;
      String bookAbbr;

      if (isKachin && _kachinBookNames.containsKey(bookId)) {
        bookName = _kachinBookNames[bookId]!['name']!;
        bookAbbr = _kachinBookNames[bookId]!['abbr']!;
      } else if (isMyanmarScript) {
        bookName = data['my'] as String;
        bookAbbr = data['abbrMy'] as String;
      } else {
        bookName = data['en'] as String;
        bookAbbr = data['abbrEn'] as String;
      }

      return BookModel(
        id: bookId,
        languageId: languageId,
        name: bookName,
        nameEn: data['en'] as String,
        abbreviation: bookAbbr,
        totalChapters: data['chapters'] as int,
        testament: data['testament'] as BibleTestament,
        order: data['order'] as int,
      );
    }).toList();
  }

  @override
  Future<List<VerseModel>> getPreSeededVerses({
    required String languageId,
    required String bookId,
    required int chapterNumber,
  }) async {
    if (languageId == 'my_burmese') {
      final bookData = await _loadBookJson(bookId);
      if (bookData != null && bookData.containsKey('chapters')) {
        final chapters = bookData['chapters'] as List<dynamic>;
        if (chapterNumber > 0 && chapterNumber <= chapters.length) {
          final chapterData = chapters[chapterNumber - 1] as Map<String, dynamic>;
          final versesData = chapterData['verses'] as List<dynamic>;
          final loadedVerses = versesData.map((v) {
            final vMap = v as Map<String, dynamic>;
            return VerseModel(
              verseNumber: vMap['verse'] as int,
              text: (vMap['text'] as String).trim(),
            );
          }).toList();
          if (loadedVerses.isNotEmpty) {
            return loadedVerses;
          }
        }
      }
    } else if (languageId == 'kachin_jinghpaw') {
      final bookData = await _loadKachinBookJson(bookId);
      if (bookData != null && bookData.containsKey('chapters')) {
        final chapters = bookData['chapters'] as List<dynamic>;
        if (chapterNumber > 0 && chapterNumber <= chapters.length) {
          final chapterData = chapters[chapterNumber - 1] as Map<String, dynamic>;
          final versesData = chapterData['verses'] as List<dynamic>;
          final loadedVerses = versesData.map((v) {
            final vMap = v as Map<String, dynamic>;
            return VerseModel(
              verseNumber: vMap['verse'] as int,
              text: (vMap['text'] as String).trim(),
            );
          }).toList();
          if (loadedVerses.isNotEmpty) {
            return loadedVerses;
          }
        }
      }
    }

    // Fallback for non-Burmese or dynamic regional languages
    final sampleTexts = _getScriptSampleTexts(languageId);
    return List.generate(
      8,
      (i) => VerseModel(
        verseNumber: i + 1,
        text: '${sampleTexts[i % sampleTexts.length]} (Chapter $chapterNumber:${i + 1})',
      ),
    );
  }

  List<String> _getScriptSampleTexts(String languageId) {
    switch (languageId) {
      case 'my_burmese':
        return const [
          'ဘုရားသခင်၏ နှုတ်ကပတ်တော်သည် သန့်ရှင်းလျက် အသက်ရှင်သော တရားဒေသနာတော်ဖြစ်၏။',
          'ထာဝရဘုရားသည် ငါ၏သိုးထိန်းဖြစ်တော်မူ၏။ ငါသည် လိုလေသေးမရှိ။',
          'ကိုယ်တော်၏ နှုတ်ကပတ်တော်သည် ငါ၏ခြေရှေ့မှာ မီးအိမ်ဖြစ်၍၊ ငါ၏လမ်းပေါ်မှာ အလင်းဖြစ်ပါ၏။',
          'ဘုရားသခင်သည် မိမိ၌ တစ်ပါးတည်းသော သားတော်ကို စွန့်တော်မူသည်တိုင်အောင် လောကီသားတို့ကို ချစ်တော်မူ၏။',
        ];
      case 'kachin_jinghpaw':
        return const [
          'Shawng lam hta Karai Kasang gaw sumsing lamu hte ga dak hpe hpan da nngai. (JCLB)',
          'Madu Karai Kasang gaw nye a rem ai wa rai nga ai, ngai hpa hpe mung n ra a nga nngai. (JCLB)',
          'Na a mungga gaw nye a lagaw shara hta hku hkyeng rai nna, nye a lam hta htoi hpoi rai nga ai. (JCLB)',
          'Karai Kasang gaw mudi kasha hpe jaw nna mudi masha hpe grai tsaw ra nga ai. (JCLB)',
        ];
      case 'chin_hakha':
        return const [
          'Bawipa Pathian cu ka zohkhenhtu a si, zianghman ka bau lo ding.',
          'A hnin le a êng cu ka ke hmaiah meinnêk a si i ka lamlipi ah thanglainak a si.',
          'Pathian nih a Fapa hrin sun khat cu vawlei mi hna dawtnak caah a pe.',
        ];
      case 'shan':
        return const [
          'ၸဝ်ႈၽႃႉပဵၼ်ၵေႃႉထိင်းမႄးၵူၼ်းႁဝ်း။',
          'တြႃးၸဝ်ႈပဵၼ်ႁၢင်ႈလႅင်းၼႃႈတၢင်းၵူၼ်းႁဝ်း။',
          'ၸဝ်ႈၽႃႉႁၵ်ႉပႅၼ်းၵူၼ်းမိူင်းလူင်ၼႆႉ လႄႈပၼ်လုၵ်ႈၸဝ်ႈ။',
        ];
      case 'karen_sgaw':
        return const [
          'ယွာ်မ့ၢ်ယမိၢ်ယပါ လၢအကွၢ်ထွဲယၤတပူၤလှီု။',
          'နကလုာ်ကထါမ့ၢ်ယမိထူလၢယခံထံး။',
          'ယွာ်အဲၣ်ကမျ့ၢ်ဖိလၢဟီၣ်ခိၣ်န့ၣ်လီၤ။',
        ];
      case 'kayah_li':
        return const [
          'ꤊꤢ꤬ꤛꤢꤩ ꤡꤢꤵꤝꤟꤥꤔꤌꤣ ꤗꤟꤢꤩ ꤢ꤬ꤟꤢꤩꤒꤥ꤬ꤔꤌꤣꤗꤟꤢꤩ။',
          'ꤔꤌꤣꤒꤥ꤬ ꤊꤤ꤬ꤢ꤬ꤛꤢꤩ ꤡꤢꤵ ꤗꤟꤢꤩꤒꤥ꤬ꤔꤌꤣꤗꤟꤢꤩ။',
        ];
      default:
        return const [
          'The Lord is my shepherd; I shall not want.',
          'Thy word is a lamp unto my feet, and a light unto my path.',
          'For God so loved the world, that he gave his only begotten Son.',
          'The grace of our Lord Jesus Christ be with you all. Amen.',
        ];
    }
  }
}
