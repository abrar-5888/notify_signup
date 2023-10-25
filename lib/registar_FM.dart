import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:notify_signup/Model/addFM.dart';
import 'package:notify_signup/main.dart';

class Register_FM extends StatefulWidget {
  const Register_FM(
      {super.key,
      required this.docid,
      required this.owner,
      required this.address,
      required this.parentID,
      required this.ownerEmail});
  final String owner;
  final String docid;
  final String address;
  final String parentID;
  final String ownerEmail;

  @override
  State<Register_FM> createState() => _Register_FMState();
}

class _Register_FMState extends State<Register_FM> {
  final GlobalKey<FormState> _FMformKey = GlobalKey();

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool isPhone(String em) {
    String p =
        r'^((\+92)|(0092))-{0,1}\d{3}-{0,1}\d{7}$|^\d{11}$|^\d{4}-\d{7}$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  String FCMtoken = "";
  getMobileToken() {
    _firebaseMessaging.getToken().then((String? token) {
      if (token != null) {
        setState(() {
          FCMtoken = token;
        });

        print("FCM Token: $FCMtoken");
      } else {
        print("Unable to get FCM token");
      }
    });
  }

  var addFMmodel = addFM(
      name: '',
      email: '',
      password: '',
      phoneNo: '',
      uid: '',
      address: '',
      owner: '',
      parentID: '',
      ownerEmail: '');
  var FMinitials = {
    'name': '',
    'email': '',
    'password': '',
    'phoneNo': '',
    'uid': '',
    'address': '',
    'owner': '',
    'parentID': '',
    'ownerEmail': ''
  };
  String generateRandomFourDigitCode() {
    Random random = Random();
    int code = random.nextInt(10000);

    // Ensure the code is four digits long (pad with leading zeros if necessary)
    return code.toString().padLeft(4, '0');
  }

  int fmNum = 0;
  void saveform() async {
    String fourDigitCode = generateRandomFourDigitCode();

    print("digit code = ${fourDigitCode}");
    String email;
    String pass;
    if (_FMformKey.currentState!.validate()) {
      _FMformKey.currentState!.save();
      try {
        email = addFMmodel.email;
        pass = addFMmodel.password;
        print("Email = ${email},password = ${pass}");

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: pass);

        User? user = userCredential.user;
        await getMobileToken();

        var userrecord = FirebaseFirestore.instance
            .collection("UserRequest")
            .where('ownermail', isEqualTo: widget.ownerEmail)
            .get()
            .then((value) async {
          if (value.docs.length >= 1) {
            EasyLoading.showError("Maximum Logins Exceeded!");
          } else {
            Map<String, dynamic> fmData = {
              "Name": addFMmodel.name,
              "Phoneno": addFMmodel.phoneNo,
              "status": "Approve",
              "email": addFMmodel.email,
              "uid": user?.uid,
              "residentID": "INVOSEG${fourDigitCode}",
              "FCM_Token": FCMtoken,
              "address": widget.address,
              "owner": widget.owner,
              'parentID': widget.parentID,
              'ownermail': widget.ownerEmail,
            };
            await FirebaseFirestore.instance
                .collection('UserRequest')
                .doc(widget.docid)
                .set({'FM${fmNum}': fmData, 'TFM': fmNum},
                    SetOptions(merge: true));

            _FMformKey.currentState!.reset();
            FocusScope.of(context).unfocus();
          }
        });
      } catch (e) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Details Sent!',
            style: TextStyle(color: Colors.black),
          ),
          action: SnackBarAction(
              label: 'OK', textColor: Colors.black, onPressed: () {}),
          backgroundColor: Colors.grey[400],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Sign Up a Family Member",
            style: TextStyle(
                color: Color(0xff212121),
                fontWeight: FontWeight.w700,
                fontSize: 20),
          ),
          centerTitle: true,
          leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyPage(),
                      ));
                },
              )),
          backgroundColor: Colors.white38,
          elevation: 0,
        ),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: Center(
                child: Form(
                    key: _FMformKey,
                    child: SingleChildScrollView(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Container(
                              width: double.infinity,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.5),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                      child: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 15.0),
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Container(
                                            height: 30.0,
                                            width: 1.0,
                                            color: Colors.grey.withOpacity(0.5),
                                            margin: const EdgeInsets.only(
                                                left: 00.0, right: 10.0),
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                              initialValue:
                                                  FMinitials['name'] as String,
                                              decoration: InputDecoration(
                                                labelText:
                                                    'Enter Your Full Name',
                                                border: InputBorder.none,
                                                hintText: 'Adam Hunt',
                                                hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10),
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'This field is required and cannot be left empty!';
                                                }
                                              },
                                              onSaved: (value) {
                                                addFMmodel.name = value!;
                                              },
                                              keyboardType: TextInputType.text,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.5),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                      child: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 15.0),
                                            child: Icon(
                                              Icons.email,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Container(
                                            height: 30.0,
                                            width: 1.0,
                                            color: Colors.grey.withOpacity(0.5),
                                            margin: const EdgeInsets.only(
                                                left: 00.0, right: 10.0),
                                          ),
                                          new Expanded(
                                            child: TextFormField(
                                              initialValue:
                                                  FMinitials['email'] as String,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              decoration: InputDecoration(
                                                labelText: 'Enter Your Email',
                                                border: InputBorder.none,
                                                hintText: 'john@email.com',
                                                hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10),
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Invalid email!';
                                                } else if (!isEmail(value)) {
                                                  return 'Please enter valid Email.';
                                                }
                                                return null;
                                              },
                                              onSaved: (value) {
                                                addFMmodel.email = value!;
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.5),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                      child: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 15.0),
                                            child: Icon(
                                              Icons.phone,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Container(
                                            height: 30.0,
                                            width: 1.0,
                                            color: Colors.grey.withOpacity(0.5),
                                            margin: const EdgeInsets.only(
                                                left: 00.0, right: 10.0),
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                              initialValue:
                                                  FMinitials['phoneNo']
                                                      as String,
                                              keyboardType: TextInputType.phone,
                                              decoration: InputDecoration(
                                                labelText:
                                                    'Enter Your Phone Number',
                                                border: InputBorder.none,
                                                hintText: '030xxxxxxxx',
                                                hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10),
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Phone Number is not valid!';
                                                } else if (!isPhone(value)) {
                                                  return 'Please enter valid Phone.';
                                                }
                                                return null;
                                              },
                                              onSaved: (value) {
                                                addFMmodel.phoneNo = value!;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.5),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                      child: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 15.0),
                                            child: Icon(
                                              Icons.lock,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Container(
                                            height: 30.0,
                                            width: 1.0,
                                            color: Colors.grey.withOpacity(0.5),
                                            margin: const EdgeInsets.only(
                                                left: 00.0, right: 10.0),
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                              obscureText: true,
                                              initialValue:
                                                  FMinitials['password'],
                                              keyboardType:
                                                  TextInputType.visiblePassword,
                                              decoration: InputDecoration(
                                                labelText:
                                                    'Enter Your Password',
                                                border: InputBorder.none,
                                                hintText: '********',
                                                hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10),
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Password is not valid!';
                                                }
                                                return null;
                                              },
                                              onSaved: (value) {
                                                addFMmodel.password = value!;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(top: 20.0),
                                      padding: const EdgeInsets.only(
                                          left: 20.0, right: 20.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                shape: MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                )),
                                                padding: MaterialStateProperty
                                                    .all(EdgeInsets.symmetric(
                                                            vertical: 25,
                                                            horizontal: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                MediaQuery.of(
                                                                        context)
                                                                    .padding
                                                                    .top) *
                                                        0.25),
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Color.fromRGBO(
                                                            15,
                                                            39,
                                                            127,
                                                            1)), // <-- Button color
                                                overlayColor:
                                                    MaterialStateProperty
                                                        .resolveWith<Color?>(
                                                            (states) {
                                                  if (states.contains(
                                                      MaterialState.pressed))
                                                    return Color.fromRGBO(
                                                        15,
                                                        39,
                                                        127,
                                                        0.548); // <-- Splash color
                                                }),
                                              ),
                                              child: Text(
                                                "Request Credentials",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              onPressed: () {
                                                saveform();
                                                setState(() {
                                                  fmNum = fmNum + 1;
                                                });
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ]))
                        ]))))));
  }
}
