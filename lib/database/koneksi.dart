import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper {
  static Future<void> createTables(sql.Database db) async {
    await db.execute("""

      CREATE TABLE IF NOT EXISTS pengeluaranKategori(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        nama TEXT,
        icon TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );

      """);

    await db.execute("""

      CREATE TABLE IF NOT EXISTS pemasukanKategori(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        nama TEXT,
        icon TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );

      """);

    await db.execute("""

      CREATE TABLE IF NOT EXISTS Transaksi(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        pengeluaranKategoriId INTEGER,
        pemasukanKategoriId INTEGER,
        jumlahTransaksi REAL,
        tanggal DATETIME,
        deskripsi TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (pengeluaranKategoriId) REFERENCES pengeluaranKategori(id)
        FOREIGN KEY (pemasukanKategoriId) REFERENCES pemasukanKategori(id)
      );

      """);

    await db.execute("""

      CREATE TABLE IF NOT EXISTS RencanaKeuangan (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        nama TEXT,
        totalJumlah REAL,
        progresTarget REAL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );

      """);
  }

  static Future<void> onCreate(sql.Database db) async {
    var batch = db.batch();
    batch.insert(
      'pengeluaranKategori',
      {
        'nama': 'Makanan',
        'icon': '{"pack": "material", "key": "fastfood_outlined"}'
      },
    );

    batch.insert(
      'pengeluaranKategori',
      {
        'nama': 'Tranportasi',
        'icon': '{"pack": "material", "key": "directions_transit_outlined"}'
      },
    );
    batch.insert(
      'pengeluaranKategori',
      {
        'nama': 'Baju',
        'icon': '{"pack": "material", "key": "dry_cleaning_outlined"}'
      },
    );

    batch.insert(
      'pengeluaranKategori',
      {
        'nama': 'Hiburan',
        'icon': '{"pack": "material", "key": "live_tv_outlined"}'
      },
    );
    batch.insert(
      'pengeluaranKategori',
      {
        'nama': 'Investasi',
        'icon': '{"pack": "material", "key": "candlestick_chart_outlined"}'
      },
    );
    batch.insert(
      'pengeluaranKategori',
      {
        'nama': 'Lainnya',
        'icon': '{"pack": "material", "key": "auto_fix_high_outlined"}'
      },
    );
    batch.insert(
      'pemasukanKategori',
      {'nama': 'Gaji', 'icon': '{"pack": "material", "key": "attach_money"}'},
    );
    await batch.commit();
  }

  static Future<sql.Database> initializeDB() async {
    return sql.openDatabase(
      'database.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
        await onCreate(database);
      },
      onUpgrade: (sql.Database database, int oldVersion, int newVersion) async {
        await createTables(database);
      },
    );
  }

  Future<List<Map<String, Object?>>> accessDatabase(String query) async {
    final database = await initializeDB();
    List<Map<String, Object?>> result = await database.rawQuery(query);

    return result;
  }
}
