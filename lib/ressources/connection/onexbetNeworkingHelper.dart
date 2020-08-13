import 'package:cloud_firestore/cloud_firestore.dart';

class OnexbetNetworkingHelper {
  static Future<dynamic> sendData(
      {String collectionName, Map<String, dynamic> dataToSend}) async {
    DocumentReference documentReference;
    await Firestore.instance
        .collection(collectionName)
        .add(dataToSend)
        .then((value) {
      documentReference = value;
    }).catchError((e) {
      print(e);
    });
    return documentReference;
  }

  static Future<dynamic> getData({String collectionName}) async {
    List<DocumentSnapshot> data;
    await Firestore.instance
        .collection(collectionName)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      data = snapshot.documents;
    }).catchError((e) {
      print(e);
    });
    return data;
  }

  static Future<dynamic> getDocuments(
      {String collectionName, String documentId}) async {
    Map<String, dynamic> data;
    DocumentReference documentReference =
        Firestore.instance.collection(collectionName).document(documentId);
    await documentReference.get().then((dataSnapshot) {
      if (dataSnapshot.exists) {
        data = dataSnapshot.data;
      }
    }).catchError((e) {
      print(e);
    });

    return data;
  }

  static Future<dynamic> updateDocuments(
      {String collection, String documentID, Map<String, dynamic> dataToSend}) {
    Firestore.instance
        .collection(collection)
        .document(documentID)
        .updateData(dataToSend)
        .then((value) {
      print('success');
      return;
    }).catchError((e) {
      print(e);
    });
  }
}
