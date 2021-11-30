class BuscasRecentes{
   int id;
   int itemId;

  BuscasRecentes({this.id, this.itemId});

 int getId(){
   return this.id;
 }

 int getItemId(){
   return this.itemId;
 }

//Convert To Map
 Map<String, dynamic> toMap(){
   var map= Map<String, dynamic>();
   if(id != null)
    map['id']= id;
   map['itemId']= itemId;

   return map;
 }

//Convert to Object
  BuscasRecentes.fromMapObject(Map<String, dynamic> map){
    this.id= map['id'];
    this.itemId= map['itemId'];
  }

}