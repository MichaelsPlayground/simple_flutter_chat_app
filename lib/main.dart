import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/ChatRoom.dart';
import 'models/ChatMessage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return MaterialApp(
              home: Container(
                color: Colors.white,
                child: Text("error"),
              ));
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(home: MyHomePage());
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(
            home: Container(
              color: Colors.white,
              child: Text("Loading"),
            ));
      },
    );
  }
}

class ProfileInfo extends StatefulWidget {
  @override
  _ProfileInfoState createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  final nicknameFieldController = TextEditingController();
  String nickname = "";
  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefValue) => {
      setState(() {
        nickname = prefValue.getString('nickname') ?? "";
        nicknameFieldController.text = nickname;
      })
    });

    nicknameFieldController.addListener(() {
      setNickname();
    });
  }

  void saveNickname() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('nickname', nickname);
  }

  setNickname() async {
    setState(() {
      nickname = nicknameFieldController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text("Nickname: $nickname"),
            TextField(
              enabled: true,
              controller: nicknameFieldController,
            ),
            Container(
                margin: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    saveNickname();
                    final snackBar = SnackBar(
                      content: Text('Updated username!'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: Text('Update'),
                ))
          ],
        ),
      ),
    );
  }
}

class RoomPage extends StatefulWidget {
  RoomPage({Key? key, required this.id}) : super(key: key);
  final int id;
  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late String message = "";
  late String nickname = "";
  late String roomname = "";

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _chatMessageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefValue) => {
      setState(() {
        nickname = prefValue.getString('nickname') ?? "";
      })
    });
    roomname = "Chat room " + (widget.id + 1).toString();
  }

  setMessage() async {
    setState(() {
      message = this._chatMessageController.text;
    });
  }

  DateTime readTimeStamp(dynamic date) {
    Timestamp timestamp = date;
    return timestamp.toDate();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController messageController = TextEditingController();
    CollectionReference messagesCollection = FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.id.toString())
        .collection("messages");

    final snapStream = messagesCollection
        .orderBy('date', descending: true)
        .limit(100)
        .snapshots()
        .map((obj) => obj.docs
        .map((e) => new ChatMessage(
        e.data()['message'],
        e.data()['nickname'].toString(),
        readTimeStamp(e.data()['date'])))
        .toList());

    Future<void> addMessage() {
      return messagesCollection.add({
        'message': this.message,
        "nickname": this.nickname,
        "date": DateTime.now()
      }).then((value) => messageController.text = "");
    }

    return StreamBuilder<List<ChatMessage>>(
      stream: snapStream,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return DisplayLoading();
        }

        return Scaffold(
          appBar: AppBar(title: Text(this.roomname)),
          body: Stack(
            children: <Widget>[
              Align(
                child: ListView.builder(
                  itemCount: (snapshot.data as List<ChatMessage>).length,
                  shrinkWrap: true,
                  reverse: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(top: 10, bottom: 80),
                  itemBuilder: (context, index) {
                    final messageData =
                    (snapshot.data as List<ChatMessage>)[index];
                    final bool isMe = messageData.nickname == nickname;
                    final String? messenger = messageData.nickname;
                    late String timeformat = DateFormat('yyyy-MM-dd – kk:mm')
                        .format(messageData.date);

                    late String message = messageData.message;

                    if (!isMe) {
                      if (message != null) {
                        //message = messenger + ': ' + message;
                        if (messenger != null) {
                          message = messenger + ': ' + message;
                        }
                      }
                    }

                    return Container(
                      padding: EdgeInsets.only(
                          left: 14, right: 14, top: 10, bottom: 10),
                      child: Align(
                        alignment:
                        (!isMe ? Alignment.topLeft : Alignment.topRight),
                        child: Stack(children: [
                          GestureDetector(
                              onTap: () => {},
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: (!isMe
                                      ? Colors.grey.shade200
                                      : Colors.blue[400]),
                                ),
                                padding: EdgeInsets.all(16),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: !isMe
                                            ? Colors.black87
                                            : Colors.white),
                                    text: '$timeformat\n',
                                    children: [
                                      TextSpan(
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: !isMe
                                                ? Colors.black87
                                                : Colors.white),
                                        text: message,
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                        ]),
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                  height: 60,
                  width: double.infinity,
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          onChanged: (str) => {this.message = str},
                          decoration: InputDecoration(
                              hintText: "Write message...",
                              hintStyle: TextStyle(color: Colors.black54),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      FloatingActionButton(
                        onPressed: addMessage,
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                        backgroundColor: Colors.blue,
                        elevation: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DisplayLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(child: Text("Loading...")),
    );
  }
}

class RoomsListPage extends StatelessWidget {
  RoomsListPage({Key? key}) : super(key: key);
  final List<ChatRoom> items =
  List<ChatRoom>.generate(2, (index) => new ChatRoom(index));

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return new ListTile(
          title: new Text('${items[index].name}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RoomPage(id: index)),
            );
          },
          contentPadding: EdgeInsets.symmetric(horizontal: 26.0),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Simple Chat")),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            ProfileInfo(),
            RoomsListPage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        showElevation: true,
        itemCornerRadius: 50,
        mainAxisAlignment: MainAxisAlignment.center,
        curve: Curves.easeIn,
        onItemSelected: (index) => {
          setState(() => _currentIndex = index),
          _pageController.jumpToPage(index)
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: Icon(Icons.people),
            title: Text('Profile'),
            activeColor: Colors.purpleAccent,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.message),
            title: Text(
              'Chat Rooms',
            ),
            activeColor: Colors.pink,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
