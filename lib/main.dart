//
//                       _oo0oo_
//                      o8888888o
//                      88" . "88
//                      (| -_- |)
//                      0\  =  /0
//                    ___/`---'\___
//                  .' \\|     |// '.
//                 / \\|||  :  |||// \
//                / _||||| -:- |||||- \
//               |   | \\\  -  /// |   |
//               | \_|  ''\---/''  |_/ |
//               \  .-\__  '-'  ___/-. /
//             ___'. .'  /--.--\  `. .'___
//          ."" '<  `.___\_<|>_/___.' >' "".
//         | | :  `- \`.;`\ _ /`;.`/ - ` : | |
//         \  \ `_.   \_ __\ /__ _/   .-` /  /
//     =====`-.____`.___ \_____/___.-`___.-'=====
//                       `=---='
//
//
//     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//               佛祖保佑         永无BUG
//
//
//
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'dart:math';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: 'Fishing game'),
    );
  }
}

jobList() {
  int count = 0;
  return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('fishing').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Something wrong!');
        if (snapshot.connectionState == ConnectionState.waiting)
          return Text('Loading...');
        return SizedBox(
          height: 200,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data = snapshot.data!.docs;
                return Dismissible(
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    FirebaseFirestore.instance
                        .collection('fishing')
                        .doc(data[index].id)
                        .delete();
                  },
                  key: Key(data[index].id),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                getJob(documentId: data[index].id)));
                      },
                      title: Text(data[index]['fish']),
                      subtitle: Text(data[index]['big']),
                      trailing: Wrap(
                        spacing: -16,
                        children: [
                          IconButton(
                            onPressed: () {
                              String jobId = data[index].id;
                              String jobName = data[index]['fish'];
                              String jobDesc = data[index]['big'];
                              count = index;
                              showDialog(
                                  context: context,
                                  builder: (context) => updateTaskAlertDialog(
                                        taskId: jobId,
                                        taskName: jobName,
                                        taskDesc: jobDesc,
                                      ));
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('fishing')
                                  .doc(data[index].id)
                                  .delete();
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        );
      });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CollectionReference jobs = FirebaseFirestore.instance.collection('fishing');
  final formKey = GlobalKey<FormState>();
  final jobController = TextEditingController();
  final jobDetailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              height: MediaQuery.of(context).size.height - 130,
              width: MediaQuery.of(context).size.width,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height - 130,
                            child: jobList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          SpeedDial(icon: Icons.star, backgroundColor: Colors.blue, children: [
        SpeedDialChild(
          child: const Icon(Icons.add, color: Colors.white),
          label: 'ADD',
          backgroundColor: Colors.blueAccent,
          onTap: () {
            showDialog(
                context: context, builder: (context) => AddTaskAlertDialog());
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.play_arrow, color: Colors.white),
          label: 'Play',
          backgroundColor: Colors.blueAccent,
          onTap: () async {
            while (true) {
              var fishNum = Random().nextInt(100);
              CollectionReference jobs =
                  FirebaseFirestore.instance.collection('fishing');
              QuerySnapshot querySnapshot =
                  await jobs.where('No', isEqualTo: fishNum).get();
              if (querySnapshot.size > 0) {
              }
            }
          },
        ),
      ]),
    );
  }
}

class Jobs extends StatefulWidget {
  const Jobs({Key? key}) : super(key: key);

  @override
  State<Jobs> createState() => _JobsState();
}

class _JobsState extends State<Jobs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('fish list')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: jobList(),
            ),
          ],
        ),
      ),
    );
  }
}

class getJob extends StatelessWidget {
  final String documentId;

  getJob({Key? key, required this.documentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference jobs = FirebaseFirestore.instance.collection('fishing');
    return Scaffold(
      appBar: AppBar(
        title: Text('fish details'),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder(
          future: jobs.doc(documentId).get(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text('Something wrong!');
            if (snapshot.hasData && !snapshot.data!.exists)
              return Text("Document doesn't exist!");
            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data1 =
                  snapshot.data!.data() as Map<String, dynamic>;
              return Center(
                child: Text(
                  "fish: ${data1['fish']} big:${data1['big']} No:${data1['No']}",
                  style: TextStyle(fontSize: 20),
                ),
              );
            }
            return Text('loading...');
          },
        ),
      ),
    );
  }
}

