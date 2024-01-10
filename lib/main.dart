import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notify_signup/firebase_options.dart';
import 'package:notify_signup/registar_FM.dart';
import 'package:notify_signup/splashScreen.dart';

import 'Model/NewUsers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //final FirebaseMessaging _fc = FirebaseMessaging.instance;
  bool _initialized = false;
  bool _error = false;

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();

    super.initState();
    //_fc.subscribeToTopic("Events");
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const MaterialApp(
        home: Scaffold(
          body: AlertDialog(
            content: Text('Something went wrong. Please restart the app.'),
          ),
        ),
      );
    }
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      title: 'Notify-App',
      theme: ThemeData(
        fontFamily: 'Urbanist',
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final passContoller = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(p);

    return regExp.hasMatch(em);
  }

  String documentId = "";

  bool isPhone(String em) {
    String p =
        r'^((\+92)|(0092))-{0,1}\d{3}-{0,1}\d{7}$|^\d{11}$|^\d{4}-\d{7}$';

    RegExp regExp = RegExp(p);

    return regExp.hasMatch(em);
  }

  var RegisterationModel = RequestUsers(
      name: '',
      email: '',
      password: '',
      phoneNo: '',
      designation: '',
      age: '',
      owner: '',
      address: '',
      fname: '',
      fphoneNo: '',
      uid: '');
  var initials = {
    'name': '',
    'email': '',
    'password': '',
    'phoneNo': '',
    'designation': '',
    'age': '',
    'owner': '',
    'address': '',
    'fname': '',
    'fphoneNo': '',
    'uid': ''
  };
  bool status = false;
  String email = "";
  String generateRandomFourDigitCode() {
    Random random = Random();
    int code = random.nextInt(10000);

    // Ensure the code is four digits long (pad with leading zeros if necessary)
    return code.toString().padLeft(4, '0');
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void generatePassword() {
    passContoller.text = RegisterationModel.name;
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
//   }

// // Add this function to set the generated password
    // void setGeneratedPassword(String password) {
    //   // Set the generated password in the TextFormField
    //   // Replace 'yourPasswordFieldController' with your actual TextEditingController
    //   passContoller.text = password;
    // }
  }

  Future<bool> isEmailRegistered(String email) async {
    try {
      List<String> signInMethods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(RegisterationModel.email);
      return signInMethods.isNotEmpty;
    } catch (e) {
      print("Error checking email registration: $e");
      return false; // Handle the error as needed
    }
  }

  saveform() async {
    String fourDigitCode = generateRandomFourDigitCode();

    print("digit code = $fourDigitCode");

    String pass;
    String fcmToken;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // FCM_Token = FCMtoken;
        if (RegisterationModel.email.isEmpty) {
          setState(() {
            email = "${RegisterationModel.phoneNo}@gmail.com";
          });
        } else {
          setState(() {
            email = RegisterationModel.email;
          });
        }
        pass = RegisterationModel.password;
        print("Email = $email,password = $pass");
        // var userCredential;
        // try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: pass);

        // } catch (e) {
        //   print("Error==${e}");
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(
        //         'Email is Already used!',
        //         style: TextStyle(color: Colors.black),
        //       ),
        //       action: SnackBarAction(
        //           label: 'OK', textColor: Colors.black, onPressed: () {}),
        //       backgroundColor: Colors.grey[400],
        //     ),
        //   );
        // }

        User? user = userCredential.user;
        // await getMobileToken();
        await FirebaseFirestore.instance.collection('UserRequest').add({
          "Name": RegisterationModel.name,
          "phonenumber": RegisterationModel.phoneNo,
          "address": RegisterationModel.address,
          "fPhonenumber": RegisterationModel.fphoneNo,
          "fName": RegisterationModel.fname,
          "designation": RegisterationModel.designation,
          "age": RegisterationModel.age,
          "owner": RegisterationModel.owner,
          "status": "Approve",
          "password": RegisterationModel.password,
          "email": email, "TFM": 0,
          "uid": user?.uid,
          "residentID": "INVOSEG$fourDigitCode",
          // "FCM_Token": FCM_Token,
        }).then((DocumentReference document) async {
          print("Dcoument id = ${document.id}");
          setState(() {
            documentId = document.id;
            status = true;
          });
          await FirebaseFirestore.instance
              .collection('UserRequest')
              .doc(documentId)
              .update({'parentID': documentId});
        });

        _formKey.currentState!.reset();
        FocusScope.of(context).unfocus();

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

        print("Status == $status");
        if (status == true) {
          showDialog1(context);
        }
      } catch (e) {
        print("Catch working");
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Error! Account already Occured ! "),
            action: SnackBarAction(
              label: 'Ok',
              onPressed: () {
                // Action button callback goes here
                print('Action button pressed');
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign Up",
          style: TextStyle(
              color: Color(0xff212121),
              fontWeight: FontWeight.w700,
              fontSize: 24),
        ),
        centerTitle: true,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Image(
            image: AssetImage('assets/Images/izmir.jpg'),
            height: 60,
            width: 60,
          ),
        ),
        backgroundColor: Colors.white38,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
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
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 15.0),
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
                                  initialValue: initials['name'] as String,
                                  decoration: const InputDecoration(
                                    labelText: 'Enter Your Full Name',
                                    border: InputBorder.none,
                                    hintText: 'Adam Hunt',
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This field is required and cannot be left empty!';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    RegisterationModel.name = value!;
                                    print(
                                        "REgisterion name = ${RegisterationModel.name}");
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
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 15.0),
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
                                  initialValue: initials['email'] as String,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Enter Your Email',
                                    border: InputBorder.none,
                                    hintText: 'john@email.com',
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                  validator: (value) {
                                    // if (value!.isEmpty) {
                                    //   return 'Invalid email!';
                                    // } else if (!isEmail(value)) {
                                    //   return 'Please enter valid Email.';
                                    // }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    RegisterationModel.email = value!;
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
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 15.0),
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
                                  controller: passContoller,
                                  // obscureText: true,

                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: InputDecoration(
                                    suffixIcon: Container(
                                      margin: const EdgeInsets.all(8),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          minimumSize: const Size(100, 50),
                                        ),
                                        child: const Text(
                                          "generate pass",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        onPressed: () {
                                          generatePassword();
                                        },
                                      ),
                                    ),
                                    labelText: 'Enter Your Password',
                                    border: InputBorder.none,
                                    hintText: '********',
                                    hintStyle: const TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Password is not valid!';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    RegisterationModel.password = value!;
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
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 15.0),
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
                                  initialValue: initials['phoneNo'] as String,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Enter Your Phone Number',
                                    border: InputBorder.none,
                                    hintText: '030xxxxxxxx',
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Phone Number is not valid!';
                                    } else if (!isPhone(value)) {
                                      return 'Please enter valid Phone.';
                                    }
                                    if (value.contains("#") ||
                                        value.contains("*") ||
                                        value.contains("\$") ||
                                        value.contains("=") ||
                                        value.contains("&") ||
                                        value.contains("^") ||
                                        value.contains("%") ||
                                        value.contains("@")) {
                                      return 'Invalid Phone Number';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    RegisterationModel.phoneNo = value!;
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
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 15.0),
                                child: Icon(
                                  Icons.work_rounded,
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
                                      initials['designation'] as String,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    labelText: 'Enter Job Designation',
                                    border: InputBorder.none,
                                    hintText: 'Associate Marketing Manager',
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This field cannot be left empty!';
                                    } else if (value.contains("#") ||
                                        value.contains("*") ||
                                        value.contains("\$") ||
                                        value.contains("=") ||
                                        value.contains("&") ||
                                        value.contains("^") ||
                                        value.contains("%") ||
                                        value.contains("@")) {
                                      return 'Invalid Job Designation';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    RegisterationModel.designation = value!;
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
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 15.0),
                                child: Icon(
                                  Icons.calendar_today_rounded,
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
                                  initialValue: initials['age'] as String,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Enter Your Age',
                                    border: InputBorder.none,
                                    hintText: '22',
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This field cannot be left empty!';
                                    }
                                    if (int.parse(value) >= 110) {
                                      return 'Age is not valid';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    RegisterationModel.age = value!;
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
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 15.0),
                                child: Icon(
                                  Icons.house_rounded,
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
                                  initialValue: initials['owner'] as String,
                                  keyboardType: TextInputType.name,
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Owner/Related Family Member Name',
                                    border: InputBorder.none,
                                    hintText: 'John Smith',
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This field cannot be left empty!';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    RegisterationModel.owner = value!;
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
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 15.0),
                                child: Icon(
                                  Icons.pin_drop_rounded,
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
                                  initialValue: initials['address'] as String,
                                  keyboardType: TextInputType.streetAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Enter Your Address',
                                    border: InputBorder.none,
                                    hintText:
                                        '455 Maple St, Brooklyn, NY 11225',
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This field cannot be left empty!';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    RegisterationModel.address = value!;
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
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 15.0),
                                child: Icon(
                                  Icons.person_2_rounded,
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
                                  initialValue: initials['fname'] as String,
                                  keyboardType: TextInputType.name,
                                  decoration: const InputDecoration(
                                    labelText: 'Father Name',
                                    border: InputBorder.none,
                                    hintText: 'William Dennis',
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This field cannot be left empty!';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    RegisterationModel.fname = value!;
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
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 15.0),
                                child: Icon(
                                  Icons.phone_in_talk_rounded,
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
                                  initialValue: initials['fphoneNo'] as String,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Father Phone Number',
                                    border: InputBorder.none,
                                    hintText: '030xxxxxxxx',
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Phone Number is not valid!';
                                    } else if (!isPhone(value)) {
                                      return 'Please enter valid Phone.';
                                    }
                                    if (value.contains("#") ||
                                        value.contains("*") ||
                                        value.contains("\$") ||
                                        value.contains("=") ||
                                        value.contains("&") ||
                                        value.contains("^") ||
                                        value.contains("%") ||
                                        value.contains("@")) {
                                      return 'Invalid Phone Number';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    RegisterationModel.fphoneNo = value!;
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 20.0),
                          padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.symmetric(
                                                  vertical: 25,
                                                  horizontal:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width -
                                                          MediaQuery.of(context)
                                                              .padding
                                                              .top) *
                                              0.25),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              const Color.fromRGBO(15, 39, 127,
                                                  1)), // <-- Button color
                                      overlayColor: MaterialStateProperty
                                          .resolveWith<Color?>((states) {
                                        if (states
                                            .contains(MaterialState.pressed)) {
                                          return const Color.fromRGBO(
                                              15, 39, 127, 0.548);
                                          return null; // <-- Splash color
                                        }
                                        return null;
                                      }),
                                    ),
                                    child: const Text(
                                      "Continue",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      await saveform();

                                      //   print("Working");
                                      //
                                    }),
                              )
                            ],
                          ),
                        ),
                        // Container(
                        //   //padding: EdgeInsets.all(20),
                        //   margin: EdgeInsets.all(20),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       Container(
                        //           child: TextButton(
                        //       child:Text( "Register a Family Member ?",
                        //         style: TextStyle(color: Colors.teal[800]),
                        //       ),onPressed: (){
                        //         Navigator.push(
                        //               context,
                        //               PageTransition(
                        //                   duration: Duration(milliseconds: 700),
                        //                   type: PageTransitionType
                        //                       .leftToRightWithFade,
                        //                   child: Register_FM()));

                        //                   },)),
                        //       TextButton(
                        //         style: TextButton.styleFrom(
                        //           textStyle: const TextStyle(
                        //               fontSize: 12,
                        //               fontWeight: FontWeight.w800,
                        //               color: Color(0xff8d43d6)),
                        //         ),
                        //         onPressed: () {
                        //           Navigator.push(
                        //               context,
                        //               PageTransition(
                        //                   duration: Duration(milliseconds: 700),
                        //                   type: PageTransitionType
                        //                       .leftToRightWithFade,
                        //                   child: Register_FM()));
                        //         },
                        //         child: const Text(
                        //           'Sign Up',
                        //           style: TextStyle(
                        //               color: Colors.teal,
                        //               fontWeight: FontWeight.bold),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showDialog1(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Family Member'),
            content: const Text('You want to add a family member?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Handle "No" button press
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Your Details has been submitted ")));
                  Navigator.of(context).pop();
                  _formKey.currentState!.reset();
                  FocusScope.of(context).unfocus();
                  // Close the dialog
                  // You can navigate back to the previous page here
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  print(RegisterationModel.uid);
                  // Handle "Yes" button press
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Register_FM(
                              docid: documentId,
                              owner: RegisterationModel.owner,
                              address: RegisterationModel.address,
                              parentID: documentId,
                              ownerEmail: email))); // Close the dialog
                  // You can navigate to the page where you want to add a family member
                  // using Navigator or any other navigation method
                },
                child: const Text('Yes'),
              ),
            ],
          );
        });
  }
}
