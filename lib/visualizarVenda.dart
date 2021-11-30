import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/src/rendering/sliver_persistent_header.dart';
import 'package:http/http.dart';
import 'databaseMapas.dart';
import 'itemBarril.dart';
import 'mapaBarril.dart';
import 'vendaBarril.dart';
import 'package:intl/intl.dart';
import 'databaseBarril.dart';
import 'databaseOptions.dart';

class VisualizarVendas extends StatefulWidget{ //OBS: Mudei para STATEFUL, rollback se der errado. (PRECISO PARA O POPUP MENU)
    final ItemBarril itemSelecionado;
    final VendaBarril venda;

    VisualizarVendas({this.itemSelecionado, this.venda});
  @override
  State<StatefulWidget> createState() {
    return VisualizarVendasState(
      itemSelecionado: itemSelecionado,
      venda: venda
    );
  }
}

class VisualizarVendasState extends State<VisualizarVendas>{

  final ItemBarril itemSelecionado;
  final VendaBarril venda;

  VisualizarVendasState({this.itemSelecionado, this.venda});

    @override
  void initState(){
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    final mapaDB= databaseMapas.where((String p)=>p.contains(venda.getMapaDaLoja()));
    
    List<String> auxiliar= [];

    MapaBarril mapa;

    if(mapaDB.isNotEmpty){
      for(String s in mapaDB){
        auxiliar= s.split(',');
      }
      mapa= MapaBarril(
      auxiliar[0],
      int.parse(auxiliar[1]), 
      int.parse(auxiliar[2]),
      venda.getCoordX(),  //coordenada X da loja
      venda.getCoordY(),   //coordenada Y da loja
      );
    }
    else{
      mapa= MapaBarril(
      'mapNotFound',
      500, 
      500,
      venda.getCoordX(),  //coordenada X da loja
      venda.getCoordY(),   //coordenada Y da loja
      );
    }


    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: VisualizarVendasHeader(
              minExtent: 80,
              maxExtent: MediaQuery.of(context).size.width,
              mapa: mapa,

            ),
            ),
            SliverFixedExtentList(
              itemExtent: 60,
              delegate: SliverChildListDelegate(
                [
                  Container(
                    alignment: Alignment.center,
                    color: Colors.blue[50],
                    child:Text('Loja de ${venda.getDonoDaLoja()}',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                  )
                ]
              ),
            ),
            SliverFixedExtentList(
              itemExtent: 80,
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index){
                    String preco= venda.itensVendidos[index].getPreco().toString();
                    var formatar= NumberFormat("#,###");
                    String formatada= formatar.format(int.parse(preco)).toString();
                    formatada= formatada.replaceAll(',', '.'); 
                    Image slot0=slotImage(venda.itensVendidos[index], 0);
                    Image slot1=slotImage(venda.itensVendidos[index], 1);
                    Image slot2=slotImage(venda.itensVendidos[index], 2);
                    Image slot3=slotImage(venda.itensVendidos[index], 3);
                    List<Widget> imagens= [
                      Text('$formatada zeny',
                        style: TextStyle(
                            fontSize: 12.0,
                        )
                      ),
                    ];
                    imagens.add(slot0);
                    if(venda.itensVendidos[index].getSlot1()==4757){
                      imagens.add(slot2);
                      imagens.add(slot3);
                      imagens.add(slot1);
                    }
                    else{
                      imagens.add(slot1);
                      imagens.add(slot2);
                      imagens.add(slot3);
                    }
                    String nome= completeNamer(venda.itensVendidos[index]); //Nome com options caso o item as tenha
                    return Container(
                      color: Colors.white,
                      child: PopupMenuButton(
                        tooltip: 'Clique no item para ver mais informações!',
                        padding: EdgeInsets.all(0),
                          itemBuilder: (BuildContext context){
                            List<PopupMenuEntry<Object>> itensMostrados= popUpMenuList(venda.itensVendidos[index]);
                            return itensMostrados;  
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child:Image.asset('assets/images/${venda.itensVendidos[index].getNomeImage()}.png'),
                            ),
                            title: Text(nome,
                              style: TextStyle(
                                fontSize: 16.0
                              ),
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: imagens,
                            ),
                            trailing: Text('x${venda.itensVendidos[index].getQuantidade()}',
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          )
                      )
                    );
                  },
                childCount: venda.itensVendidos.length,
              ),
            ),
        ],
      ),
    );
  }


 List<PopupMenuEntry<Object>> popUpMenuList(ItemBarril item){ //Constrói a lista de coisas a aparecer no menu flutuante
    List<PopupMenuEntry<Object>> lista= [];
    int ifCount= 0;
    if(item.getOptionAmount()>0)
      lista.add(
        PopupMenuItem(
          child:Center( 
            child: Text('${item.getNomeSlot()} [${item.getOptionAmount().toString()}P]')
          )
        )
      );
    else
      lista.add(
        PopupMenuItem(
          child:Center( 
            child: Text('${item.getNomeSlot()}')
          )
        )
      );
    lista.add(
      PopupMenuDivider(
        height: 0,
      )
    );
    if(item.getSlot0()!=0 && item.getSlot0()!=4757){
      lista.add(
        PopupMenuItem(
          child: ListTile(
            dense:true,
            leading: Image.asset('assets/images/${getfromDB(item.getSlot0().toString(), 2)}.png'),
            title: Text(getfromDB(item.getSlot0().toString(), 1),style: TextStyle(fontSize: 13))
          )
        )
      );
      ifCount++;
    }
    if(item.getSlot1()!=0 && item.getSlot1()!=4757){
      lista.add(
        PopupMenuItem(
          child: ListTile(
            dense: true,
            leading: Image.asset('assets/images/${getfromDB(item.getSlot1().toString(), 2)}.png'),
            title: Text(getfromDB(item.getSlot1().toString(), 1),style: TextStyle(fontSize: 13)),
          )
        )
      );
      ifCount++;
    }
    if(item.getSlot2()!=0 && item.getSlot2()!=4757){
      lista.add(
        PopupMenuItem(
          child: ListTile(
            dense: true,
            leading: Image.asset('assets/images/${getfromDB(item.getSlot2().toString(), 2)}.png'),
            title: Text(getfromDB(item.getSlot2().toString(), 1),style: TextStyle(fontSize: 13)),
          )
        )
      );
      ifCount++;
    }
    if(item.getSlot3()!=0 && item.getSlot3()!=4757){
      lista.add(
        PopupMenuItem(
          child: ListTile(
            dense: true,
            leading: Image.asset('assets/images/${getfromDB(item.getSlot3().toString(), 2)}.png'),
            title: Text(getfromDB(item.getSlot3().toString(), 1),style: TextStyle(fontSize: 13)),
          )
        )
      );
      ifCount++;
    }
    if(ifCount >0)
      lista.add(
        PopupMenuDivider(
          height: 0,
        )
      );
    String texto;
    int aux;
    if(item.getOptionValue0()!=0){
      aux= int.parse(getFromOptionsDB(item.getOption0().toString(), 2)); 
      if(aux == 1)//percentual
        texto= '${getFromOptionsDB(item.getOption0().toString(),1)} +${item.getOptionValue0().toString()}%';
      else //base
        texto= '${getFromOptionsDB(item.getOption0().toString(),1)} +${item.getOptionValue0().toString()}';
      lista.add(
        PopupMenuItem(
          child:Center( 
            child: Text(texto,style: TextStyle(fontSize: 13))
          )
        )
      );
      ifCount++;
    }
    if(item.getOptionValue1()!=0){
      aux= int.parse(getFromOptionsDB(item.getOption1().toString(), 2)); 
      if(aux == 1)//percentual
        texto= '${getFromOptionsDB(item.getOption1().toString(),1)} +${item.getOptionValue1().toString()}%';
      else //base
        texto= '${getFromOptionsDB(item.getOption1().toString(),1)} +${item.getOptionValue1().toString()}';
      lista.add(
        PopupMenuItem(
          child:Center( 
            child: Text(texto,style: TextStyle(fontSize: 13))
          )
        )
      );
      ifCount++;
    }
    if(item.getOptionValue2()!=0){
      aux= int.parse(getFromOptionsDB(item.getOption2().toString(), 2)); 
      if(aux == 1)//percentual
        texto= '${getFromOptionsDB(item.getOption2().toString(),1)} +${item.getOptionValue2().toString()}%';
      else //base
        texto= '${getFromOptionsDB(item.getOption2().toString(),1)} +${item.getOptionValue2().toString()}';
      lista.add(
        PopupMenuItem(
          child:Center( 
            child: Text(texto,style: TextStyle(fontSize: 13))
          )
        )
      );
      ifCount++;
    }
    if(item.getOptionValue3()!=0){
      aux= int.parse(getFromOptionsDB(item.getOption3().toString(), 2)); 
      if(aux == 1)//percentual
        texto= '${getFromOptionsDB(item.getOption3().toString(),1)} +${item.getOptionValue3().toString()}%';
      else //base
        texto= '${getFromOptionsDB(item.getOption3().toString(),1)} +${item.getOptionValue3().toString()}';
      lista.add(
        PopupMenuItem(
          child:Center( 
            child: Text(texto,style: TextStyle(fontSize: 13))
          )
        )
      );
      ifCount++;
    }
    if(item.getOptionValue4()!=0){
      aux= int.parse(getFromOptionsDB(item.getOption4().toString(), 2)); 
      if(aux == 1)//percentual
        texto= '${getFromOptionsDB(item.getOption4().toString(),1)} +${item.getOptionValue4().toString()}%';
      else //base
        texto= '${getFromOptionsDB(item.getOption4().toString(),1)} +${item.getOptionValue4().toString()}';
      lista.add(
        PopupMenuItem(
          child:Center( 
            child: Text(texto,style: TextStyle(fontSize: 13))
          )
        )
      );
      ifCount++;
    }
    if(ifCount == 0)
      lista.add(
        PopupMenuItem(
          child:Center(child: Text('Não há nada para se ver aqui.')),
        )
      );
    return lista;
  }

  String completeNamer(ItemBarril item){
    if(item.getOptionAmount()>0) //Checa se o número de options do item é maior que zero
      return(item.getNomeSlot()+' ['+item.getOptionAmount().toString()+'P]'); //Retorna o nome com refinamento e o número de Options
    else
      return(item.getNomeSlot());
  }

  Image slotImage(ItemBarril item, int slotNumber){
    if(slotNumber == 0){
      if(item.getSlot0()!=0 && item.getSlot0()!= 4757){//Há algo neste slot
        return Image.asset('assets/images/${getfromDB(item.getSlot0().toString(), 2)}.png');
      }
      else if(item.getSlot0()==0 && slotNumber+1 <= int.parse(item.getSlot().substring(1,2))) //Slot Vazio
        return Image.asset('assets/images/cardEmpty.png');
      else if(item.getSlot0()==0 && slotNumber+1 > int.parse(item.getSlot().substring(1,2))){ //Slot não existe
        if(int.parse(item.getSlot().substring(1,2)) == 0)
          return Image.asset('assets/images/noCard.png');
        else{
          if(item.getForgeStatus()==true) // Itens forjados não tem cartas portanto não deve aparecer a carta sombreada
            return Image.asset('assets/images/noCard.png');
          else
            return Image.asset('assets/images/cardUnavailable.png');
        }
      }
      else{//Slot não tem nada
        return Image.asset('assets/images/noCard.png');
      }
    }
    else if(slotNumber == 1){
      if(item.getSlot1()!=0 && item.getSlot1()!= 4757){//Há algo neste slot
        return Image.asset('assets/images/${getfromDB(item.getSlot1().toString(), 2)}.png');
      }
      else if(item.getSlot1()==0 && slotNumber+1 <= int.parse(item.getSlot().substring(1,2))) //Slot Vazio
        return Image.asset('assets/images/cardEmpty.png');
      else if(item.getSlot1()==0 && slotNumber+1 > int.parse(item.getSlot().substring(1,2))){ //Slot não existe
        if(int.parse(item.getSlot().substring(1,2)) == 0)
          return Image.asset('assets/images/noCard.png');
        else{
          if(item.getForgeStatus()==true) // Itens forjados não tem cartas portanto não deve aparecer a carta sombreada
            return Image.asset('assets/images/noCard.png');
          else
            return Image.asset('assets/images/cardUnavailable.png');
        }
      }
      else{//Slot não tem nada
        return Image.asset('assets/images/noCard.png');
      }
    }
    else if(slotNumber == 2){
      if(item.getSlot2()!=0 && item.getSlot2()!= 4757){//Há algo neste slot
        return Image.asset('assets/images/${getfromDB(item.getSlot2().toString(), 2)}.png');
      }
      else if(item.getSlot2()==0 && slotNumber+1 <= int.parse(item.getSlot().substring(1,2))) //Slot Vazio
        return Image.asset('assets/images/cardEmpty.png');
      else if(item.getSlot2()==0 && slotNumber+1 > int.parse(item.getSlot().substring(1,2))){ //Slot não existe
        if(int.parse(item.getSlot().substring(1,2)) == 0)
          return Image.asset('assets/images/noCard.png');
        else{
          if(item.getForgeStatus()==true) // Itens forjados não tem cartas portanto não deve aparecer a carta sombreada
            return Image.asset('assets/images/noCard.png');
          else
            return Image.asset('assets/images/cardUnavailable.png');
        }
      }
      else{//Slot não tem nada
        return Image.asset('assets/images/noCard.png');
      }
    }
    else{ //Slotnumber == 3
      if(item.getSlot3()!=0 && item.getSlot3()!= 4757){//Há algo neste slot
        return Image.asset('assets/images/${getfromDB(item.getSlot3().toString(), 2)}.png');
      }
      else if(item.getSlot3()==0 && slotNumber+1 <= int.parse(item.getSlot().substring(1,2))) //Slot Vazio
        return Image.asset('assets/images/cardEmpty.png');
      else if(item.getSlot3()==0 && slotNumber+1 > int.parse(item.getSlot().substring(1,2))){ //Slot não existe
        if(int.parse(item.getSlot().substring(1,2)) == 0)
          return Image.asset('assets/images/noCard.png');
        else{
          if(item.getForgeStatus()==true) // Itens forjados não tem cartas portanto não deve aparecer a carta sombreada
            return Image.asset('assets/images/noCard.png');
          else
            return Image.asset('assets/images/cardUnavailable.png');
        }
      }
      else{//Slot não tem nada
        return Image.asset('assets/images/noCard.png');
      }
    }
  }

  Image slotImage2(ItemBarril item, int slotNumber){
    if(int.parse(item.getSlot().substring(1,2))>=slotNumber){//Item tem este "slot"
      if(slotNumber==0){
        if(item.getSlot0() == 0){ //Slot de carta vazio
          return Image.asset('assets/images/cardEmpty.png');
        }
        else if(item.getSlot0() == 4757){ //Slot com item em branco
          return Image.asset('assets/images/noCard.png');
        }
        else
          return Image.asset('assets/images/${getfromDB(item.getSlot0().toString(), 2)}.png'); //Modificador Forjado ou carta
        /*else if(item.getSlot0()>=4750 && item.getSlot0()<=4792){ //Slot com modificador forjado
          return Image.asset('assets/images/${getfromDB(item.getSlot0().toString(), 2)}.png');
        }*/
      }
      else if(slotNumber==1){
        if(item.getSlot1() == 0){ //Slot de carta vazio
          return Image.asset('assets/images/cardEmpty.png');
        }
        else if(item.getSlot1() == 4757){ //Slot com item em branco
          return Image.asset('assets/images/noCard.png');
        }
        else
          return Image.asset('assets/images/${getfromDB(item.getSlot1().toString(), 2)}.png'); //Modificador Forjado ou carta
        /*else if(item.getSlot1()>=4750 && item.getSlot1()<=4792){ //Slot com modificador forjado
          return Image.asset('assets/images/${getfromDB(item.getSlot1().toString(), 2)}.png');
        }*/
      }
      else if(slotNumber==2){
        if(item.getSlot2() == 0){ //Slot de carta vazio
          return Image.asset('assets/images/cardEmpty.png');
        }
        else if(item.getSlot2() == 4757){ //Slot com item em branco
          return Image.asset('assets/images/noCard.png');
        }
        else
          return Image.asset('assets/images/${getfromDB(item.getSlot2().toString(), 2)}.png'); //Modificador Forjado ou carta
        /*else if(item.getSlot2()>=4750 && item.getSlot2()<=4792){ //Slot com modificador forjado
          return Image.asset('assets/images/${getfromDB(item.getSlot2().toString(), 2)}.png');
        }*/
      }
      else{ //SlotNumber = 3
        if(item.getSlot3() == 0){ //Slot de carta vazio
          return Image.asset('assets/images/cardEmpty.png');
        }
        else if(item.getSlot3() == 4757){ //Slot com item em branco
          return Image.asset('assets/images/noCard.png');
        }
        else
          return Image.asset('assets/images/${getfromDB(item.getSlot3().toString(), 2)}'); //Modificador Forjado ou carta
       /* else if(item.getSlot3()>=4750 && item.getSlot3()<=4792){ //Slot com modificador forjado
          return Image.asset('assets/images/${getfromDB(item.getSlot3().toString(), 2)}.png');
        }*/
      }
    }
    else{//Item não tem este "slot"
      if(slotNumber-1 == 0 && item.getSlot0()!= 0 && (item.getSlot0()<4750 || item.getSlot0()>4792)){//Item possui uma carta no slot0
        return Image.asset('assets/images/cardUnavailable.png');
      }
      else if(slotNumber-1 == 1 && item.getSlot1()!= 0 && (item.getSlot1()<4750 || item.getSlot1()>4792)){//Item possui uma carta no slot0
        return Image.asset('assets/images/cardUnavailable.png');
      }
      else if(slotNumber-1 == 2 && item.getSlot2()!= 0 && (item.getSlot2()<4750 || item.getSlot2()>4792)){//Item possui uma carta no slot0
        return Image.asset('assets/images/cardUnavailable.png');
      }
      else
        return Image.asset('assets/images/noCard.png');
    }
  }



}


