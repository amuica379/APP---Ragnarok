import 'package:path/path.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'sqlDatabase.dart';

class DatabaseHelper{
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String buscasRecentesTable= 'buscasRecentes_table';
  String colId= 'id';
  String colItemId= 'itemId';

  DatabaseHelper._createInstance();
  factory DatabaseHelper(){
    if(_databaseHelper == null)
      _databaseHelper= DatabaseHelper._createInstance(); //Executa somente uma vez por utilização do app
    return _databaseHelper;
  }

  Future<Database> get database async{
    if(_database == null){
      _database= await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async{
    //Obtém o diretório da Database
    Directory directory= await getApplicationDocumentsDirectory();
    String path= directory.path + 'buscasRecentes.db';

    //  Abre/Cria a database no diretório
    var databaseBuscasRecentes= openDatabase(path, version: 1, onCreate: _createDB);
    return databaseBuscasRecentes;
    
  }

  void _createDB(Database db, int newVersion) async{
    //Comando SQL para criar a table
    await db.execute('CREATE TABLE $buscasRecentesTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colItemId TEXT');
  
  }

}