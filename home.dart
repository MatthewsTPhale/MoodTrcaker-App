import 'package:flutter/material.dart';
import 'package:phale_mood/classes/database.dart';
import 'package:phale_mood/classes/journal.dart';
import 'package:phale_mood/classes/database_file_routines.dart';
import 'package:phale_mood/classes/journal_edit.dart';
import 'package:phale_mood/pages/edit_entry.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  // ignore: use_super_parameters
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Database _database;

  Future<List<Journal>> _loadJournals() async {
    try {
      String journalsJson = await DatabaseFileRoutine().readJournals();
      if (journalsJson.isNotEmpty) {
        _database = DatabaseFileRoutine().databaseFromJson(journalsJson);
        _database.journal
            .sort((comp1, comp2) => comp2.date.compareTo(comp1.date));
      } else {
        // Handle the case when the file is empty
        // ignore: avoid_print
        print("File is empty.");
        _database = Database(journal: []); // or initialize _database as needed
      }
    } catch (e) {
      // Handle other exceptions, e.g., unexpected format
      // ignore: avoid_print
      print("Error reading journals: $e");
      _database = Database(journal: []); // or handle the error as needed
    }
    return _database.journal;
  }

  void _addOrEditJournal(
      {required bool add, required int index, required Journal journal}) async {
    JournalEdit journalEdit = JournalEdit(action: '', journal: journal);
    journalEdit = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditEntry(
                add: add,
                index: index,
                journalEdit: journalEdit,
              ),
          fullscreenDialog: true),
    );
    switch (journalEdit.action) {
      case 'Save':
        if (add) {
          setState(() {
            _database.journal.add(journalEdit.journal);
          });
        } else {
          setState(() {
            _database.journal[index] = journalEdit.journal;
          });
        }
        DatabaseFileRoutine()
            .writeJournals(DatabaseFileRoutine().databaseToJson(_database));
        break;
      case 'Cancel':
        break;
      default:
        break;
    }
  }

  // Build the ListView with Separator
  Widget _buildListViewSeparated(AsyncSnapshot snapshot) {
    return ListView.separated(
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        var parsedDate = DateTime.parse(snapshot.data[index].date);
        String titleDate = DateFormat.yMMMd().format(parsedDate);
        String subtitle =
            snapshot.data[index].mood + "\n" + snapshot.data[index].note;
        return Dismissible(
          key: Key(snapshot.data[index].id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16.0),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16.0),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: ListTile(
            leading: Column(
              children: <Widget>[
                Text(
                  DateFormat.d()
                      .format(DateTime.parse(snapshot.data[index].date)),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                      color: Colors.blue),
                ),
                Text(DateFormat.E()
                    .format(DateTime.parse(snapshot.data[index].date))),
              ],
            ),
            title: Text(
              titleDate,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(subtitle),
            onTap: () {
              _addOrEditJournal(
                add: false,
                index: index,
                journal: snapshot.data[index],
              );
            },
          ),
          onDismissed: (direction) {
            setState(() {
              _database.journal.removeAt(index);
            });
            DatabaseFileRoutine()
                .writeJournals(DatabaseFileRoutine().databaseToJson(_database));
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          color: Colors.grey,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
      ),
      body: FutureBuilder(
        initialData: const [],
        future: _loadJournals(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return !snapshot.hasData
              ? const Center(child: CircularProgressIndicator())
              : _buildListViewSeparated(snapshot);
        },
      ),
      bottomNavigationBar: const BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: EdgeInsets.all(24.0),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Journal Entry',
        child: const Icon(Icons.add),
        onPressed: () {
          _addOrEditJournal(
            add: true,
            index: -1,
            journal: Journal(
              id: '',
              date: '',
              mood: '',
              note: '',
            ),
          );
        },
      ),
    );
  }
}
