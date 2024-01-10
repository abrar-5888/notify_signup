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
  var remaining = 0;
  final passContoller = TextEditingController();

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(p);

    return regExp.hasMatch(em);
  }

  // bool _isloading = true;
  // void remain() async {
  //   _isloading = true;

  //   String documentId = "";

  //   var userrecord = FirebaseFirestore.instance
  //       .collection("UserRequest")
  //       .where('email', isEqualTo: widget.ownerEmail);
  //   QuerySnapshot userQuerySnapshot = await userrecord.get();
  //   // print(userQuerySnapshot.toString());

  //   if (userQuerySnapshot.docs.isNotEmpty) {
  //     for (QueryDocumentSnapshot documentSnapshot in userQuerySnapshot.docs) {
  //       print("Document ID: ${documentSnapshot.id}");
  //       setState(() {
  //         documentId = documentSnapshot.id;
  //       });
  //       // You can also access the document data if needed:
  //       // var data = documentSnapshot.data();
  //       // print("Document Data: $data");
  //     }
  //     DocumentReference userDocumentRef =
  //         userQuerySnapshot.docs.first.reference;
  //     print(documentId);

  //     // Reference to the "FmData" subcollection
  //     CollectionReference fmDataCollection =
  //         userDocumentRef.collection("FMData");
  //     QuerySnapshot fmDataSnapshot = await fmDataCollection.get();
  //     var length = fmDataSnapshot.docs.length;
  //     setState(() {
  //       _isloading = false;
  //     });

  //     if (length.toString() == null) {
  //       setState(() {
  //         _isloading = false;
  //         remaining = 8;
  //       });
  //     } else {
  //       setState(() {
  //         _isloading = false;
  //         remaining = 8 - length;
  //       });
  //       // print("Remaining = $remaining");
  //     }
  //     _isloading = false;
  //   }
  // }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   remain();
  // }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool isPhone(String em) {
    String p =
        r'^((\+92)|(0092))-{0,1}\d{3}-{0,1}\d{7}$|^\d{11}$|^\d{4}-\d{7}$';

    RegExp regExp = RegExp(p);

    return regExp.hasMatch(em);
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

  void generatePassword() {
    passContoller.text = addFMmodel.password;
    final random = Random();
    const upperCaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numericChars = '0123456789';

    String password = '';

    for (int i = 0; i < 4; i++) {
      password += upperCaseChars[random.nextInt(upperCaseChars.length)];
      // passContoller.text = password;
    }

    for (int i = 0; i < 4; i++) {
      password += numericChars[random.nextInt(numericChars.length)];
      // passContoller.text = password;
    }
    setState(() {
      passContoller.text = password;
    });
  }

  int fmNum = 1;
  void saveform() async {
    print(widget.parentID);
    String fourDigitCode = generateRandomFourDigitCode();

    print("digit code = $fourDigitCode");
    String email = "";
    String pass;
    if (_FMformKey.currentState!.validate()) {
      _FMformKey.currentState!.save();
      try {
        EasyLoading.show();
        if (addFMmodel.email.isEmpty) {
          setState(() {
            email = "${addFMmodel.phoneNo}@gmail.com";
          });
        } else {
          setState(() {
            email = addFMmodel.email;
          });
        }
        pass = addFMmodel.password;
        print("Email = $email,password = $pass");

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: pass);
        User? user = userCredential.user;
        // await getMobileToken();

        var userrecord = FirebaseFirestore.instance
            .collection("UserRequest")
            .where('email', isEqualTo: widget.ownerEmail);
        QuerySnapshot userQuerySnapshot = await userrecord.get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentReference userDocumentRef =
              userQuerySnapshot.docs.first.reference;

          // Reference to the "FmData" subcollection
          CollectionReference fmDataCollection =
              userDocumentRef.collection("FMData");
          QuerySnapshot fmDataSnapshot = await fmDataCollection.get();
          var length = fmDataSnapshot.docs.length;

          if (fmDataSnapshot.docs.length >= 8) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyPage(),
                ));
            showDialog2(context);
            // If the subcollection has 8 documents
            EasyLoading.showError("Maximum Logins Exceeded!");
          } else {
            setState(() {
              remaining = 7 - length;
            });
            // print("Remaining = $remaining");

            Map<String, dynamic> fmData = {
              "remaining": remaining,
              "Name": addFMmodel.name,
              "phonenumber": addFMmodel.phoneNo,
              "status": "Approve",
              "email": email,
              "uid": user?.uid,
              "password": addFMmodel.password,
              "residentID": "INVOSEG$fourDigitCode",
              // "CM_Token": FCMtoken,
              "address": widget.address,
              "owner": widget.owner,
              'parentID': widget.parentID,
              'ownermail': widget.ownerEmail,
            };

            DocumentReference parentDocumentReference = FirebaseFirestore
                .instance
                .collection('UserRequest')
                .doc(widget.docid);
            DocumentSnapshot parentDocumentSnapshot =
                await parentDocumentReference.get();
            int currentTFM = parentDocumentSnapshot.get('TFM');
            CollectionReference subcollectionReference =
                parentDocumentReference.collection('FMData');
            DocumentReference fmDocumentReference =
                subcollectionReference.doc('FM$fmNum');
            await fmDocumentReference.set(fmData).then((value) => {
                  setState(() {
                    addFMmodel.password = "";
                    fmNum = fmNum + 1;
                  })
                });

            print("fmNum   $fmNum");
            await parentDocumentReference
                .update({'TFM': FieldValue.increment(1)});

            _FMformKey.currentState!.reset();
            FocusScope.of(context).unfocus();
            print("length==========${fmDataSnapshot.docs.length}");

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Details Sent!',
                  style: TextStyle(color: Colors.black),
                ),
                action: SnackBarAction(
                    label: 'OK', textColor: Colors.black, onPressed: () {}),
                backgroundColor: Colors.grey[400],
              ),
            );

            // if (fmNum >= 8) {
            //   print("Not oka");
            //   return showDialog2(context);
            // } else {
            //   return showDialog1(context);
            // }
          }
        }
      } catch (e) {
        print(e);
        // showDialog2(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Sorry ! Account already occured"),
          action: SnackBarAction(label: 'ok', onPressed: () {}),
        ));
      }
    }
  }

  void showDialog1(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add another Family Member'),
            content: const Text('You want to add another family member?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Handle "No" button press
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const MyPage())); // Close the dialog

                  // Close the dialog
                  // You can navigate back to the previous page here
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _FMformKey.currentState!.reset();
                  FocusScope.of(context).unfocus();
                  // Handle "Yes" button press
                  // You can navigate to the page where you want to add a family member
                  // using Navigator or any other navigation method
                },
                child: const Text('Yes'),
              ),
            ],
          );
        });
  }

  void showDialog2(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Family Member'),
            content: const Text(
                'Sorry You cannot add another family member.Thank You for your cordinations !'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Handle "No" button press
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const MyPage())); // Close the dialog

                  // Close the dialog
                  // You can navigate back to the previous page here
                },
                child: const Text('Ok'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // if (_isloading == false) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
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
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyPage(),
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
                          SizedBox(
                              width: double.infinity,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "You can add ",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            Text(
                                              "${remaining > 0 ? remaining : 8}",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Text(
                                              " Family Members",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
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
                                          const Padding(
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
                                              decoration: const InputDecoration(
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
                                                return null;
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
                                          const Padding(
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
                                          Expanded(
                                            child: TextFormField(
                                              initialValue:
                                                  FMinitials['email'] as String,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              decoration: const InputDecoration(
                                                labelText: 'Enter Your Email',
                                                border: InputBorder.none,
                                                hintText: 'john@email.com',
                                                hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10),
                                              ),
                                              validator: (value) {
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
                                          const Padding(
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
                                              decoration: const InputDecoration(
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
                                          const Padding(
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
                                              // obscureText: true,
                                              controller: passContoller,
                                              keyboardType:
                                                  TextInputType.visiblePassword,
                                              decoration: InputDecoration(
                                                suffixIcon: Container(
                                                  margin:
                                                      const EdgeInsets.all(8),
                                                  child: TextButton(
                                                    style: TextButton.styleFrom(
                                                      minimumSize:
                                                          const Size(100, 50),
                                                    ),
                                                    child: const Text(
                                                      "generate pass",
                                                      style: TextStyle(
                                                          fontSize: 10),
                                                    ),
                                                    onPressed: () {
                                                      generatePassword();
                                                    },
                                                  ),
                                                ),
                                                labelText:
                                                    'Enter Your Password',
                                                border: InputBorder.none,
                                                hintText: '********',
                                                hintStyle: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10,
                                                ),
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
                                                        const Color.fromRGBO(
                                                            15,
                                                            39,
                                                            127,
                                                            1)), // <-- Button color
                                                overlayColor:
                                                    MaterialStateProperty
                                                        .resolveWith<Color?>(
                                                            (states) {
                                                  if (states.contains(
                                                      MaterialState.pressed)) {
                                                    return const Color.fromRGBO(
                                                        15, 39, 127, 0.548);
                                                    return null; // <-- Splash color
                                                  }
                                                  return null;
                                                }),
                                              ),
                                              child: const Text(
                                                "Add Family Member",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              onPressed: () {
                                                saveform();
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ]))
                        ]))))));
    // } else {
    //   return const Scaffold(
    //       body: Center(
    //     child: CircularProgressIndicator(),
    //   ));
    // }
  }
}
