import 'itemBarril.dart';

class VendaBarril{
  String donoDaLoja;
  String tituloDaLoja;
  String mapaDaLoja;
  int coordX;
  int coordY;
  List<ItemBarril> itensVendidos= [];

  VendaBarril(String donoDaLoja, String tituloDaLoja, String mapaDaLoja, int coordX, int coordY){
    this.donoDaLoja= donoDaLoja;
    this.tituloDaLoja= tituloDaLoja;
    this.mapaDaLoja= mapaDaLoja;
    this.coordX= coordX;
    this.coordY= coordY;
  }

  String getDonoDaLoja(){
    return this.donoDaLoja;
  }

  String getTituloDaLoja(){
    return this.tituloDaLoja;
  }

  String getMapaDaLoja(){
    return this.mapaDaLoja;
  }

  int getCoordX(){
    return this.coordX;
  }

  int getCoordY(){
    return this.coordY;
  }

  void inserirItem(ItemBarril item){
    this.itensVendidos.add(item);
  }

}