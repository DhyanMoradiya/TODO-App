import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/Databse/Database.dart';
import 'package:drift/drift.dart' as dr;
import 'package:intl/intl.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(

      create: (context)=>TaskDatabase(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TaskDatabase database;
  List<TaskData>? taskList;
  List<TaskData>? completedTaskList;
  final _formKey = GlobalKey<FormState>();
  final taskNameController = TextEditingController();
  DateTime? date;
  bool showCompletedTask = false;

  Future<List<TaskData>> getTaskList() async {
    return await database.getTaskList();
  }

  @override
  Widget build(BuildContext context) {
    database = Provider.of<TaskDatabase>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "TODO",
            style: TextStyle(
              fontWeight: FontWeight.w600
            ),
        ),
        actions: [
          Row(
            children: [
              Text(
                  "Completed Task :",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18
                ),
              ),
              SizedBox(
                height: 40,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Switch(
                      value: showCompletedTask,
                      onChanged: (value){
                        setState(() {
                          showCompletedTask = value;
                        });
                      },
                    activeColor: Colors.orange,
                    thumbColor: MaterialStateProperty.all(Colors.orange),
                    trackOutlineColor: MaterialStateProperty.all(Colors.orange.shade200),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          date = null;
          taskNameController.text = "";
          await showDialog(
              context: context,
              builder: (context)=>AlertDialog(
                title: Text(
                    "New Task",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.brown
                  ),
                ),
                content: StatefulBuilder(
                  builder: (context, setState) => Container(
                    height: 190,
                    width: MediaQuery.of(context).size.width - 50,
                    child: Form(
                      key: _formKey,
                      child: SizedBox(
                        height: 150,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 50,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  color: Colors.white,
                                ),
                                child: TextFormField(
                                  controller: taskNameController,
                                  decoration: InputDecoration(
                                    hintText: "Title",
                                  ),
                                  validator: (value) {
                                    if(value == null || value.isEmpty){
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Some Title';
                                      }
                                      return null;
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            InkWell(
                              onTap: () async {
                                date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate:  DateTime.now(),
                                    lastDate:  DateTime.now().add(Duration(days: 100 * 365)));
                                setState(() {});
                              },
                              child: Container(
                                height: 46,
                                padding: EdgeInsets.symmetric(horizontal: 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                date==null ? "Pick Date" : DateFormat.yMMMEd().format(date!),
                                  style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400
                              ),),
                                    Expanded(child: SizedBox()),
                                    Icon(Icons.calendar_month)
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 25,),
                            InkWell(
                                onTap: (){
                                  if(_formKey.currentState!.validate() && date!=null){
                                    database.addTask(TaskCompanion(
                                      taskName: dr.Value(taskNameController.text),
                                      date: dr.Value(date!)
                                    ));
                                    taskNameController.text = "";
                                    date = null;
                                    Navigator.pop(context);
                                  }
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.brown,
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Add",
                                      style: TextStyle(
                                        color: Colors.orangeAccent.shade100,
                                        fontSize: 17
                                      ),
                                    ),
                                  ),
                                )
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
          );
          setState(() {});
        },
        child: Icon(Icons.add),
      ),

      body: FutureBuilder(
          future: getTaskList(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              taskList = snapshot.data;
              if(taskList == null || taskList!.isEmpty){
                return Center(child : Text("No Task Found"));
              }else{
                completedTaskList = taskList!.where((element) => element.isCompleted).toList();
                if(showCompletedTask && completedTaskList!.isEmpty){
                  return Center(
                    child: Text(
                      "No Completed Task",
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  itemCount: showCompletedTask ? completedTaskList!.length : taskList!.length,
                    itemBuilder: (context, index){
                    TaskData taskData  = showCompletedTask ? completedTaskList![index] : taskList![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10,bottom: 10, right: 12, left: 25),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 60,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width : MediaQuery.of(context).size.width - 180,
                                        child: Text(
                                            taskData.taskName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                          DateFormat.yMMMEd().format(taskData.date),
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(child: SizedBox()),
                                Row(
                                  children: [
                                   !taskData.isCompleted ? IconButton(
                                        onPressed: () async {
                                          await database.updateTask(new TaskData(
                                              taskID: taskData.taskID, taskName: taskData.taskName, date: taskData.date, isCompleted: true)
                                          );
                                          setState(() { });
                                        },
                                       tooltip: "Completed",
                                        icon: Icon(
                                            Icons.check_rounded,
                                          color: Colors.green,
                                        )
                                    )
                        :SizedBox(),
                                    IconButton(
                                        onPressed: () async{
                                          await database.deleteTask(taskData);
                                          setState(() {});
                                        },
                                        tooltip: "remove",
                                        icon: Icon(
                                            Icons.delete,
                                          color: Colors.red,
                                        )
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                );
              }
            }else{
              return Center(child: CircularProgressIndicator(),);
            }
          }
      ),
    );
  }
}
