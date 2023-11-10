import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
part 'Database.g.dart';

class Task extends Table{
  IntColumn get taskID => integer().autoIncrement()();
  TextColumn get taskName => text()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(Constant(false))();
}


@DriftDatabase(tables : [Task])
class TaskDatabase extends _$TaskDatabase {
  TaskDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  addTask(TaskCompanion taskCompanion) async {
    await into(task).insert(taskCompanion);
  }

  Future<List<TaskData>> getTaskList() async {
    return await select(task).get();
  }

  updateTask(TaskData taskData) async {
    await update(task).replace(taskData);
  }

  deleteTask(TaskData taskData) async {
    await delete(task).delete(taskData);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
