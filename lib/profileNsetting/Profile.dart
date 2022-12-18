import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:individual_project/model/UserProvider.dart';
import 'package:individual_project/model/User.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';

import '../model/data/LearnTopicData.dart';
import '../model/data/TestPreparationData.dart';


class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FocusNode _screenFocus = FocusNode();
  String _firstSelected ='assets/images/usaFlag.svg';
  bool _isLoading = false;
  final _changeInfoFormKey = GlobalKey<FormState>();

  PickedFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();

  Country? testCon;
  final FocusNode _ctFocus = FocusNode();
  final TextEditingController _ctController = TextEditingController();
  String? postCt = "";

  final FocusNode _bdFocus = FocusNode();
  final TextEditingController _bdController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      setState(() {
        _bdController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  String? selectedLevel;
  String? postLevel;
  final List<String> levels = [
    'BEGINNER',
    'HIGHER_BEGINNER',
    'PRE_INTERMEDIATE',
    'INTERMEDIATE',
    'UPPER_INTERMEDIATE',
    'ADVANCE',
    'PROFICIENCY',
  ];
  final List<String> levelItems = [
    'Pre A1 (Beginner)',
    'A1 (Higher Beginner)',
    'A2 (Pre-Intermediate)',
    'B1 (Intermediate)',
    'B2 (Upper-Intermediate)',
    'C1 (Advance)',
    'C2 (Proficiency)',
  ];

  List<String> selectedSubjects = [];
  List<String> postLearn = [];
  List<String> postTest = [];
  final List<LearnTopics> learnData = LearnTopicData.all;
  final List<TestPreparations> testData = TestPreparationData.all;
  final List<String> subjectItems = ['Subjeish for Kids', 'Business English', 'Conversational English', 'Test Preparation:', 'STARTERS', 'MOVERS', 'FLYERS', 'KET', 'PET', 'IELTS', 'TOEFL', 'TOEIC'];

  final TextEditingController _ssController = TextEditingController();
  final FocusNode _scFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    /*Provider.of<UserProvider>(context, listen: false).thisTokens = Tokens(
      access: Access(
        token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkZTZhMGViZS1lOGNkLTRhODQtYTc0Yi0yOWZlNTM5NjRjNDciLCJpYXQiOjE2NzA0MzQ0ODIsImV4cCI6MTY3MDUyMDg4MiwidHlwZSI6ImFjY2VzcyJ9.1XRe5c5agbl9n2JVVUWV7bdybIFiEZiJs0PWvGjae9k",
        expires: "2022-12-08T05:35:46.286Z"
      ),
      refresh: Refresh(
        token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkZTZhMGViZS1lOGNkLTRhODQtYTc0Yi0yOWZlNTM5NjRjNDciLCJpYXQiOjE2NzAzOTEzNDYsImV4cCI6MTY3Mjk4MzM0NiwidHlwZSI6InJlZnJlc2gifQ.5DiiDFVhCFUnlHFosgDn7EvWUwWBGy5kcADSR9opstE",
        expires: "2023-01-06T05:35:46.286Z"
      )
    );*/
    UserProvider thisUserProvider = context.read<UserProvider>();
    thisUserProvider.getUser(thisUserProvider.thisTokens.access);
    
    _nameController.text = "${thisUserProvider.thisUser.name}";

    postCt = thisUserProvider.thisUser.country;
    selectedDate = DateTime.parse(thisUserProvider.thisUser.birthday);
    testCon = Country.tryParse(postCt.toString());
    _ctController.text = testCon == null ?  "" : testCon!.name;
    _bdController.text = thisUserProvider.thisUser.birthday ?? "";

    if (thisUserProvider.thisUser.level != null) {
      String thisLevel = thisUserProvider.thisUser.level;
      for(int i = 0; i < levels.length; i++) {
        if (thisLevel.compareTo(levels[i]) == 0) {
          selectedLevel = levelItems[i];
        }
      }
    }
    else {
      selectedLevel = null;
    }

    if (thisUserProvider.thisUser.learnTopics != null && thisUserProvider.thisUser.testPreparations != null) {
      List<String> subjects = [];
      if (thisUserProvider.thisUser.learnTopics != null) {
        List<LearnTopics> tempLearn = thisUserProvider.thisUser.learnTopics;
        for (int i = 0; i < tempLearn.length; i++) {
          for (int j = 0; j < subjectItems.length; j++) {
            if (tempLearn[i].name.compareTo(subjectItems[j]) == 0) {
              subjects.add(subjectItems[j]);
            }
          }
        }
      }
      if (thisUserProvider.thisUser.testPreparations != null) {
        List<TestPreparations> tempTest = thisUserProvider.thisUser.testPreparations;
        for (int i = 0; i < tempTest.length; i++) {
          for (int j = 0; j < subjectItems.length; j++) {
            if (tempTest[i].name.compareTo(subjectItems[j]) == 0) {
              subjects.add(subjectItems[j]);
            }
          }
        }
      }
      selectedSubjects = subjects;
    }

    _ssController.text = thisUserProvider.thisUser.studySchedule == null || thisUserProvider.thisUser.studySchedule.isEmpty ? "" : thisUserProvider.thisUser.studySchedule;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          FocusScope.of(context).requestFocus(_screenFocus);
        });
      },
      child: Scaffold(
        appBar: AppBar(backgroundColor: Theme.of(context).backgroundColor,
          title: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    "/tutor",
                        (route) => route.isCurrent && route.settings.name == "/tutor"
                        ? false
                        : true);
              }, //sửa sau
              child: SizedBox(
                height: 30,
                child: SvgPicture.asset('assets/images/logo.svg'),
              )
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            PopupMenuButton<String>(
              child: SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 25,
                        height: 25,
                        child: SvgPicture.asset(_firstSelected),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 8,
                            color: Colors.grey,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              offset: Offset(0, 50),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'assets/images/usaFlag.svg',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: SvgPicture.asset('assets/images/usaFlag.svg'),
                      ),
                      SizedBox(width: 20,),
                      Text('Engilish')
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'assets/images/vnFlag.svg',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: SvgPicture.asset('assets/images/vnFlag.svg'),
                      ),
                      SizedBox(width: 20,),
                      Text('Vietnamese')
                    ],
                  ),
                ),
              ],
              onSelected: (String value) {
                setState(() {
                  _firstSelected = value;
                });
              },
            ),
            SizedBox(width: 10,),
            PopupMenuButton<String>(
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: Icon(Icons.menu, color: Theme.of(context).backgroundColor,),
                  ),
                ),
              ),
              offset: Offset(0, 50),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'Profile',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: CircleAvatar(
                          radius: 80.0,
                          backgroundImage: _imageFile == null
                              ? Image.network('${context.read<UserProvider>().thisUser.avatar}').image
                              : FileImage(File(_imageFile!.path)),
                        ),
                      ),
                      SizedBox(width: 20,),
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'BuyLessons',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset('assets/images/icons/BuyLessons.png', color: Colors.blue,),
                      ),
                      SizedBox(width: 20,),
                      Text(
                        'Buy Lessons',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Tutor',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset('assets/images/icons/Tutor.png', color: Colors.blue,),
                      ),
                      SizedBox(width: 20,),
                      Text(
                        'Tutor',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Schedule',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset('assets/images/icons/Schedule.png', color: Colors.blue,),
                      ),
                      SizedBox(width: 20,),
                      Text(
                        'Schedule',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'History',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset('assets/images/icons/History.png', color: Colors.blue,),
                      ),
                      SizedBox(width: 20,),
                      Text(
                        'History',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Courses',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset('assets/images/icons/Courses.png', color: Colors.blue,),
                      ),
                      SizedBox(width: 20,),
                      Text(
                        'Courses',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'MyCourse',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset('assets/images/icons/MyCourse.png', color: Colors.blue,),
                      ),
                      SizedBox(width: 20,),
                      Text(
                        'My Course',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'BecomeTutor',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset('assets/images/icons/BecomeTutor.png', color: Colors.blue,),
                      ),
                      SizedBox(width: 20,),
                      Text(
                        'Become a Tutor',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Setting',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset('assets/images/icons/Setting.png', color: Colors.blue,),
                      ),
                      SizedBox(width: 20,),
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Logout',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset('assets/images/icons/Logout.png', color: Colors.blue,),
                      ),
                      SizedBox(width: 20,),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'Profile') {
                  Navigator.pushReplacementNamed(context, '/profile');
                }
                else if (value == 'Tutor') {
                  Navigator.pushNamed(context, '/tutor');
                }
                else if (value == 'Schedule') {
                  Navigator.pushNamed(context, '/schedule');
                }
                else if (value == 'History') {
                  Navigator.pushNamed(context, '/history');
                }
                else if (value == 'Courses') {
                  Navigator.pushNamed(context, '/courses');
                }
                else if (value == 'BecomeTutor') {
                  Navigator.pushNamed(context, '/become_tutor');
                }
                else if (value == 'Setting') {
                  Navigator.pushNamed(context, '/setting');
                }
                else if (value == 'Logout') {
                  Navigator.of(context).pushNamedAndRemoveUntil("/login",
                          (route) {return false;});
                }
              },
            ),
          ],
          //automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _changeInfoFormKey,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Proflie',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: ImageProfile(),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: SizedBox(
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(10),
                                child: Text(
                                  '${context.watch<UserProvider>().thisUser.name}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                'Account ID: ${context.read<UserProvider>().thisUser.id}',
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              TextButton(
                                onPressed: null,
                                child: Text(
                                  'Others review you',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.only(top: 15),
                            child: RichText(
                              text: TextSpan(
                                text: '*',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                                children: [
                                  TextSpan(
                                      text: 'Name:',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      )
                                  ),
                                ],
                              ),
                            ),
                          )
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            autovalidateMode: AutovalidateMode.always,
                            controller: _nameController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: Colors.grey),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: Colors.blue),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: Colors.red),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: Colors.orange),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                errorStyle: TextStyle(
                                  fontSize: 15,
                                )
                            ),
                            validator: (val) {
                              if(val == null || val.isEmpty){
                                return "Please input your Name!";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.only(top: 15),
                            child: Text('Email Address:'),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              initialValue: '${context.read<UserProvider>().thisUser.email}',
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: Colors.grey),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                filled: true,
                                fillColor: Color(0xffd9d9d9),
                              ),
                              enabled: false,
                            ),
                          ),
                        ),
                      ],
                    )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: RichText(
                          text: TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                            children: [
                              TextSpan(
                                  text: 'Country:',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          focusNode: _ctFocus,
                          controller: _ctController,
                          autovalidateMode: AutovalidateMode.always,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.blue),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.orange),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.red),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            errorStyle: TextStyle(
                              fontSize: 15,
                            ),
                            suffixIcon: Container(
                              margin: EdgeInsets.only(right: 13),
                              width: 84,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _ctController.text.isNotEmpty ?
                                  IconButton(onPressed: () {setState(() {
                                    _ctController.clear();
                                    selectedDate = DateTime.now();
                                    _ctFocus.unfocus();
                                  });}, icon: Icon(Icons.clear)) : Container(),
                                  Icon(Icons.flag_outlined),
                                ],
                              ),
                            ),
                          ),
                          readOnly: true,
                          onTap: () => {
                            _ctFocus.requestFocus(),
                            showCountryPicker(
                              context: context,
                              onSelect: (Country country) => {
                                _ctFocus.unfocus(),
                                _ctController.text = country.name,
                                postCt = country.countryCode,
                              },
                            ),
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please select your Country!";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Text('Phone Number:'),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          initialValue: '${context.read<UserProvider>().thisUser.phone}',
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            filled: true,
                            fillColor: Color(0xffd9d9d9),
                          ),
                          enabled: false,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: 100),
                  margin: EdgeInsets.only(bottom: 5),
                  alignment: Alignment.centerLeft,
                  child: context.read<UserProvider>().thisUser.isPhoneActivated
                      ? Text('Verified', style: TextStyle(color: Colors.green),)
                      : Text('Unverified', style: TextStyle(color: Colors.red),),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: RichText(
                          text: TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                            children: [
                              TextSpan(
                                  text: 'Birthday:',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          focusNode: _bdFocus,
                          controller: _bdController,
                          autovalidateMode: AutovalidateMode.always,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.blue),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.orange),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.red),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            errorStyle: TextStyle(
                              fontSize: 15,
                            ),
                            suffixIcon: Container(
                              margin: EdgeInsets.only(right: 13),
                              width: 84,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _bdController.text.isNotEmpty ?
                                  IconButton(onPressed: () {setState(() {
                                    _bdController.clear();
                                    selectedDate = DateTime.now();
                                    _bdFocus.unfocus();
                                  });}, icon: Icon(Icons.clear)) : Container(),
                                  Icon(Icons.calendar_month_outlined),
                                ],
                              ),
                            ),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please select your Birthday!";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: RichText(
                          text: TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                            children: [
                              TextSpan(
                                  text: 'My Level:',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: DropdownSearch<String>(
                          items: levelItems,
                          clearButtonProps: ClearButtonProps(
                            isVisible: true,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.zero,
                          ),
                          dropdownButtonProps: DropdownButtonProps(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 12),
                          ),
                          popupProps: PopupProps.menu(
                            showSelectedItems: true,
                            showSearchBox: true,
                          ),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: Colors.grey),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: Colors.blue),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: Colors.orange),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: Colors.red),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              errorStyle: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          selectedItem: selectedLevel,
                          autoValidateMode: AutovalidateMode.always,
                          onChanged: (val) {
                            selectedLevel = val;
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please select your Level!";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(top: 10),
                        child: RichText(
                          text: TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                            children: [
                              TextSpan(
                                  text: 'Want to learn:',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: DropdownSearch<String>.multiSelection(
                            items: subjectItems,
                            popupProps: PopupPropsMultiSelection.menu(
                              showSelectedItems: true,
                              showSearchBox: true,
                              disabledItemFn: (String s) => s == 'Subjects:' || s == 'Test Preparation:',
                            ),
                            clearButtonProps: ClearButtonProps(
                              isVisible: true,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.zero,
                            ),
                            dropdownButtonProps: DropdownButtonProps(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 12),
                            ),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: Colors.grey),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: Colors.blue),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: Colors.orange),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: Colors.red),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                errorStyle: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            selectedItems: selectedSubjects,
                            autoValidateMode: AutovalidateMode.always,
                            onChanged: (val) {
                              setState(() {
                                selectedSubjects = val;
                              });
                            },
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Please select at least one subject!";
                              }
                              return null;
                            },
                          )
                      ),
                    ),
                  ],
                ),
                Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.only(top: 10),
                            child: Text('Study Schedule:'),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              controller: _ssController,
                              minLines: 3,
                              maxLines: 8,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: Colors.grey),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: Colors.blue),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: 'Note the time of the week you want to study on LetTutor.',
                                isCollapsed: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    focusNode: _scFocus,
                    style: OutlinedButton.styleFrom(
                      fixedSize: Size(170, 50),
                      padding: EdgeInsets.all(15),
                      backgroundColor: Colors.blue,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isLoading
                            ? SizedBox(height: 10, width: 10, child: CircularProgressIndicator(color: Colors.white,),)
                            : Container(),
                        SizedBox(width: 5,),
                        Text(
                          'Save changes',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        _isLoading
                        ? SizedBox(width: 15,)
                        : SizedBox(width: 5,),
                      ],
                    ),
                    onPressed: () async {
                      _scFocus.requestFocus();
                      if (_changeInfoFormKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });
                        //print(_nameController.text);
                        //print(postCt);
                        //print(_bdController.text);
                        for(int i = 0; i < levelItems.length; i++) {
                          if (selectedLevel?.compareTo(levelItems[i]) == 0) {
                            postLevel = levels[i];
                          }
                        }
                        //print(postLevel);
                        for (int i = 0; i < learnData.length; i++) {
                          for (int j = 0; j < selectedSubjects.length; j++) {
                            if (learnData[i].name.compareTo(selectedSubjects[j]) == 0 && !postLearn.contains(learnData[i].id.toString())) {
                              postLearn.add(learnData[i].id.toString());
                            }
                          }
                        }
                        //print(jsonEncode(postLearn.toString()));
                        for (int i = 0; i < testData.length; i++) {
                          for (int j = 0; j < selectedSubjects.length; j++) {
                            if (testData[i].name.compareTo(selectedSubjects[j]) == 0 && !postTest.contains(testData[i].id.toString())) {
                              postTest.add(testData[i].id.toString());
                            }
                          }
                        }
                        //print(postTest);
                        //print(_ssController.text);
                        //print(context.read<UserProvider>().thisUser.avatar);

                        var url = Uri.https('sandbox.api.lettutor.com', 'user/info');

                        var response = await http.put(url,
                            headers: {
                              "Accept": "application/json",
                              "Content-Type": "application/json",
                              'Authorization': "Bearer ${context.read<UserProvider>().thisTokens.access.token}"
                            },
                            body: jsonEncode(<String, dynamic>{'name': _nameController.text, 'country': postCt, 'birthday': _bdController.text, 'level': postLevel, 'studySchedule': _ssController.text, 'learnTopics': postLearn, 'testPreparations':postTest}),
                        );
                        setState(() {
                          _isLoading = false;
                        });
                        if (response.statusCode != 200) {
                          final Map parsed = json.decode(response.body);
                          final String err = parsed["message"];
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(err, style: TextStyle(color: Colors.red),),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                        else {
                          context.read<UserProvider>().getUser(context.read<UserProvider>().thisTokens.access);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Successfully changed!', style: TextStyle(color: Colors.green),),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    }, //sửa sau
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
          },
          backgroundColor: Colors.grey,
          child: const Icon(Icons.message_outlined),
        ),
      ),
    );
  }
  Widget ImageProfile() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 80.0,
          backgroundImage: _imageFile == null
              ? Image.network('${context.read<UserProvider>().thisUser.avatar}').image
              : FileImage(File(_imageFile!.path)),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: ((builder) => bottomSheet()),
              );
            },
            child: Icon(
              Icons.camera_alt,
              color: Colors.blue,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }
  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            "Choose Profile photo",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
            ElevatedButton.icon(
              icon: Icon(Icons.camera),
              onPressed: () {
                takePhoto(ImageSource.camera);
              },
              label: Text("Camera"),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.image),
              onPressed: () {
                takePhoto(ImageSource.gallery);
              },
              label: Text("Gallery"),
            ),
          ])
        ],
      ),
    );
  }
  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.getImage(
      source: source,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      Map<String, String> headers = {
        'Authorization': "Bearer ${context.read<UserProvider>().thisTokens.access.token}"
      };
      var url = Uri.https('sandbox.api.lettutor.com', 'user/uploadAvatar');
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath('avatar', _imageFile!.path));
      var res = await request.send();
      if (res.statusCode != 200) {
        final Map parsed = json.decode(await res.stream.bytesToString());
        final String err = parsed["message"];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err, style: TextStyle(color: Colors.red),),
            duration: Duration(seconds: 3),
          ),
        );
      }
      else {
        context.read<UserProvider>().getUser(context.read<UserProvider>().thisTokens.access);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully updated avatar!', style: TextStyle(color: Colors.green),),
            duration: Duration(seconds: 3),
          ),
        );
      }
      Navigator.pop(context);
    }
  }
}