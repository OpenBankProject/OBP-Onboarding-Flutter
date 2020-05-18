import 'dart:convert';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hello_obp_flutter/model/model.dart';
import 'package:hello_obp_flutter/utils/auth.dart';
import 'package:hello_obp_flutter/utils/constant.dart';
import 'package:hello_obp_flutter/utils/http_utils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:loading_overlay/loading_overlay.dart';

class AuthContextUpdatePage extends StatefulWidget {
  @override
  _AuthContextUpdatePageState createState() => _AuthContextUpdatePageState();
}

class _AuthContextUpdatePageState extends State<AuthContextUpdatePage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormState> _answerKey = GlobalKey<FormState>();

  List<Bank> banks = List();

  // manage state of modal progress HUD widget
  bool _isLoading = false;

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
  }

  void submitAuthContextUpdate() async {
    if (_fbKey.currentState.saveAndValidate()) {
      setState(() {
        this._isLoading = true;
      });

      var formValues = _fbKey.currentState.value;
      try {
        var createAuthContextUpdateUrl = constants.createAuthContextUpdateUrl
            .replaceFirst('BANK_ID', formValues['bank_id'])
            .replaceFirst('SCA_METHOD', formValues['confrim_way']);
        var json =
            '{  "key": "CUSTOMER_NUMBER",  "value": "${formValues['customer_number']}" }';
        ObpResponse response = await httpRequest.post(
            createAuthContextUpdateUrl,
            data: json,
            headers: auth.authHeaders);
        if (response.isSuccess()) {
          var userAuthContextUpdateId =
              response.data['user_auth_context_update_id'] as String;

          setState(() {
            this._isLoading = false;
          });

          _answerKey.currentState?.reset();
          String answer;
          // popup
          Alert(
              context: context,
              title: "Answer Challenge",
              content: Form(
                key: _answerKey,
                child: Column(
                  children: <Widget>[
                    Text(
                      'Please check your ${formValues['confrim_way']},\nand input recieved answer.',
                      style: TextStyle(fontSize: 15, color: Colors.blue),
                    ),
                    TextFormField(
                        decoration: InputDecoration(
                          icon: Icon(
                              CommunityMaterialIcons.comment_question_outline),
                          labelText: 'Answer',
                        ),
                        onChanged: (value) => answer = value,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Answer is required!'
                            : null),
                  ],
                ),
              ),
              buttons: [
                DialogButton(
                  onPressed: () =>
                      answerChallenge(userAuthContextUpdateId, answer),
                  child: Text(
                    "Answer Challenge",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )
              ]).show();
        } else {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Row(
              children: <Widget>[
                Icon(
                  Icons.warning,
                  color: Colors.yellow,
                ),
                Expanded(
                  child: Text(
                      response.message.replaceFirst(RegExp(r'OBP-\d+: '), ""),
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ));
        }
      } catch (e) {
        print('Error: $e');
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Row(
            children: <Widget>[
              Icon(
                Icons.warning,
                color: Colors.yellow,
              ),
              Text('  Server side error, please try again!'),
            ],
          ),
        ));
      } finally {
        setState(() {
          this._isLoading = false;
        });
      }
    }
  }

  void answerChallenge(String userAuthContextUpdateId, String answer) async {
    if (_answerKey.currentState.validate()) {
      _answerKey.currentState.save();
      Navigator.pop(context);

      try {
        setState(() {
          this._isLoading = true;
        });
        Map<String, String> authHeaders = auth.authHeaders;
        var jsonJson = {"answer": answer};
        var json = jsonEncode(jsonJson);
        var answerAuthContextUpdateChallengeUrl = constants
            .answerAuthContextUpdateChallengeUrl
            .replaceFirst('AUTH_CONTEXT_UPDATE_ID', userAuthContextUpdateId);
        ObpResponse response = await httpRequest.post(
            answerAuthContextUpdateChallengeUrl,
            data: json,
            headers: authHeaders);
        if (response.isSuccess()) {
          var challengeStatus = response.data['status'] as String;
          if (challengeStatus == 'ACCEPTED') {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Row(
              children: <Widget>[
                Icon(
                  CommunityMaterialIcons.hand_peace,
                  color: Colors.green,
                ),
                Text('  Success!'),
              ],
            )));
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Row(
              children: <Widget>[
                Icon(
                  Icons.warning,
                  color: Colors.yellow,
                ),
                Text('  Answer is not correct!'),
              ],
            )));
          }
        } else {
          print('Error: ${response.message}');
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Icon(
                      Icons.warning,
                      color: Colors.yellow,
                    ),
                    Expanded(
                        child: Text(
                            '  Server side error: ${response.message.replaceFirst(RegExp(r'OBP-\d+: '), "")}',
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ));
        }
      } catch (e) {
        print('Error: $e');
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Row(
          children: <Widget>[
            Icon(
              Icons.warning,
              color: Colors.yellow,
            ),
            Text('  Server side error, please try again!'),
          ],
        )));
      } finally {
        setState(() {
          this._isLoading = false;
        });
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
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(15.0),
          children: <Widget>[
            FormBuilder(
              key: _fbKey,
              initialValue: {
                'confrim_way': 'SMS',
              },
              autovalidate: false,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                        child: Text(
                      'Request Access to your Accounts',
                      style: TextStyle(fontSize: 20, color: Colors.blue),
                    )),
                  ),
                  FormBuilderDropdown(
                    attribute: "bank_id",
                    decoration: InputDecoration(
                        labelText: "Which Bank do you want to use?"),
                    hint: Text('Select Bank'),
                    validators: [
                      FormBuilderValidators.required(
                          errorText: 'Bank is required')
                    ],
                    items: banks
                        .map((bank) => DropdownMenuItem(
                            value: bank.id, child: Text(bank.full_name)))
                        .toList(),
                  ),
                  FormBuilderTextField(
                    attribute: "customer_number",
                    decoration: InputDecoration(
                        labelText: "Please enter your Customer Number."),
                    maxLines: 1,
                    validators: [
                      FormBuilderValidators.required(
                          errorText: 'Customer Number is required'),
                    ],
                  ),
                  FormBuilderChoiceChip(
                      attribute: "confrim_way",
                      decoration: InputDecoration(
                          labelText: "How should we confirm your Identity?"),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      spacing: 20,
                      options: [
                        FormBuilderFieldOption(
                            child: Text("SMS"), value: "SMS"),
                        FormBuilderFieldOption(
                            child: Text("EMAIL"), value: "EMAIL"),
                      ],
                      validators: [
                        FormBuilderValidators.required(
                            errorText: '"Confirm way" is required')
                      ]),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text(
                      "Request Access",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.green,
                    onPressed: this.submitAuthContextUpdate,
                  ),
                ),
                Container(padding: EdgeInsets.only(left: 10)),
                Expanded(
                  child: RaisedButton(
                    child: Text(
                      "Reset Values",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.green,
                    onPressed: () {
                      _fbKey.currentState.reset();
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
