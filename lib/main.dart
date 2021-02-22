import 'package:buscador_gifs_flutter/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:buscador_gifs_flutter/ui/home_page.dart'; // importando o package HomePage

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    theme: ThemeData(// aplicando o theme para inserir a borda
        hintColor: Colors.white,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          hintStyle: TextStyle(color: Colors.white),
        )),
  ));
}
