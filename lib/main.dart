import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notify_signup/firebase_options.dart';
import 'package:notify_signup/registar_FM.dart';
import 'package:page_transition/page_transition.dart';
import 'Model/NewUsers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //final FirebaseMessaging _fc = FirebaseMessaging.instance;
  bool _initialized = false;
  bool _error = false;

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      return MaterialApp(
        home: Scaffold(
          body: AlertDialog(
            content: Text('Something went wrong. Please restart the app.'),
          ),
        ),
      );
    }
    if (!_initialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyPage(),
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
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }
 
  bool isPhone(String em) {
    String p =
        r'^((\+92)|(0092))-{0,1}\d{3}-{0,1}\d{7}$|^\d{11}$|^\d{4}-\d{7}$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  var RegisterationModel = RequestUsers(
      name: '',
      email: '',
      password :'',
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
  bool status=false;
    String generateRandomFourDigitCode() {
    Random random = Random();
    int code = random.nextInt(10000);


    // Ensure the code is four digits long (pad with leading zeros if necessary)
    return code.toString().padLeft(4, '0');
  }
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String FCMtoken="";
 getMobileToken() {
  _firebaseMessaging.getToken().then((String? token) {
    if (token != null) {
      
        setState(() {
          FCMtoken=token;
        });
    
      
      print("FCM Token: $FCMtoken");
      
    } else {
      print("Unable to get FCM token");
      
      
    }
    print(FCMtoken);
  });
}
  void saveform() async {
        String fourDigitCode = generateRandomFourDigitCode();

    print("digit code = ${fourDigitCode}");
   String email;
    String pass;
    String FCM_Token;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      try {
     FCM_Token=FCMtoken;
        email=RegisterationModel.email;
        pass=RegisterationModel.password;
        print("Email = ${RegisterationModel.name},password = ${pass}");
      
        UserCredential userCredential=     await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);
         
         User? user=userCredential.user;
        // await getMobileToken();
          await FirebaseFirestore.instance.collection('UserRequest').add({
          "Name": RegisterationModel.name,
          "Phoneno": RegisterationModel.phoneNo,
          "address": RegisterationModel.address,
          "fPhonenumber": RegisterationModel.fphoneNo,
          "fName": RegisterationModel.fname,
          "designation": RegisterationModel.designation,
          "age": RegisterationModel.age,
          "owner": RegisterationModel.owner,
          "status": "Approve",
          "email": RegisterationModel.email,
          "uid":user?.uid,
          "residentID":"INVOSEG${fourDigitCode}",
          "FCM_Token":FCM_Token,
        });
        
        
      
        _formKey.currentState!.reset();
        FocusScope.of(context).unfocus();
        if(userCredential!=null){
setState(() {
          status=true;
        });}
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
      
        
      
      print("Status == ${status}");
      } catch (e) {
        print("Catch working");
        print(e);
      }
     
    
      }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up",style: TextStyle(
                        color: Color(0xff212121),
                        fontWeight: FontWeight.w700,
                        fontSize: 24),),centerTitle: true, leading: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Image(
                      image: AssetImage('assets/Images/rehman.png'),
                      height: 60,
                      width: 60,
                    ),
                  ),backgroundColor:  Colors.white38,elevation: 0,),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formKey,
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
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              Padding(
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
                                  decoration: InputDecoration(
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
                                  },
                                  onSaved: (value) {
                                    
                                    RegisterationModel.name = value!;
                                    print("REgisterion name = ${RegisterationModel.name}");
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
                              Padding(
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
                              new Expanded(
                                child: TextFormField(
                                  initialValue: initials['email'] as String,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Enter Your Email',
                                    border: InputBorder.none,
                                    hintText: 'john@email.com',
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 10),
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
                              Padding(
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
                                  obscureText: true,
                                  initialValue: initials['password'] ,
                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Enter Your Password',
                                    border: InputBorder.none,
                                    hintText: '********',
                                    hintStyle: TextStyle(
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
                        ),Container(
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
                              Padding(
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
                                  decoration: InputDecoration(
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
                              Padding(
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
                                  decoration: InputDecoration(
                                    labelText: 'Enter Job Designation',
                                    border: InputBorder.none,
                                    hintText: 'Associate Marketing Manager',
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This field cannot be left empty!';
                                    }
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
                              Padding(
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
                                  decoration: InputDecoration(
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
                              Padding(
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
                                  decoration: InputDecoration(
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
                              Padding(
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
                                  decoration: InputDecoration(
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
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 15.0),
                                child: Icon(
                                  Icons.family_restroom,
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
                                  decoration: InputDecoration(
                                    labelText: 'Other Family Member Name',
                                    border: InputBorder.none,
                                    hintText: 'William Dennis',
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This field cannot be left empty!';
                                    }
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
                              Padding(
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
                                  decoration: InputDecoration(
                                    labelText: 'Family Member Phone Number',
                                    border: InputBorder.none,
                                    hintText: '030xxxxxxxx',
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'This field cannot be left empty!';
                                    }
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
                                      borderRadius: BorderRadius.circular(10.0),
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
                                    backgroundColor: MaterialStateProperty.all(
                                         Color.fromRGBO(
                                                          15, 39, 127, 1)), // <-- Button color
                                    overlayColor: MaterialStateProperty
                                        .resolveWith<Color?>((states) {
                                      if (states
                                          .contains(MaterialState.pressed))
                                        return  Color.fromRGBO(15, 39, 127, 0.548); // <-- Splash color
                                    }),
                                  ),
                                  child: Text(
                                    "Request Credentials",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: (){
                                     saveform();
                                    if(status==true){
                                    
                                    showDialog1(context);
                                    }
                                    print("Working");
                                    }
                                ),
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
  void showDialog1(BuildContext context){
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Family Member'),
          content: Text('You want to add a family member?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Handle "No" button press
                Navigator.of(context).pop(); // Close the dialog
                // You can navigate back to the previous page here
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                // Handle "Yes" button press
                Navigator.push(context, MaterialPageRoute(builder: (context) => Register_FM(),)); // Close the dialog
                // You can navigate to the page where you want to add a family member
                // using Navigator or any other navigation method
              },
              child: Text('Yes'),
            ),
          ],
        );
    });


  }
}
