import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:onexbet/constants/constant.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<SimCard> _simData;
  int selectedIndex;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Sélectionnez une SIM pouvant vous permettre d\'effectuer des paiements: ',
            style: textStyle.copyWith(fontSize: 16.0),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _simData.length,
              itemBuilder: (BuildContext context, int position) {
                return InkWell(
                  onTap: () => setState(() {
                    selectedIndex = position;
                    isSelected = true;
                  }),
                  child: Container(
                    width: size.width / 2,
                    child: Card(
                      shape: (selectedIndex == position)
                          ? RoundedRectangleBorder(
                              side: BorderSide(color: Colors.green, width: 3.0),
                            )
                          : null,
                      elevation: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            'SIM ${_simData[position].slotIndex + 1}',
                            style: textStyle,
                          ),
                          Text(
                            _simData[position].carrierName,
                            style: textStyle,
                          ),
                          Image.asset(
                            (_simData[position].carrierName == 'MTN')
                                ? 'images/mtn.png'
                                : 'images/etisalat.png',
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward_ios),
        onPressed: isSelected
            ? () {
                Navigator.pop(context, _simData[selectedIndex]);
              }
            : null,
        backgroundColor: isSelected ? Colors.blue : Colors.grey,
      ),
    );
  }

  Future<void> initPlatformState() async {
    try {
      _simData = await MobileNumber.getSimCards;
      setState(() {});
    } catch (e) {
      print(e);
    }
  }
}