class VisualizarVendasHeader implements SliverPersistentHeaderDelegate{

  VisualizarVendasHeader({
    this.mapa,
    this.minExtent,
    @required this.maxExtent
  });

  final double minExtent;
  final double maxExtent;
  final MapaBarril mapa;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child:CustomPaint(
                  foregroundPainter:Painter(
                    coordX: mapa.getCoordX(),
                    coordY: mapa.getCoordY(),
                    maxCoordX: mapa.getMaxCoordX(),
                    maxCoordY: mapa.getMaxCoordY(),
                    shrinkOffset: shrinkOffset,
                  ),
                  child:Image.asset('assets/imagesMaps/${mapa.getNome()}.png',
                        fit: BoxFit.cover,
                        ),
                  ),
          ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black54],
              stops: [0.5, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              tileMode: TileMode.repeated
            ),
          ),
        ),
        Positioned(
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
          child: Text('${mapa.getNome()[0].toUpperCase()}${mapa.getNome().substring(1)}  ${mapa.getCoordX()},${mapa.getCoordY()}',
            style: TextStyle(
              fontSize: fontSize(shrinkOffset),
              color: Colors.white.withOpacity(titleOpacity(shrinkOffset)),

            ),
          ),
        ),
      ],
    );
  }

  double fontSize(double shrinkOffset){ //20
    double offSet= 1.0-max(0.0, shrinkOffset)/maxExtent;
    if(offSet<0.667)
      offSet=0.667;
    return 30.0*offSet;
  }

  double titleOpacity(double shrinkOffset){
    double opacity= 1.0-max(0.0, shrinkOffset)/maxExtent;
    if(opacity < 0.7)
      opacity = 0.7;
    return opacity;
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;

}

