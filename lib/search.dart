import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {

  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => SearchPageState();

}

class SearchPageState extends State<SearchPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Container(
            width: 250,
            height: 35,
            child: TextField(
              decoration: InputDecoration.collapsed(
                hintText: 'Поиск'
              ),
            )
          ),
          actions: [
            FlatButton(
              onPressed: () {

              },
              child: Icon(
                Icons.mic
              )
            )
          ]
        ),
        body: Column(

      )
    );
  }

}