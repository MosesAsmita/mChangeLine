import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:onexbet/constants/constant.dart';
import 'package:onexbet/constants/externalWidget.dart';
import 'package:onexbet/ressources/connection/onexbetNeworkingHelper.dart';

class Transactions extends StatefulWidget {
  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions>
    with SingleTickerProviderStateMixin {
  List<DocumentSnapshot> docList = [];
  Timer getData;
  bool spinner = true;
  String currentCollection = 'recharges';
  TabController tabController;
  @override
  void dispose() {
    super.dispose();
    getData.cancel();
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2)
      ..addListener(() {
        switch (tabController.index) {
          case 0:
            spinner = true;
            currentCollection = 'recharges';
            setState(() {});
            fetchAllTransactions();
            break;
          case 1:
            spinner = true;
            currentCollection = 'retraits';
            setState(() {});
            fetchAllTransactions();
            break;
        }
      });
    initialData();
    getData = Timer.periodic(
        Duration(seconds: 80), (Timer t) => fetchAllTransactions());
  }

  initialData() async {
    await fetchAllTransactions();
  }

  fetchAllTransactions() async {
    docList = [];
    docList = await OnexbetNetworkingHelper.getData(
        collectionName: currentCollection);
    spinner = false;
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Transcations'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () async {
                spinner = true;
                if (this.mounted) {
                  setState(() {});
                }
                await fetchAllTransactions();
              })
        ],
        bottom: TabBar(
          tabs: [
            Tab(
              child: Text(
                "Recharges",
              ),
            ),
            Tab(
              child: Text("Retraits"),
            ),

          ],
          indicatorColor: Colors.white,
          controller: tabController,
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        progressIndicator: waitMsg(),
        child: TabBarView(
          controller: tabController,
          children: [presentation(), presentation()],
        ),
      ),
    );
  }

  presentation() {
    docList.sort((a, b) => DateTime.parse(b.data['date'])
        .compareTo(DateTime.parse(a.data['date'])));
    DocumentSnapshot prev;
    bool shownHeader = false;

    List<Widget> _listChildren = <Widget>[];
    docList.forEach((DocumentSnapshot documentSnapshot) {
      if (prev != null &&
          DateTime.parse(documentSnapshot.data['date'].substring(0, 10)) !=
              DateTime.parse(prev.data['date'].substring(0, 10))) {
        shownHeader = false;
      }

      if (!shownHeader) {
        _listChildren.add(ListTile(
          title: Text(
            documentSnapshot.data['date'].substring(0, 10),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ));
        prev = documentSnapshot;
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
                    color: documentSnapshot.data.containsKey('appartenant')
                        ? Colors.orange
                        : Colors.blue,
                    width: 5),
                right: BorderSide(
                    color: documentSnapshot.data['status']
                        ? Colors.green
                        : Colors.red,
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
                        documentSnapshot.data.containsKey('appartenant')
                            ? 'Retrait'
                            : 'Recharge',
                        style: textStyle.copyWith(
                            fontSize: 20.0, fontWeight: FontWeight.normal),
                      ),
                      Text(
                        documentSnapshot.data['date'].substring(0, 16),
                        style: textStyle.copyWith(
                            fontSize: 12.0, fontWeight: FontWeight.normal),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'ID 1XBET: ',
                        style: textStyle.copyWith(
                            fontSize: 15.0, fontWeight: FontWeight.normal),
                      ),
                      SelectableText(
                        '${documentSnapshot.data['id_xbet']}',
                        style: textStyle.copyWith(
                            fontSize: 15.0, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  Text(
                    'Montant: ${documentSnapshot.data['montant']} XOF',
                    style: textStyle.copyWith(
                        fontSize: 14.0, fontWeight: FontWeight.normal),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'Numéro de Téléphone: ',
                        style: textStyle.copyWith(
                            fontSize: 15.0, fontWeight: FontWeight.normal),
                      ),
                      SelectableText(
                        '${documentSnapshot.data['numero']}',
                        style: textStyle.copyWith(
                            fontSize: 15.0, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: documentSnapshot.data.containsKey('appartenant'),
                    child:
                    Text(
                      'Appartenant à: ${documentSnapshot.data['appartenant']}',
                      style: textStyle.copyWith(
                          fontSize: 14.0, fontWeight: FontWeight.normal),
                    ),
                  ),
                  Visibility(
                    visible: documentSnapshot.data.containsKey('appartenant'),
                    child:   Row(
                      children: <Widget>[
                        Text(
                          'Code: ',
                          style: textStyle.copyWith(
                              fontSize: 15.0, fontWeight: FontWeight.normal),
                        ),
                        SelectableText(
                          '${documentSnapshot.data['code']}',
                          style: textStyle.copyWith(
                              fontSize: 15.0, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text('Status: '),
                      Text(
                        documentSnapshot.data['status']
                            ? 'Effectué'
                            : 'En cours de traitement',
                      )
                    ],
                  ),
                  Visibility(
                    visible: !documentSnapshot.data['status'],
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: raisedButton(context, label: 'Valider',
                              onPressed: () async {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('M-Change Line'),
                                  content: Text(
                                    'Cette transaction a-t-elle été déjà effectuée?',
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(
                                        'Oui',
                                        style: textStyle.copyWith(
                                            color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        spinner = true;
                                        setState(() {});
                                        await OnexbetNetworkingHelper
                                            .updateDocuments(
                                                collection: currentCollection,
                                                dataToSend: {'status': true},
                                                documentID: documentSnapshot
                                                    .documentID);
                                        await fetchAllTransactions();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text(
                                        'Non',
                                        style: textStyle.copyWith(
                                            color: Colors.red),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                );
                              },
                            );
                          }, colors: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
    });
    return (docList.isNotEmpty)? ListView(children: _listChildren):Center(child: Text('Aucunnes données'),);
  }
}