class Painter extends CustomPainter{
  Painter({this.coordX, this.coordY, this.maxCoordX, this.maxCoordY, this.shrinkOffset});
  final int coordX;
  final int coordY;
  final int maxCoordX;
  final int maxCoordY;
  final double shrinkOffset;

  @override
  void paint(Canvas canvas, Size size) {
    var paint= Paint();
    paint.color= Colors.pink.withOpacity(paintOpacity(shrinkOffset, size));
    paint.style= PaintingStyle.stroke;
    paint.strokeWidth= 2.0;

    double posCanvasX= rangeX(maxCoordX,coordX, size);
    double posCanvasY= rangeY(maxCoordY, coordY, size);

    canvas.drawCircle(Offset(posCanvasX, (size.height-posCanvasY)), 10, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

}

double paintOpacity(double shrinkOffset, Size size){
  double porcentagem= (shrinkOffset*100/size.height)/100;
  double valorReal;
  if(porcentagem>1.0)
    porcentagem= 1.0;
  if(porcentagem<0.1)
    porcentagem= 0.0;
  
  valorReal= 1.0 - porcentagem;
  return valorReal;
}

double rangeX(int maxCoordMapa, int coordenada, Size size){
  double porcentagem= (coordenada*100/maxCoordMapa)/100;
  double posCanvas= (porcentagem*size.width);
  return posCanvas;
}

double rangeY(int maxCoordMapa, int coordenada, Size size){
  double porcentagem= (coordenada*100/maxCoordMapa)/100;
  double posCanvas= (porcentagem*size.height);
  return posCanvas;
}

  String getfromDB(String id, int operation){//retorna ID, Nome, Nome Image, Slot a depender da operation
    final item= databaseBarril.where((String p)=>p.toLowerCase().startsWith(id+','));
    List<String> auxiliar= [];
    if(item.isEmpty){
      auxiliar.add('000');
      auxiliar.add('Unknown Item');
      auxiliar.add('bbe7b0fa2e706e67');
      auxiliar.add('[0]');
    }
    else{
      auxiliar= item.toString().split(',');
    }
    if(operation==0)//retorna ID
      return auxiliar[0].substring(1, auxiliar[0].length);
    else if(operation==1)//retorna Nome
      return auxiliar[1];
      else if(operation==2)//retorna NomeImage
        return auxiliar[2];
        else if(operation==3){//retorna slot
          return auxiliar[3];
        }
    else
      return "erro";
  }

  String getFromOptionsDB(String id, int operation){//retorna ID ou Nome e se é porcentagem a depender da operation
    final item= databaseOptions.where((String p)=>p.toLowerCase().startsWith(id+','));
    List<String> auxiliar= [];
    if(item.isEmpty){
      auxiliar.add('000');
      auxiliar.add('Unknown Option');
      auxiliar.add('1');
    }
    else{
      auxiliar= item.toString().split(',');
    }
    if(operation==0)//retorna ID
      return auxiliar[0].substring(1, auxiliar[0].length);
    else if(operation==1)//retorna Nome
      return auxiliar[1].substring(0, auxiliar[1].length);
    else if(operation==2)//retorna se é porcentagem (1=porcentagem, 0= base)
      return auxiliar[2].substring(0, auxiliar[2].length-1);
    else
      return "erro";
  }