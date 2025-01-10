import 'package:database_notebook/bottomSheetWidget.dart';
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

  void handleSave(String title, String desc, bool isUpdate, int sno) async {
    if (title.isEmpty || desc.isEmpty) {
      setState(() {
        errMsg = "Please fill all the required fields.";
      });
    } else {
      bool check = isUpdate
          ? await dbRef!.updateNote(title: title, desc: desc, sno: sno)
          : await dbRef!.addNote(title: title, desc: desc);
      if (check) {
        getNotes();
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
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
                        icon: const FaIcon(
                          FontAwesomeIcons.pen,
                          size: 16,
                        ),
                        onPressed: () {
                          // Handle edit action
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: const Color(0xFFB2DFDB),
                            isScrollControlled: true,
                            // Allows full-screen height control
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(30.0),
                              ),
                            ),
                            builder: (context) {
                              titleController.text =
                                  allNotes[index][DBHelper.COLUMN_TITLE];
                              descController.text =
                                  allNotes[index][DBHelper.COLUMN_DESC];
                              return BottomSheetView(
                                isUpdate: true,
                                sno: allNotes[index][DBHelper.COLUMN_SNO],
                                titleController: titleController,
                                descController: descController,
                                errMsg: errMsg,
                                onSave: handleSave,
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const FaIcon(
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
          : const Center(
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
            backgroundColor: const Color(0xFFB2DFDB),
            isScrollControlled: true,
            // Allows full-screen height control
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30.0),
              ),
            ),
            builder: (context) {
              return BottomSheetView(
                isUpdate: false,
                sno: 0,
                titleController: titleController,
                descController: descController,
                errMsg: errMsg,
                onSave: handleSave,
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
