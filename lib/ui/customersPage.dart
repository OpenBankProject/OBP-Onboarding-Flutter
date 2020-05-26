
import 'package:flutter/material.dart';
import 'package:hello_obp_flutter/model/model.dart';
import 'package:hello_obp_flutter/utils/auth.dart';
import 'package:hello_obp_flutter/utils/constant.dart';
import 'package:hello_obp_flutter/utils/http_utils.dart';
import 'package:loading_overlay/loading_overlay.dart';

class CustomersPage extends StatefulWidget {
  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  // manage state of modal progress HUD widget
  bool _isLoading = true;

  List<Customer> customers = List();
  Map<String, String> bankIdToBankName = {};

  @override
  void initState() {
    super.initState();
    initiateCustomersAndBanks();
  }

  void initiateCustomersAndBanks() async {
    // initiate customers
    {
      ObpResponse response = await httpRequest.get(
          constants.getCurrentUserLinkedCustomerUrl,
          headers: auth.authHeaders);

      if (response.isSuccess()) {
        var customersJson = response.data["customers"] as List<dynamic>;
        setState(() {
          customers = customersJson
              .map<Customer>(
                  (it) => Customer.fromJson(it as Map<String, dynamic>))
              .toList();
        });
      }
    }

    // initiate banks
        {
      if (bankIdToBankName.isEmpty) {
        ObpResponse response = await httpRequest.get(constants.getBanksUrl, headers: auth.authHeaders);
        if (response.isSuccess()) {
          var banksJson = response.data["banks"] as List<dynamic>;
          var bankIds = banksJson.map<String>((bk) => bk['id'] as String);
          var fullNames =
          banksJson.map<String>((bk) => bk['full_name'] as String);

          setState(() {
            bankIdToBankName = Map.fromIterables(bankIds, fullNames);
            this._isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        isLoading: _isLoading,
        // demo of some additional parameters
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: List.generate(3, (int index) {
              if (index == 1) {
                return SizedBox(
                  height: 30,
                );
              }
              if (customers.isEmpty) {
                if (index == 0) {
                  return Text(
                    'Welcome!',
                    style: TextStyle(fontSize: 30),
                  );
                } else {
                  return Text( this._isLoading ? 'Loading...': 'No Bank can be connected,\nplease "Request Access" first!');
                }
              } else {
                var firstCustomer = customers.first;
                if (index == 0) {
                  return Text(
                    'Welcome ${firstCustomer.title ?? ""} ${firstCustomer.legal_name}',
                    style: TextStyle(fontSize: 18),
                  );
                } else {
                  return Text( this._isLoading ? 'Loading...':
                  'You are now connected to\nThe Bank of ${bankIdToBankName[firstCustomer.bank_id]}',
                      style: TextStyle(fontSize: 18));
                }
              }
            }),
          ),
        ),
      ),
    );
  }
}