class MapaBarril{
  String nome;
  int maxCoordX;
  int maxCoordY;
  int coordY;
  int coordX;

  MapaBarril(String nome, int maxCoordX, int maxCoordY, int coordX, int coordY){
    this.nome= nome;
    this.coordX= coordX;
    this.coordY= coordY;
    this.maxCoordY= maxCoordY;
    this.maxCoordX= maxCoordX;
  }

  String getNome(){
    return this.nome;
  }

  int getCoordX(){
    return this.coordX;
  }

  int getCoordY(){
    return this.coordY;
  }

  int getMaxCoordX(){
    return this.maxCoordX;
  }

  int getMaxCoordY(){
    return this.maxCoordY;
  }
}