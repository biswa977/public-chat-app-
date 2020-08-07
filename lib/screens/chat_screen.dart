import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

 final _fireStore = Firestore.instance;
 FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {

  static const String id = 'chat_string';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final messageTextController = TextEditingController();
 
  final _auth = FirebaseAuth.instance;
  String messageText;
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }



  void getCurrentUser() async{
    try{
    final user = await _auth.currentUser();
    if(user != null){
      loggedInUser = user;
    }} catch(e){
      print(e);
    }
  }

  // void getMessages() async{
  
  //  final messages = await _fireStore.collection('messages').getDocuments();
  //  for (var message in messages.documents){
  //    print(message.data);
  //  }
  // }
  
  void messageStream() async{
    await for(var snapshot in _fireStore.collection('messages').snapshots() ){
      for(var message in snapshot.documents){
            print(message.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
                //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      // message text + loggedinuser.email
                      messageTextController.clear();
                      _fireStore.collection('messages').add({
                        'text': messageText, 
                        'Sender':loggedInUser.email,
                      });

                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(

              stream: _fireStore.collection('messages').snapshots(),
              builder: (context,snapshot){
                  if(!snapshot.hasData){

                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    );
                  }
                  {
                    final messages = snapshot.data.documents.reversed;
                    List<MessaggeBubble> messageBubbles = [];
                    for(var message in messages){
                      final messageText = message.data['text'];
                      final messageSender = message.data['Sender'];
                      
                      final currentUser = loggedInUser.email;

                      // if(currentUser==messageSender){

                      // }

                      final messaggeBubble = MessaggeBubble(sender: messageSender, text: messageText,
                      isMe: currentUser == messageSender,);
                      // Text('$messageText from $messageSender',
                      // style: TextStyle(
                      //   fontSize: 50.0,
                      // ),
                      // );
                      messageBubbles.add(messaggeBubble);
                    }
                    return Expanded(
                        child: ListView(
                          reverse: true,
                          padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
                        children: messageBubbles,
                      ),
                    );
                  }
                  


              },
              );
  }
}


class MessaggeBubble extends StatelessWidget {

  MessaggeBubble({this.sender, this.text, this.isMe});

  final String sender;
  final String text;
  final bool isMe;


  @override
  Widget build(BuildContext context) {
    return  Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Text(sender,
              style: TextStyle(
                fontSize:12.0,
                color: Colors.black54,
              ),),
              Material(
                borderRadius: isMe ? BorderRadius.only(topLeft: Radius.circular(30.0), 
                bottomLeft: Radius.circular(30.0), 
                bottomRight: Radius.circular(30.0)) : 
                BorderRadius.only(topRight: Radius.circular(30.0), 
                bottomLeft: Radius.circular(30.0), 
                bottomRight: Radius.circular(30.0))
                ,
                elevation: 5.0,
                color: isMe ? Colors.lightBlueAccent : Colors.white,
                child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                  child: Text(text ,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black54,
                                  fontSize:  15.0,
                                ),
                                ),
                ),
      ),
            ],
          ),
    );
  }
}
