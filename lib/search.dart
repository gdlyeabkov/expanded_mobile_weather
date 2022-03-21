import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {

  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => SearchPageState();

}

class SearchPageState extends State<SearchPage> {

  TextEditingController searchFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchFieldController.selection = TextSelection(
      extentOffset: 0,
      baseOffset: 0
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: 250,
          height: 35,
          child: TextField(
            controller: searchFieldController,
            decoration: InputDecoration.collapsed(
              hintText: 'Поиск'
            ),
            autofocus: true
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
        children: [
          Container(
            child: Text(
              'Добавить текущее место'
            ),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255)
            ),
            padding: EdgeInsets.all(
              25
            ),
            margin: EdgeInsets.all(
              25
            )
          ),
          Text(
            'Введите название\nместоположения'
          )
        ],
      )
    );
  }

}