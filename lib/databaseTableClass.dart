import 'itemBarril.dart';


class PesquisaRecente{
  int id;
  int priority;
  ItemBarril item;

  PesquisaRecente(int id, int priority, ItemBarril item){
    this.id= id;
    this.priority= priority;
    this.item= item;
  }

  int getId(){
    return this.id;
  }

  int getPriority(){
    return this.priority;
  }

  ItemBarril getItemBarril(){
    return this.item;
  }

  void setId(int id){
    this.id= id;
  }

  void setPriority(int priority){
    this.priority= priority;
  }

  void setItemBarril(ItemBarril item){
    this.item= item;
  }

  Map<String, dynamic> toMap(){
    var map= Map<String, dynamic>();
    if(id != null)
      map['id']= id;
    map['priority']= priority;
    map['item']= item;

    return map;
  }

  PesquisaRecente.fromMap(Map<String, dynamic> map){
    this.id= map['id'];
    this.priority= map['priority'];
    this.item= map['item'];
  }

}