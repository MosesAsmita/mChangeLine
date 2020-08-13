import 'dart:async';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:onexbet/constants/constant.dart';
import 'package:onexbet/constants/externalWidget.dart';
import 'package:onexbet/ressources/connection/onexbetNeworkingHelper.dart';
import 'package:onexbet/ressources/local/onexbetDataBase.dart';

class Statistiques extends StatefulWidget {
  final String numero;
  final OnexbetDataBase onexbetDataBase;
  Statistiques({this.numero, this.onexbetDataBase});
  @override
  _StatistiquesState createState() => _StatistiquesState();
}

class _StatistiquesState extends State<Statistiques> {
  List<Map<String, dynamic>> docList = [];
  Timer getData;
  bool spinner = true;

  @override
  void dispose() {
    super.dispose();
    getData.cancel();
  }

  @override
  void initState() {
    super.initState();

    initialData();
    getData = Timer.periodic(
        Duration(seconds: 80), (Timer t) => fetchAllStatistiques(widget.numero));
  }

  initialData() async {
    await fetchAllStatistiques(widget.numero);
  }

  fetchAllStatistiques(String numero) async {
    spinner = true;
    setState(() {});
    try{
      docList = [];
      List<Transfert> transfert = await widget.onexbetDataBase.getAllTransferts();
      Map<String, dynamic> doc = {};
      for (int i = 0; i < transfert.length; i++) {
        if (transfert[i].numero == '+229' + numero) {
          doc = await OnexbetNetworkingHelper.getDocuments(
              collectionName: transfert[i].type,
              documentId: transfert[i].documentID);
          if(doc !=  null){
            docList.add(doc);
          }
        }
      }
    }catch(e){
      print(e);
      docList = [];
      spinner = false;
      if (this.mounted) {
        setState(() {});
      }
    }
    spinner = false;
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiques'),
        backgroundColor: Colors.orange,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () async {
                spinner = true;
                if (this.mounted) {
                  setState(() {});
                }
                await fetchAllStatistiques(widget.numero);
              })
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        progressIndicator: waitMsg(),
        child: presentation(),
      ),
    );
  }

  presentation() {
    docList.sort((a, b) =>
        DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    Map<String, dynamic> prev;
    bool shownHeader = false;

    List<Widget> _listChildren = <Widget>[];
    docList.forEach((Map<String, dynamic> document) {
      if (prev != null &&
          DateTime.parse(document['date'].substring(0, 10)) !=
              DateTime.parse(prev['date'].substring(0, 10))) {
        shownHeader = false;
      }

      if (!shownHeader) {
        _listChildren.add(ListTile(
          title: Text(
            document['date'].substring(0, 10),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ));
        prev = document;
        shownHeader = true;
      }

      _listChildren.add(Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        width: double.maxFinite,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Card(
            elevation: 5,
            shape: Border(
                left: BorderSide(
                    color: document.containsKey('appartenant')
                        ? Colors.orange
                        : Colors.blue,
                    width: 5),
                right: BorderSide(
                    color: document['status'] ? Colors.green : Colors.red,
                    width: 3)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        document.containsKey('appartenant')
                            ? 'Retrait'
                            : 'Recharge',
                        style: textStyle.copyWith(
                            fontSize: 20.0, fontWeight: FontWeight.normal),
                      ),
                      Text(
                        document['date'].substring(0, 16),
                        style: textStyle.copyWith(
                            fontSize: 12.0, fontWeight: FontWeight.normal),
                      )
                    ],
                  ),
                  Text(
                    'ID 1XBET: ${document['id_xbet']}',
                    style: textStyle.copyWith(
                        fontSize: 15.0, fontWeight: FontWeight.normal),
                  ),
                  Text(
                    'Montant: ${document['montant']} XOF',
                    style: textStyle.copyWith(
                        fontSize: 14.0, fontWeight: FontWeight.normal),
                  ),
                  Text(
                    'Numéro de Téléphone: ${document['numero']}',
                    style: textStyle.copyWith(
                        fontSize: 15.0, fontWeight: FontWeight.normal),
                  ),
                  Visibility(
                    visible: document.containsKey('appartenant'),
                    child: Text(
                      'Appartenant à: ${document['appartenant']}',
                      style: textStyle.copyWith(
                          fontSize: 14.0, fontWeight: FontWeight.normal),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text('Status: '),
                      Text(
                        document['status']
                            ? 'Effectué'
                            : 'En cours de traitement',
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
    });
    return (docList.isNotEmpty)
        ? ListView(children: _listChildren)
        : Center(
            child: Text('Aucunnes données'),
          );
  }
}
