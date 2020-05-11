import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_obp_flutter/model/model.dart';
import 'package:hello_obp_flutter/utils/auth.dart';
import 'package:hello_obp_flutter/utils/constant.dart';
import 'package:hello_obp_flutter/utils/http_utils.dart';

class AuthContextUpdatePage extends StatefulWidget {
  @override
  _AuthContextUpdatePageState createState() => _AuthContextUpdatePageState();
}

class _AuthContextUpdatePageState extends State<AuthContextUpdatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _bankId = '';

  List<Bank> banks = List();
  List<Bank> roleReaderBanks = [Bank(id: '', full_name: 'select one bank')];

  String userAuthContextUpdateId = null;
  String answer = null;
  String operationResult = null;

  bool isRolesReady(List<Entitlement> entitlements, String bankId) {
    bool hasCanCreateCustomer = false;
    bool hasCanCreateUserCustomerLink = false;
    bool hasCanCreateUserAuthContextUpdate = false;
    bool hasCanGetUserAuthContext = false;
    entitlements.forEach((Entitlement entitlement) {
      if (entitlement.role_name == 'CanCreateCustomer' &&
          entitlement.bank_id == bankId) {
        hasCanCreateCustomer = true;
      } else if (entitlement.role_name == 'CanCreateUserCustomerLink' &&
          entitlement.bank_id == bankId) {
        hasCanCreateUserCustomerLink = true;
      } else if (entitlement.role_name == 'CanCreateUserAuthContextUpdate') {
        hasCanCreateUserAuthContextUpdate = true;
      } else if (entitlement.role_name == 'CanGetUserAuthContext') {
        hasCanGetUserAuthContext = true;
      }
    });
    return hasCanCreateCustomer &&
        hasCanCreateUserCustomerLink &&
        hasCanCreateUserAuthContextUpdate &&
        hasCanGetUserAuthContext;
  }
  @override
  void initState() {
    super.initState();
    if (banks.isEmpty) {
      httpRequest.get(constants.getBanksUrl).then((response) {
        if (response.isSuccess()) {
          var banksJson = response.data["banks"] as List<dynamic>;
          setState(() {
            banks = banksJson.map<Bank>((it) => Bank.fromJson(it)).toList();
          });
        }
      });
    }

    googleAuth.getEntitlements().then((roles) {
      var filteredBanks = banks.where((bank){
            return this.isRolesReady(roles, bank.id);
          }).toList();

      if(filteredBanks.isNotEmpty) {
        filteredBanks.insert(0, this.roleReaderBanks[0]);
        setState(() {
          this.roleReaderBanks = filteredBanks;
        });
      }

    });
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        Map<String, String> authHeaders = googleAuth.authHeaders;
//        Customer customer = Customer(bank_id: this._color);
//        var customerJson = jsonEncode(customer.toJson());
        var j = {
          "legal_name": "Eveline Tripman",
          "mobile_phone_number": "+44 07972 444 876",
          "email": "eveline@example.com",
          "face_image": {
            "url": "www.openbankproject",
            "date": "2017-09-19T00:00:00Z"
          },
          "date_of_birth": "2017-09-19T00:00:00Z",
          "relationship_status": "single",
          "dependants": 1,
          "dob_of_dependants": ["2017-09-19T00:00:00Z"],
          "credit_rating": { "rating": "OBP", "source": "OBP"},
          "credit_limit": { "currency": "EUR", "amount": "0"},
          "highest_education_attained": "Master",
          "employment_status": "worker",
          "kyc_status": true,
          "last_ok_date": "2017-09-19T00:00:00Z",
          "title": "Dr.",
          "branch_id": "DERBY6",
          "name_suffix": "Sr"
        };
        var customerJson = jsonEncode(j);
        var createCustomerUrl = constants.createCustomerUrl.replaceFirst('BANK_ID', this._bankId);
        ObpResponse response = await httpRequest.post(createCustomerUrl, data: customerJson, headers: authHeaders);
        if(response.isSuccess()) {
          Customer newCustomer = Customer.fromJson(response.data);

          var createUserCustomerLinkUrl = constants.createUserCustomerLinkUrl.replaceFirst('BANK_ID', this._bankId);
          var json = '{  "user_id":"${googleAuth.user.user_id}",  "customer_id":"${newCustomer.customer_id}"}';
          response = await httpRequest.post(createUserCustomerLinkUrl, headers: authHeaders, data: json);
          if(response.isSuccess()) {
            var createAuthContextUpdateUrl = constants.createAuthContextUpdateUrl.replaceFirst('BANK_ID', this._bankId).replaceFirst('SCA_METHOD', 'EMAIL'); // TODO add SMS way.
            var json = '{  "key":"CUSTOMER_NUMBER",  "value":"${newCustomer.customer_number}"}';
            response = await httpRequest.post(createAuthContextUpdateUrl, data: json, headers: authHeaders);
            if(response.isSuccess()) {
              var userAuthContextUpdateId = response.data['user_auth_context_update_id'] as String;
              setState(() {
                this.userAuthContextUpdateId = userAuthContextUpdateId;
              });
              print('---------------------:$userAuthContextUpdateId');
            }
          }
        } else {
          print(response.message);
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void answerAuthContextUpdateChallenge()  async {
    if (validateAndSave()) {
      try {
        Map<String, String> authHeaders = googleAuth.authHeaders;
        var jsonJson = {  "answer": this.answer};
        var json = jsonEncode(jsonJson);
        var answerAuthContextUpdateChallengeUrl = constants.answerAuthContextUpdateChallengeUrl.replaceFirst('AUTH_CONTEXT_UPDATE_ID', this.userAuthContextUpdateId);
        ObpResponse response = await httpRequest.post(answerAuthContextUpdateChallengeUrl, data: json, headers: authHeaders);
        if(response.isSuccess()) {
          setState(() {
            this.operationResult = 'answer is correct';
            this.userAuthContextUpdateId = null;
          });
        } else {
          setState(() {
            this.operationResult = response.message;
          });
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new SafeArea(
          top: false,
          bottom: false,
          child: new Form(
              key: _formKey,
              autovalidate: true,
              child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.person),
                      hintText: 'Enter your first and last name',
                      labelText: 'Name',
                    ),
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.calendar_today),
                      hintText: 'Enter your date of birth',
                      labelText: 'Dob',
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.phone),
                      hintText: 'Enter a phone number',
                      labelText: 'Phone',
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.email),
                      hintText: 'Enter a email address',
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.view_module),
                      hintText: 'Select a bank',
                      labelText: 'Bank',
                    ),
                    value: _bankId == '' ? null : _bankId,
                    onChanged: (value){
                      setState(() {
                        _bankId = value;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty ? 'bank is required' : null,
                    items:
                    roleReaderBanks.map<DropdownMenuItem<String>>((Bank bank) {
                      return DropdownMenuItem<String>(
                        value: bank.id,
                        child: Text(bank.full_name),
                      );
                    }).toList(),
                  ),
                  Container(
                       child: userAuthContextUpdateId != null ? TextFormField(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.question_answer),
                          hintText: 'Enter ansewer by check your email.',
                          labelText: 'Answer',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value == null || value.isEmpty ? 'answer is required' : null,
                         onChanged: (value){
                          setState(() {
                           answer = value;
                         });},
                      ): Divider(),
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
                      child: RaisedButton(
                        child: userAuthContextUpdateId == null ? Text('Create User Auth Context Update') : Text('Answer Auth Context Update Challenge.'),
                        onPressed: userAuthContextUpdateId == null ? this.validateAndSubmit : this.answerAuthContextUpdateChallenge,
                      )),
                  operationResult == null ? Divider(): Text(this.operationResult, style: TextStyle(color: Colors.blue, fontSize: 20),),
                ],
              ))),
    );
  }
}