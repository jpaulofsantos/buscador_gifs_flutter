import 'dart:convert';
import 'package:buscador_gifs_flutter/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart'; //1 - importando http
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async {//2 - criando a função para buscar os Gifs

    http.Response response;

    if (_search == null || _search.isEmpty) //se _search estiver nulo, retorno os trending gifs, caso contrário, usar o valor da busca
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=ckgLLQ7QefA3jlPCYHhcOCY1IQzlkT9m&limit=27&rating=g");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=ckgLLQ7QefA3jlPCYHhcOCY1IQzlkT9m&q=$_search&limit=26&offset=$_offset&rating=g&lang=en");

    return json.decode(response.body); //retorna o json da API
  }

  @override
  void initState() {
    super.initState();
    //_getGifs().then((map) => print(map));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(//3 - criando Scaffold
      appBar: AppBar(//4 - criando AppBar
        backgroundColor: Colors.black,
        title: Image.network(
          "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif",), //5 - no title da AppBar, podemos utilizar diversos Widgets, inclusive imagens. Neste caso, pegando uma imagem da web
        centerTitle: true,
      ),
      backgroundColor: Colors.black, //5 - background black
      body: Column(//6 - layout do corpo - Coluna
        children: [
          Padding(//8 - Colocando o TextFiled dentro do padding
            padding: EdgeInsets.all(10.0),
            child: TextField(//7 - iniciando com os filhos - textfield
              decoration: InputDecoration(
                  labelText: "Pesquise Aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text) {//22 -  função que recebe o texto a ser pesquisado
                setState(() {// 23 - reconstroi o FutureBuilder com a pesquisa
                  _search = text;
                  _offset = 0;
                });
              }, //add pesquisa de gifs
            ),
          ),
          Expanded(//8 - criando expanded logo abaixo do textfield, ira ocupar o espaço da pagina
              child: FutureBuilder(
            future: _getGifs(), //9 - indica a função para buscar o json
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {//10 - switch para validar o status dp snapshot
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Container(//11 - caso esteja aguardando resposta, retornar o CircularProgress
                    width: 200.0,
                    height: 200.0,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // cor do circular
                      strokeWidth: 5.0, // largura
                    ),
                  );
                default:
                  if (snapshot.hasError)
                    return Container();
                  else
                    return _createGifTable(context, snapshot); //12 retornando a GridView
              }
            },
          ))
        ],
      ),
    );
  }

  int _getCount(List dados) {//22 função que retorna a quantidade de quadros na grid
    if (_search == null) {
      return dados.length;
    } else {
      return dados.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {//13 criando a grid de gifs
    return GridView.builder(
        padding: EdgeInsets.all(10.0), //14 add padding
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(//15 - criando griddelegate
            crossAxisCount: 3, //16 - 2 itens por linha dentro da grid
            crossAxisSpacing: 10.0, //17 - espaçamento entre o conteudo das grids
            mainAxisSpacing: 10.0 //18 - espaçamento entre as linhas
            ),
        itemCount: _getCount(snapshot.data["data"]), //21 //23- retornando a quantidade de gifs que é setada na url do response
        itemBuilder: (context, index) {//19 - montando o itembuilder

          if (_search == null ||
              index < snapshot.data["data"].length) //24 - Se o search for nulo
            return GestureDetector(//20 - fornecendo opção para clicar na imagem
              child: FadeInImage.memoryNetwork(//28 - usando o FadeIn para os gifs aparecem de forma "suave"
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height"]['url'],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              onTap: () {//25 - clicando sobre o GIF e mostrando em uma nova página
                Navigator.push(context,
                    MaterialPageRoute(builder: //26 - criando a rota para chamar a página desejada
                            (context) => GifPage(snapshot.data["data"][index])));
              },
              onLongPress: () {//27 - compartilhando via Share
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]['url']);
              },
            );
          else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 60.0,
                    ),
                    Text("Carregar mais...",
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    )
                  ],
                ),
                onTap: () {//23 - função clicar em + - carrega a tela com mais itens
                  setState(() {
                    _offset += 26; //24 adicionando mais 26 itens
                  });
                },
              ),
            );
        });
  }
}
