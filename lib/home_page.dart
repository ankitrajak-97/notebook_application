import 'package:database_notebook/data/local/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // controllers
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  String errMsg = "";
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
    getNotes();
  }

  Future<void> getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      // all notes is visible here
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text((index + 1).toString()),
                  ),
                  title: Text(
                    allNotes[index][DBHelper.COLUMN_TITLE],
                  ),
                  subtitle: Text(
                    allNotes[index][DBHelper.COLUMN_DESC],
                    // maxLines: 2,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.pen,
                          size: 16,
                        ),
                        onPressed: () {
                          // Handle edit action
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Color(0xFFB2DFDB),
                            isScrollControlled: true,
                            // Allows full-screen height control
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(30.0),
                              ),
                            ),
                            builder: (context) {
                              titleController.text =
                                  allNotes[index][DBHelper.COLUMN_TITLE];
                              descController.text =
                                  allNotes[index][DBHelper.COLUMN_DESC];
                              return bottomSheetView(
                                  isUpdate: true,
                                  sno: allNotes[index][DBHelper.COLUMN_SNO]
                                  // dbRef: dbRef!, onNoteAdded: getNotes,
                                  // isUpdate: true, // Edit mode
                                  // existingNote: note,
                                  );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.trash,
                          size: 16,
                        ),
                        onPressed: () async {
                          // Handle delete action
                          bool check = await dbRef!.deleteNote(
                              sno: allNotes[index][DBHelper.COLUMN_SNO]);
                          if (check) {
                            getNotes();
                          }
                        },
                      ),
                    ],
                  ),
                );
              })
          : Center(
              child: Text("No any notes yet !!!! "),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Reset text fields and error message when the modal is opened
          titleController.clear();
          descController.clear();
          setState(() {
            errMsg = ""; // Clear any previous error messages
          });

          showModalBottomSheet(
            context: context,
            backgroundColor: Color(0xFFB2DFDB),
            isScrollControlled: true,
            // Allows full-screen height control
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30.0),
              ),
            ),
            builder: (context) {
              return bottomSheetView(
                  // dbRef: dbRef!,
                  // isUpdate: false,
                  // onNoteAdded: getNotes,
                  );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget bottomSheetView({bool isUpdate = false, int sno = 0}) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              isUpdate ? 'Edit Note' : 'Add Note',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter title here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description *',
                hintText: 'Enter description here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    var title = titleController.text.trim();
                    var desc = descController.text.trim();

                    if (title.isEmpty || desc.isEmpty) {
                      setState(() {
                        errMsg = "Please fill all the required fields.";
                      });
                    } else {
                      bool check = isUpdate
                          ? await dbRef!
                              .updateNote(title: title, desc: desc, sno: sno)
                          : await dbRef!.addNote(
                              title: title,
                              desc: desc,
                            );
                      if (check) {
                        getNotes();
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isUpdate ? 'Edit' : 'Save'),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
            if (errMsg.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errMsg,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
