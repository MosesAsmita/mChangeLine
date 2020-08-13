import 'package:flutter/material.dart';
import 'package:onexbet/constants/constant.dart';

textField(
    {String fieldName,
    String helperText,
    Function validator,
    Function onSaved,
    textInputType = TextInputType.text,
    bool obscureText = false,
    bool autoValidate = false,
    String prefixText = '',
    Function onChanged,
    Widget prefixIcon,
    Widget suffixIcon,
    String value = ''}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          fieldName,
          style: textStyle.copyWith(fontSize: 16.0),
        ),
        SizedBox(
          height: 5.0,
        ),
        TextFormField(
          obscureText: obscureText,
          autovalidate: autoValidate,
          initialValue: value,
          style: textStyle.copyWith(fontWeight: FontWeight.w600),
          onChanged: onChanged,
          decoration: InputDecoration(
              helperText: helperText,
              helperStyle: textStyle.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  fontSize: 13),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              prefix: (prefixText == '') ? null : Text(prefixText),
              prefixStyle: textStyle.copyWith(fontWeight: FontWeight.w600),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
              enabledBorder: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)),
              errorBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green))),
          validator: validator,
          onSaved: onSaved,
          keyboardType: textInputType,
        ),
      ],
    ),
  );
}

raisedButton(context,
    {@required String label, @required Function onPressed, Color colors}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 60.0),
    child: RaisedButton(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      onPressed: onPressed,
      color: colors,
    ),
  );
}

dialog(
    {BuildContext context,
    Widget content,
    String fstBtnTxt,
    Function fstBtnOnPressed,
    String sndBtnTxt,
    Function sndBtnOnPressed,
    TextStyle sndTextStyle}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: true,
        title: Text('M-Change Line'),
        content: content,
        actions: <Widget>[
          FlatButton(
            child: Text(
              fstBtnTxt,
              style: textStyle,
            ),
            onPressed: fstBtnOnPressed,
          ),
          SizedBox(
            width: 40.0,
          ),
          FlatButton(
            child: Text(
              sndBtnTxt,
              style: textStyle.copyWith(color: Colors.red),
            ),
            onPressed: sndBtnOnPressed,
          )
        ],
      );
    },
  );
}

alert({BuildContext context}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('M-Change Line'),
        content: Text(
          'Nous rencontrons des problèmes dans l\'exécution de  votre demande. Vérifiez votre solde puis reéssayer.',
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Compris',
              style: textStyle.copyWith(color: Colors.blue),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      );
    },
  );
}

waitMsg() {
  return AlertDialog(
    title: Text('M-Change Line'),
    content: Row(
      children: <Widget>[
        CircularProgressIndicator(
          strokeWidth: 2.0,
        ),
        SizedBox(
          width: 20.0,
        ),
        Text('Veuillez patienter...')
      ],
    ),
  );
}

contentRecharge(rechargeInfos, textField) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Text(
        'Confirmation',
        style: textStyle.copyWith(fontSize: 20.0),
      ),
      RichText(
        text: TextSpan(
            text: 'Vous êtes sur le point de recharger  depuis le ',
            style: textStyle.copyWith(
                color: Colors.black, fontWeight: FontWeight.normal),
            children: <TextSpan>[
              TextSpan(
                text: ' ${rechargeInfos['num']},',
                style: textStyle.copyWith(color: Colors.black),
              ),
              TextSpan(
                text: ' ${rechargeInfos['montant']} FCFA',
                style: textStyle.copyWith(color: Colors.black),
              ),
              TextSpan(
                text: ' sur votre compte 1XBET ',
                style: textStyle.copyWith(
                    color: Colors.black, fontWeight: FontWeight.normal),
              ),
              TextSpan(
                text: ' ID: ${rechargeInfos['id1xBet']}.',
                style: textStyle.copyWith(color: Colors.black),
              ),
              TextSpan(
                text: ' Il vous sera deduit ',
                style: textStyle.copyWith(
                    color: Colors.black, fontWeight: FontWeight.normal),
              ),
              TextSpan(
                text: '${rechargeInfos['montant_tarif']} FCFA',
                style: textStyle.copyWith(color: Colors.black),
              ),
              TextSpan(
                text: ' conformément à la grille tarifaire.',
                style: textStyle.copyWith(
                    color: Colors.black, fontWeight: FontWeight.normal),
              ),
              TextSpan(
                text: ' Entrer votre code PIN pour confirmer la transaction.',
                style: textStyle.copyWith(
                    color: Colors.black, fontWeight: FontWeight.normal),
              )
            ]),
      ),
      Flexible(child: textField),
      SizedBox(
        height: 20.0,
      )
    ],
  );
}

contentRetrait(retraitInfos) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Text(
        'Confirmation',
        style: textStyle.copyWith(fontSize: 20.0),
      ),
      RichText(
        text: TextSpan(
            text: 'Vous êtes sur le point de retirer ',
            style: textStyle.copyWith(
                color: Colors.black, fontWeight: FontWeight.normal),
            children: <TextSpan>[
              TextSpan(
                text: ' ${retraitInfos['montant']} FCFA',
                style: textStyle.copyWith(color: Colors.black),
              ),
              TextSpan(
                text: ' de votre compte 1XBET ',
                style: textStyle.copyWith(
                    color: Colors.black, fontWeight: FontWeight.normal),
              ),
              TextSpan(
                text: ' ID: ${retraitInfos['id1xBet']}.',
                style: textStyle.copyWith(color: Colors.black),
              ),
              TextSpan(
                text: ' Il vous sera envoyé sur le ',
                style: textStyle.copyWith(
                    color: Colors.black, fontWeight: FontWeight.normal),
              ),
              TextSpan(
                text: ' ${retraitInfos['num']},',
                style: textStyle.copyWith(color: Colors.black),
              ),
              TextSpan(
                text: ' appartenant à ',
                style: textStyle.copyWith(
                    color: Colors.black, fontWeight: FontWeight.normal),
              ),
              TextSpan(
                text: ' ${retraitInfos['nom']},',
                style: textStyle.copyWith(color: Colors.black),
              ),
              TextSpan(
                text: ' ${retraitInfos['montant_tarif']} FCFA',
                style: textStyle.copyWith(color: Colors.black),
              ),
              TextSpan(
                text: ' conformément à la grille tarifaire.',
                style: textStyle.copyWith(
                    color: Colors.black, fontWeight: FontWeight.normal),
              ),
            ]),
      ),
      SizedBox(
        height: 20.0,
      )
    ],
  );
}

customCard(Map<String, dynamic> data) {
  return GestureDetector(
    child: Card(
      margin: EdgeInsets.symmetric(horizontal: 80.0, vertical: 20.0),
      elevation: 5.0,
      child: Image.asset(
        data['icon'],
        cacheHeight: 200,
        cacheWidth: 321,
      ),
    ),
    onTap: data['function'],
  );
}