class AddTaskAlertDialog extends StatefulWidget {
  const AddTaskAlertDialog({Key? key}) : super(key: key);

  @override
  State<AddTaskAlertDialog> createState() => _AddTaskAlertDialogState();
}

class _AddTaskAlertDialogState extends State<AddTaskAlertDialog> {
  final jobController1 = TextEditingController();
  final jobDetailController1 = TextEditingController();
  final jobNumController1 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AlertDialog(
      scrollable: true,
      title: Text(
        'New fish',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.brown),
      ),
      content: SizedBox(
        height: height * 0.35,
        width: width,
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: jobController1,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  hintText: 'fish',
                  hintStyle: TextStyle(fontSize: 14),
                  icon: Icon(
                    Icons.square,
                    color: Colors.brown,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: jobDetailController1,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  hintText: 'big',
                  hintStyle: TextStyle(fontSize: 14),
                  icon: Icon(
                    Icons.bubble_chart_sharp,
                    color: Colors.brown,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: jobNumController1,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  hintText: 'number',
                  hintStyle: TextStyle(fontSize: 14),
                  icon: Icon(
                    Icons.add_circle,
                    color: Colors.brown,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final jobName = jobController1.text;
            final jobDesc = jobDetailController1.text;
            final jobNum = jobNumController1.text;
            addJobs(
                taskName: jobName,
                taskDesc: jobDesc,
                taskNum: int.parse(jobNum));
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
          child: Text('Save'),
        ),
      ],
    );
  }

  Future<void> addJobs(
      {required String taskName,
      required String taskDesc,
      required int taskNum}) async {
    await FirebaseFirestore.instance.collection('fishing').add({
      'No': taskNum,
      'fish': taskName,
      'big': taskDesc,
    });
    jobController1.text = '';
    jobDetailController1.text = '';
    jobNumController1.text = '';
  }
}

class updateTaskAlertDialog extends StatefulWidget {
  final String taskId, taskName, taskDesc;

  updateTaskAlertDialog({
    Key? key,
    required this.taskId,
    required this.taskName,
    required this.taskDesc,
  }) : super(key: key);

  @override
  State<updateTaskAlertDialog> createState() => _updateTaskAlertDialogState();
}

class _updateTaskAlertDialogState extends State<updateTaskAlertDialog> {
  final jobController2 = TextEditingController();
  final jobDetailController2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    jobController2.text = widget.taskName;
    jobDetailController2.text = widget.taskDesc;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AlertDialog(
      scrollable: true,
      title: Text(
        'Update Job',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.brown),
      ),
      content: SizedBox(
        height: height * 0.35,
        width: width,
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: jobController2,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  hintText: 'fish',
                  hintStyle: TextStyle(fontSize: 14),
                  icon: Icon(
                    Icons.square,
                    color: Colors.brown,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: jobDetailController2,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  hintText: 'big',
                  hintStyle: TextStyle(fontSize: 14),
                  icon: Icon(
                    Icons.bubble_chart_sharp,
                    color: Colors.brown,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final jobName = jobController2.text;
            final jobDesc = jobDetailController2.text;
            updateJobs(taskName: jobName, taskDesc: jobDesc);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
          child: Text('Update'),
        ),
      ],
    );
  }

  Future<void> updateJobs(
      {required String taskName, required String taskDesc}) async {
    await FirebaseFirestore.instance
        .collection('fishing')
        .doc(widget.taskId)
        .update({
          'fish': taskName,
          'big': taskDesc,
        })
        .then((_) => Fluttertoast.showToast(
            msg: 'Job updated successfully',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.SNACKBAR,
            backgroundColor: Colors.black38,
            textColor: Colors.white,
            fontSize: 14))
        .catchError((error) => Fluttertoast.showToast(
            msg: 'Failed: $error',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.SNACKBAR,
            backgroundColor: Colors.black38,
            textColor: Colors.white,
            fontSize: 14));
    jobController2.text = '';
    jobDetailController2.text = '';
  }
}
