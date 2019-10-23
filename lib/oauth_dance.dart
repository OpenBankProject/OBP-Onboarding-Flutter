import 'dart:io';
import 'package:oauth1/oauth1.dart' as oauth1;

void main() {
  // define platform (server)
  var platform = new oauth1.Platform(
      'https://apisandbox.openbankproject.com/oauth/initiate', // temporary credentials request
      'https://apisandbox.openbankproject.com/oauth/authorize',     // resource owner authorization
      'https://apisandbox.openbankproject.com/oauth/token',  // token credentials request
      oauth1.SignatureMethods.hmacSha1              // signature method
  );

  // define client credentials (consumer keys)
  const String apiKey = '5wr5ur0k55iri5ots3ouuojvm4oruwrjozfy1jp3';
  const String apiSecret = 'vs5m2zbba25emwo5q0nr2ai4531ivopndc4adysl';
  var clientCredentials = new oauth1.ClientCredentials(apiKey, apiSecret);

  // create Authorization object with client credentials and platform definition
  var auth = new oauth1.Authorization(clientCredentials, platform);

  // request temporary credentials (request tokens)
  auth.requestTemporaryCredentials('oob').then((res) {
    // redirect to authorization page
    print("Open with your browser: ${auth.getResourceOwnerAuthorizationURI(res.credentials.token)}");

    // get verifier (PIN)
    stdout.write("PIN: ");
    String verifier = stdin.readLineSync();

    // request token credentials (access tokens)
    return auth.requestTokenCredentials(res.credentials, verifier);
  }).then((res) {
    // yeah, you got token credentials
    // create Client object
    var client = new oauth1.Client(platform.signatureMethod, clientCredentials, res.credentials);

    // now you can access to protected resources via client
    client.get('https://api.twitter.com/1.1/statuses/home_timeline.json?count=1').then((res) {
      print(res.body);
    });

    // NOTE: you can get optional values from AuthorizationResponse object
    print("Your screen name is " + res.optionalParameters['screen_name']);
  });
}