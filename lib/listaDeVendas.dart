import 'package:appbarrilro/visualizarVenda.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'vendaBarril.dart';
import 'itemBarril.dart';
import 'databaseBarril.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';


class ListaDeVendas extends StatefulWidget{

  //ListaDeVendas({this.vendas, this.itemSelecionado});
  ListaDeVendas({this.itemSelecionado, this.searchAll});

  //final List<VendaBarril> vendas;
  final ItemBarril itemSelecionado;
  final bool searchAll;

  @override
  State<StatefulWidget> createState() {
    return ListaDeVendasState(
      //vendas: vendas,
      itemSelecionado: itemSelecionado,
      searchAll: searchAll
    );
  }

}

class ListaDeVendasState extends State<ListaDeVendas>{

  //ListaDeVendasState({this.vendas, this.itemSelecionado});
  ListaDeVendasState({this.itemSelecionado, this.searchAll});


  List<VendaBarril> vendas;
  bool isLoading;
  bool listEmpty;
  final ItemBarril itemSelecionado;
  final bool searchAll;

  @override
  void initState(){
    super.initState();
    isLoading= true;
    if(!searchAll)
      fetchListaInit();
    else
      fetchListaInitAll();
  }


  @override
  Widget build(BuildContext context) {

    if(isLoading==true){
      return Container(
        alignment: Alignment.center,
        color: Colors.white,
        child:CircularProgressIndicator(
          backgroundColor: Colors.white,
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 238, 167, 19)),
        )
      );
    }

    else if(vendas.length==0){
      return  Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Color.fromARGB(255, 238, 167, 19),//Cinza
          title: Text("Toque para voltar"),
        ),
        backgroundColor: Colors.white,
          body:RefreshIndicator(
            color: Color.fromARGB(255, 238, 167, 19),
            onRefresh:()async{
                List<VendaBarril> novaLista= await updateLista();
                setState(() {
                  this.vendas= novaLista;
                });
              },
            child: ListView(
              children: <Widget>[
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.250, 
                    horizontal: MediaQuery.of(context).size.width * 0.20),
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: SvgPicture.asset('assets/imagesV/poringSearch.svg',
                        height: MediaQuery.of(context).size.height * 0.25,//200.0,
                        width: MediaQuery.of(context).size.width * 0.23,//200.0,
                        ),
                      ),
                      Text("Não há ninguém vendendo isto.\n Sentimos muito!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(255, 128, 128, 128),
                          fontWeight: FontWeight.bold,
                      ),
                      ),
                    ],
                  )
                )
              ],
            )
          )
        );
    }

    else{
      String appBarTitle;
      if(!searchAll)
        appBarTitle= "Este item é vendido em:";
      else
        appBarTitle= "Lojas abertas no momento:";
      return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Color.fromARGB(255, 238, 167, 19),//Cinza
          title: Text(appBarTitle),
        ),
        body: RefreshIndicator(
          color: Color.fromARGB(255, 238, 167, 19),
          onRefresh:()async{
            List<VendaBarril> novaLista= await updateLista();
            setState(() {
                  // print(itemSelecionado.getNome());
              this.vendas= novaLista;
              //print(vendas[0].itensVendidos.length);
              // print('tamanho vendas'+vendas.length.toString());
            });
          },
          child:
            ListView.builder(
              itemCount: vendas.length,
              itemBuilder: (context,index){
                String nomeSlot;
                String preco;
                if(!searchAll){
                  nomeSlot= '${findNomeSlot(itemSelecionado.getId(), vendas, index)}';
                  preco= '${findPreco(itemSelecionado.getId(), vendas, index)} zeny';
                }
                else{
                  nomeSlot= vendas[index].getDonoDaLoja();
                  preco= '${vendas[index].itensVendidos.length.toString()} Itens';
                }
              return ListTile(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                          return VisualizarVendas(
                            itemSelecionado: itemSelecionado,
                            venda: vendas[index],
                          );
                        }));
                },
                leading:CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Image.asset('assets/images/shop.png')
                ),
                title: Text(vendas[index].getTituloDaLoja()),
                subtitle: Text(nomeSlot),
                trailing: Text(preco),
                  );
            }
          )
        )
      );
    }
  }


  String findPreco(int id, List<VendaBarril> vendas, int index){
      for(int j=0; j<vendas[index].itensVendidos.length; j++){
        if(vendas[index].itensVendidos[j].getId()==id){
          String preco= vendas[index].itensVendidos[j].getPreco().toString();
          var formatar= NumberFormat("#,###");
          String formatada= formatar.format(int.parse(preco)).toString();
          formatada= formatada.replaceAll(',', '.');
          return formatada;
        }
      }
      return 'erro';
  }

  String findNomeSlot(int id, List<VendaBarril> vendas, int index){
      for(int j=0; j<vendas[index].itensVendidos.length; j++){
        if(vendas[index].itensVendidos[j].getId()==id)
          return vendas[index].itensVendidos[j].getNomeSlot();
      }
      return 'erro';
  }

  Future<List<VendaBarril>> fetchPostAll (BuildContext context)async{
    final response= await http.get('http://barrilro.servegame.com/apirest/product/readAll.php');
    Map<String,dynamic> data= JSON.jsonDecode(response.body);
    List<VendaBarril> vendaNull=[];
    if(data["erro"] != null){
      return vendaNull;
    }
    else{
    List<VendaBarril> vendas = [];
      for(int i= 0; i< data.length; i++){
        vendas.add(VendaBarril(
          data[i.toString()]["donoDaLoja"],
          data[i.toString()]["tituloDaLoja"],
          data[i.toString()]["mapaDaLoja"],
          int.parse(data[i.toString()]["x"]),
          int.parse(data[i.toString()]["y"])
          ));
        for(int j=0; j<data[i.toString()]["itensVendidos"].length; j++){
          vendas[i].inserirItem(ItemBarril(
            int.parse(data[i.toString()]["itensVendidos"][j.toString()]["idDoItem"]),
            getfromDB(data[i.toString()]["itensVendidos"][j.toString()]["idDoItem"], 1),
            getfromDB(data[i.toString()]["itensVendidos"][j.toString()]["idDoItem"], 2),
            getfromDB(data[i.toString()]["itensVendidos"][j.toString()]["idDoItem"], 3),
          ));
          vendas[i].itensVendidos[j].setRefinamento(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["refinamento"]));
         // if(int.parse(vendas[i].itensVendidos[j].getSlot().substring(1,2))>0){
            vendas[i].itensVendidos[j].setSlot0(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["slot0"]));
            vendas[i].itensVendidos[j].setSlot1(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["slot1"]));
            vendas[i].itensVendidos[j].setSlot2(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["slot2"]));
            vendas[i].itensVendidos[j].setSlot3(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["slot3"]));
         // }
          vendas[i].itensVendidos[j].setQuantidade(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["quantidadeDoItem"]));
          vendas[i].itensVendidos[j].setPreco(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["precoDoItem"]));

          vendas[i].itensVendidos[j].setOption0(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_id0"]));
          vendas[i].itensVendidos[j].setOptionValue0(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_val0"]));
          vendas[i].itensVendidos[j].setOption1(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_id1"]));
          vendas[i].itensVendidos[j].setOptionValue1(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_val1"]));
          vendas[i].itensVendidos[j].setOption2(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_id2"]));
          vendas[i].itensVendidos[j].setOptionValue2(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_val2"]));
          vendas[i].itensVendidos[j].setOption3(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_id3"]));
          vendas[i].itensVendidos[j].setOptionValue3(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_val3"]));
          vendas[i].itensVendidos[j].setOption4(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_id4"]));
          vendas[i].itensVendidos[j].setOptionValue4(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_val4"]));
          vendas[i].itensVendidos[j].setOptionAmount();
          vendas[i].itensVendidos[j].setNomeSlot(vendas[i].itensVendidos[j].getNome(), vendas[i].itensVendidos[j].getSlot());
        }
      }
      return vendas;
    }
  }


  Future<List<VendaBarril>> fetchPost (String itemId, ItemBarril itemSelecionado, BuildContext context)async{
    final response= await http.get('http://barrilro.servegame.com/apirest/product/readById.php?id=$itemId');
    Map<String,dynamic> data= JSON.jsonDecode(response.body);
    List<VendaBarril> vendaNull=[];
    if(data["erro"] != null){
      return vendaNull;
    }
    else{
    List<VendaBarril> vendas = [];
      for(int i= 0; i< data.length; i++){
        vendas.add(VendaBarril(
          data[i.toString()]["donoDaLoja"],
          data[i.toString()]["tituloDaLoja"],
          data[i.toString()]["mapaDaLoja"],
          int.parse(data[i.toString()]["x"]),
          int.parse(data[i.toString()]["y"])
          ));
        for(int j=0; j<data[i.toString()]["itensVendidos"].length; j++){
          vendas[i].inserirItem(ItemBarril(
            int.parse(data[i.toString()]["itensVendidos"][j.toString()]["idDoItem"]),
            getfromDB(data[i.toString()]["itensVendidos"][j.toString()]["idDoItem"], 1),
            getfromDB(data[i.toString()]["itensVendidos"][j.toString()]["idDoItem"], 2),
            getfromDB(data[i.toString()]["itensVendidos"][j.toString()]["idDoItem"], 3),
          ));
          vendas[i].itensVendidos[j].setRefinamento(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["refinamento"]));
         // if(int.parse(vendas[i].itensVendidos[j].getSlot().substring(1,2))>0){
            vendas[i].itensVendidos[j].setSlot0(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["slot0"]));
            vendas[i].itensVendidos[j].setSlot1(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["slot1"]));
            vendas[i].itensVendidos[j].setSlot2(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["slot2"]));
            vendas[i].itensVendidos[j].setSlot3(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["slot3"]));
         // }
          vendas[i].itensVendidos[j].setQuantidade(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["quantidadeDoItem"]));
          vendas[i].itensVendidos[j].setPreco(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["precoDoItem"]));

          vendas[i].itensVendidos[j].setOption0(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_id0"]));
          vendas[i].itensVendidos[j].setOptionValue0(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_val0"]));
          vendas[i].itensVendidos[j].setOption1(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_id1"]));
          vendas[i].itensVendidos[j].setOptionValue1(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_val1"]));
          vendas[i].itensVendidos[j].setOption2(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_id2"]));
          vendas[i].itensVendidos[j].setOptionValue2(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_val2"]));
          vendas[i].itensVendidos[j].setOption3(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_id3"]));
          vendas[i].itensVendidos[j].setOptionValue3(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_val3"]));
          vendas[i].itensVendidos[j].setOption4(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_id4"]));
          vendas[i].itensVendidos[j].setOptionValue4(int.parse(data[i.toString()]["itensVendidos"][j.toString()]["option_val4"]));
          vendas[i].itensVendidos[j].setOptionAmount();
          vendas[i].itensVendidos[j].setNomeSlot(vendas[i].itensVendidos[j].getNome(), vendas[i].itensVendidos[j].getSlot());
        }
      }
      return vendas;
    }
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

  Future<List<VendaBarril>> updateLista()async{
    List<VendaBarril> resultado= [];
    if(!searchAll)
      resultado= await fetchLista();
    else
      resultado= await fetchListaAll();

    return resultado;
  }

  Future<List<VendaBarril>>fetchLista()async{
    List<VendaBarril> resultado= await  fetchPost(itemSelecionado.getId().toString(), itemSelecionado, context);
    return resultado;
  }

  Future<List<VendaBarril>>fetchListaAll()async{
    List<VendaBarril> resultado= await  fetchPostAll(context);
    return resultado;
  }

  fetchListaInit()async{
    List<VendaBarril> resultado= await  fetchPost(itemSelecionado.getId().toString(), itemSelecionado, context);
    setState(() {
      this.vendas= resultado;
      isLoading=false;
    });
  }

  fetchListaInitAll()async{
    List<VendaBarril> resultado= await  fetchPostAll(context);
    setState(() {
      this.vendas= resultado;
      isLoading=false;
    });
  }

}