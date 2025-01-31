import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:individual_project/model/Course/CourseList.dart';
import 'package:individual_project/model/User/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../tutor/TutorProfile.dart';

class CourseDetail extends StatefulWidget {
  final String id;
  const CourseDetail({Key? key, required this.id}) : super(key: key);

  @override
  State<CourseDetail> createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail> {
  final theGetController c = Get.put(theGetController());
  CourseClass thisCourse = CourseClass(id: "", name: "", description: "", imageUrl: "", level: "",
      reason: "", purpose: "", otherDetails: "", defaultPrice: 0, coursePrice: 0, visible: true,
      createdAt: "", updatedAt: "", topics: [], categories: [], users: []);

  bool _isLoading = false;
  TextEditingController _errorController = TextEditingController();

  final List<Map<String, String>> lvMap = [
    {"level": "0", "levelName": "Any Level",},
    {"level": "1", "levelName": "Beginner",},
    {"level": "2", "levelName": "Upper-Beginner",},
    {"level": "3", "levelName": "Pre-Intermediate",},
    {"level": "4", "levelName": "Intermediate",},
    {"level": "5", "levelName": "Upper-Intermediate",},
    {"level": "6", "levelName": "Pre-Advanced",},
    {"level": "7", "levelName": "Advanced",},
    {"level": "8", "levelName": "Very Advanced",},
  ];

  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
      _errorController.text = "";
    });
    getACourse();
  }

  void getACourse() async {
    var url = Uri.https('sandbox.api.lettutor.com', 'course/${widget.id}');
    var response = await http.get(url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': "Bearer ${context.read<UserProvider>().thisTokens.access.token}"
      },
    );

    if (response.statusCode != 200) {
      final Map parsed = json.decode(response.body);
      final String err = parsed["message"];
      setState(() {
        _errorController.text = err;
      });
    }
    else {
      final Map parsed = json.decode(response.body);
      setState(() {
        thisCourse = CourseClass.fromJson(parsed['data']);
        _errorController.text = "";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;

    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).backgroundColor,
        title: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/tutor', (Route route) => false);
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
                      child: SvgPicture.asset('${c.firstSelected}'),
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
                    Text('English'.tr)
                  ],
                ),
                onTap: () => {
                  
                  c.updateImg('assets/images/usaFlag.svg'),
                  c.updateLocale(Locale('en', 'US')),
                },
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
                    Text('Vietnamese'.tr)
                  ],
                ),
                onTap: () => {
                  
                  c.updateImg('assets/images/vnFlag.svg'),
                  c.updateLocale(Locale('vi', 'VN')),
                }, //
              ),
            ],
            /*onSelected: (String value) {
              setState(() {
                _firstSelected = value;
              });
            },*/
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
                        backgroundImage: Image.network('${context.read<UserProvider>().thisUser.avatar}').image,
                      ),
                    ),
                    SizedBox(width: 20,),
                    Text(
                      'Profile'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              /*PopupMenuItem(
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
                ),*/
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
                      'Tutor'.tr,
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
                      'Schedule'.tr,
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
                      'History'.tr,
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
                      'Courses'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              /*PopupMenuItem(
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
                ),*/
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
                      'Become a Tutor'.tr,
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
                      'Settings'.tr,
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
                      'Logout'.tr,
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
                Navigator.pushNamed(context, '/profile');
              }
              else if (value == 'Tutor') {
                Navigator.of(context).pushNamedAndRemoveUntil('/tutor', (Route route) => false);
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
        child: _isLoading == true
          ? Center(child: CircularProgressIndicator())
          : _errorController.text.isNotEmpty
          ? Center(child: Text(_errorController.text))
          : Column(
          children: [
            Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Image.network(thisCourse.imageUrl),
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 15),
                          alignment: Alignment.centerLeft,
                          child: Text(thisCourse.name, style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis
                          ), maxLines: 2,),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 25),
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          alignment: Alignment.centerLeft,
                          child: Text(thisCourse.description, style: TextStyle(
                              fontSize: 17,
                              overflow: TextOverflow.ellipsis
                          ), maxLines: 3,),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 20),
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              backgroundColor: Colors.blue,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            ),
                            child: Text(
                              'Discover'.tr,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/course_discover', arguments: DiscoverArg(0, thisCourse));
                            }, //sửa sau
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Divider(
                    thickness: 2,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text('Overview'.tr, style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),),
                ),
                Expanded(child: Divider(thickness: 2,)),
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
              child: Text.rich(
                  TextSpan(
                      children: <InlineSpan>[
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Image.asset('assets/images/icons/Question.png', color: Colors.red, width: 20, height: 20,),
                        ),
                        TextSpan(
                          text: " ",
                        ),
                        TextSpan(text: 'Why take this course'.tr, style: TextStyle(
                          fontSize: 17,
                        )),
                      ]
                  )
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
              margin: EdgeInsets.only(bottom: 15),
              child: Text(thisCourse.reason),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
              child: Text.rich(
                  TextSpan(
                      children: <InlineSpan>[
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Image.asset('assets/images/icons/Question.png', color: Colors.red, width: 20, height: 20,),
                        ),
                        TextSpan(
                          text: " ",
                        ),
                        TextSpan(text: 'What will you be able to do'.tr, style: TextStyle(
                          fontSize: 17,
                        )),
                      ]
                  )
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
              margin: EdgeInsets.only(bottom: 15),
              child: Text(thisCourse.purpose),
            ),
            Row(
              children: [
                Container(
                  width: 20,
                  child: Divider(
                    thickness: 2,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text('Experience Level'.tr, style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),),
                ),
                Expanded(child: Divider(thickness: 2,)),
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
              child: Text.rich(
                  TextSpan(
                      children: <InlineSpan>[
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(Icons.people_alt_sharp, color: Colors.deepPurple, size: 20,),
                        ),
                        TextSpan(text: " " + lvMap[lvMap.indexWhere((element) => element['level'] == thisCourse.level)]["levelName"]!, style: TextStyle(
                          fontSize: 17,
                        )),
                      ]
                  )
              ),
            ),
            Row(
              children: [
                Container(
                  width: 20,
                  child: Divider(
                    thickness: 2,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text('Course Length'.tr, style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),),
                ),
                Expanded(child: Divider(thickness: 2,)),
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
              child: Text.rich(
                  TextSpan(
                      children: <InlineSpan>[
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(Icons.book, color: Colors.deepPurple, size: 20,),
                        ),
                        TextSpan(text: ' ${thisCourse.topics.length} ${'topics'.tr}', style: TextStyle(
                          fontSize: 17,
                        )),
                      ]
                  )
              ),
            ),
            Row(
              children: [
                Container(
                  width: 20,
                  child: Divider(
                    thickness: 2,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text('List Topics'.tr, style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),),
                ),
                Expanded(child: Divider(thickness: 2,)),
              ],
            ),
            GridView.count(
              physics: ScrollPhysics(), // to disable GridView's scrolling
              shrinkWrap: true,
              crossAxisCount: itemWidth < itemHeight ? 2 : 3,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: itemWidth < itemHeight ? (itemHeight / itemWidth - 0.4) : (itemWidth / itemHeight - 0.4),
              children: List.generate(thisCourse.topics.length, (i) {
                return TopicGrid(i+1, thisCourse.topics[i].name);
              }),
            ),
            thisCourse.users.isNotEmpty
            ? Row(
              children: [
                Container(
                  width: 20,
                  child: Divider(
                    thickness: 2,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text('Suggested Tutors'.tr, style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),),
                ),
                Expanded(child: Divider(thickness: 2,)),
              ],
            )
            : Container(),
            thisCourse.users.isNotEmpty
            ? Column(
              children: thisCourse.users.map((e) {
                return Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
                  child: RichText(
                    text: TextSpan(
                        style: TextStyle(
                          fontSize: 17,
                        ),
                        children: [
                          TextSpan(
                            text: e.name,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextSpan(
                            text: ' ',
                          ),
                          TextSpan(
                            text: "More info".tr,
                            style: TextStyle(
                                color: Colors.blue
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {
                              Navigator.pushNamed(context, '/tutor_profile', arguments: ProfileArg(e.id, null));
                            }, //sửa sau
                          ),
                        ]
                    ),
                  ),
                );
              }).toList(),
            )
            : Container(),
          ],
        ),
      ),
      /*/*floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        backgroundColor: Colors.grey,
        child: const Icon(Icons.message_outlined),
      ),*/*/
    );
  }

  Widget TopicGrid(int index, String name, ){
    return Card(
      child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            Navigator.pushNamed(context, '/course_discover', arguments: DiscoverArg(index-1, thisCourse));
          },
          child: Container(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$index.'),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  alignment: Alignment.centerLeft,
                  child: Text(name, style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis
                  ), maxLines: 2,),
                ),
              ],
            ),
          )
      ),
    );
  }
}

class DiscoverArg {
  final CourseClass thisCourse;
  final int index;

  DiscoverArg(this.index, this.thisCourse);
}
