import 'package:appbarrilro/listaDeVendas.dart';
import 'package:flutter/material.dart';
import 'databaseBarril.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'itemBarril.dart';
import 'visualizarVenda.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(AppBarril());

class AppBarril extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Barril',
      home: TelaDeInicio(),
    );
  }
}

class TelaDeInicio extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return TelaDeInicioState();
  }
}

class TelaDeInicioState extends State<TelaDeInicio>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer:Drawer(),
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Color.fromARGB(255, 238, 167, 19),//Laranja
          title: Text(
            "Toque na lupa para pesquisar itens!",
            style: TextStyle(
              fontSize: 14.0
            ),
          ),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.search),
              onPressed:(){
                showSearch(context: context, delegate: DataSearch());
              }
            ),
          ],
        ),
        body:Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('Clique aqui para buscar todas as lojas ->'),
                IconButton(icon: Icon(Icons.search),
                  onPressed: (){
                    ItemBarril dummy;
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ListaDeVendas(itemSelecionado: dummy, searchAll: true,);
                    }));
                  },
                )
              ],
            )
          ],
        ),
      );
  }
}

class DataSearch extends SearchDelegate<String>{
  DataSearch({
    String label= 'Nome do Item',
  }) : super(
        searchFieldLabel: label,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
  );

  final pesquisasRecentes= [
    "7608,Ticket de Promoção,c4edc6f92e706e67,[0]",
    "2819,Manual do Espadachim,b8b6b9fdc3a55fb9ab2e706e67,[0]"
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
  
    //actions for app bar
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: (){
        query= "";
      },)
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //ícone na esquerda
    return IconButton(icon: AnimatedIcon(
      icon: AnimatedIcons.menu_arrow, 
      progress: transitionAnimation), 
      onPressed: (){
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    //mostrar resultado baseado na seleção
    
    if(query.isEmpty){//Usuário buscou sem digitar nada
        return SingleChildScrollView(
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
              Text("Por favor digite algo antes de pesquisar!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 128, 128, 128),
                  fontWeight: FontWeight.bold,
              ),
              ),
            ],
          )
        );
    }
    else{
      String queryLowerCase="";
      queryLowerCase=query.toLowerCase();

      final listaSugestao= databaseBarril.where((String p)=>p.toLowerCase().contains(queryLowerCase)).toList();

      if(listaSugestao.length<=0){//Item não existe
        return SingleChildScrollView(
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
              Text("Oops... O Item pesquisado não foi encontrado na nossa Database!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 128, 128, 128),
                  fontWeight: FontWeight.bold,
              ),
              ),
            ],
          )
        );
      }
      else{
        List<ItemBarril> listaItens= [];
        List<String> auxiliar= [];
        for(int i=0; i<listaSugestao.length; i++){
          auxiliar=listaSugestao[i].split(',');
          listaItens.add(ItemBarril(int.parse(auxiliar[0]), auxiliar[1], auxiliar[2], auxiliar[3]));
        }
        listaItens.sort((a,b)=> a.getNome().compareTo(b.getNome()));
        final styleBold= TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
        return ListView.builder(itemBuilder: (context,index)=>ListTile(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return ListaDeVendas(itemSelecionado: listaItens[index], searchAll: false,);
            }));
          },
          leading:Image.asset('assets/images/${listaItens[index].getNomeImage()}.png'),
          //leading:Icon(Icons.location_city),
          title: RichText(text: TextSpan(
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold
            ),
            children: _gerarSpans(listaItens[index].getNomeSlot(), query, styleBold)
            )
          ),
          ),
          itemCount: listaItens.length,
        );
      }
    } 

  }

  @override
  Widget buildSuggestions(BuildContext context) {

    //mostrar quando alguem pesquisar algo
    String queryLowerCase="";
    if(query.isNotEmpty)
      queryLowerCase=query.toLowerCase();
    final listaSugestao= queryLowerCase.isEmpty ? pesquisasRecentes
    :databaseBarril.where((String p)=>p.toLowerCase().contains(queryLowerCase)).toList();

    List<ItemBarril> listaItens= [];
    List<String> auxiliar= [];
    for(int i=0; i<listaSugestao.length; i++){
       auxiliar=listaSugestao[i].split(',');
       listaItens.add(ItemBarril(int.parse(auxiliar[0]), auxiliar[1], auxiliar[2], auxiliar[3]));
     }
    listaItens.sort((a,b)=> a.getNome().compareTo(b.getNome()));

    if(pesquisasRecentes.length>0 && listaSugestao.length<=0){//Item não existe
      return SingleChildScrollView(
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
            Text("Oops... O Item pesquisado não foi encontrado na nossa Database!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(255, 128, 128, 128),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
      );
    }

    final styleBold= TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
    if(query.isEmpty){//O usuário não digitou nada na busca
      return ListView.builder(itemBuilder: (context,index)=>ListTile(
        onTap: (){
          
        },
        leading:Image.asset('assets/images/${listaItens[index].getNomeImage()}.png'),
        //leading:Icon(Icons.location_city),
        title: RichText(text: TextSpan(
          text: listaItens[index].getNomeSlot().substring(0, query.length),
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold
          ),
          children: [TextSpan(
            text: listaItens[index].getNomeSlot().substring(query.length),
            style: TextStyle(
              color: Colors.grey
            ),
          )]
        )
        ),
        ),
        itemCount: listaItens.length,
      );
    }
    else{// O usuário digitou algo i.e. query.legth!=0
      return ListView.builder(itemBuilder: (context,index)=>ListTile(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context){
              return ListaDeVendas(
                itemSelecionado: listaItens[index],
                searchAll: false,
              );
            }));
        },
        leading:Image.asset('assets/images/${listaItens[index].getNomeImage()}.png'),
        //leading:Icon(Icons.location_city),
        title: RichText(text: TextSpan(
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold
          ),
          children: _gerarSpans(listaItens[index].getNomeSlot(), query, styleBold)
          )
        ),
        ),
        itemCount: listaItens.length,
      );
    }

  }

  List<TextSpan> _gerarSpans(String text, String query, TextStyle style){
      List<TextSpan> spans=[];
      int spanBoundary= 0;
      while(spanBoundary<text.length){
        final startIndex= text.toLowerCase().indexOf(query.toLowerCase(), spanBoundary);
        if(startIndex == -1){//Não achou mais nada
          spans.add(TextSpan(text: text.substring(spanBoundary),
           style: TextStyle(color: Colors.grey)));
          return spans;
        }
        if(startIndex>spanBoundary){
          spans.add(TextSpan(text: text.substring(spanBoundary, startIndex)));
        }
        final endIndex= startIndex + query.length;
        final spanText= text.substring(startIndex, endIndex);
        spans.add(TextSpan(text: spanText, style: style));

        spanBoundary= endIndex;

      }
      return spans;
  }
}