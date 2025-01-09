import 'package:database_notebook/data/local/db_helper.dart';
import 'package:flutter/material.dart';

class BottomSheetView extends StatefulWidget {
  final DBHelper dbRef; // Pass DBHelper instance
  final VoidCallback onNoteAdded; // Callback for refreshing notes
  final Map<String, dynamic>? existingNote; // Pass existing note for editing
  final bool isUpdate; // Indicates if it's an update or add operation

  const BottomSheetView({
    super.key,
    required this.dbRef,
    required this.onNoteAdded,
    this.existingNote,
    this.isUpdate = false,
  });

  @override
  State<BottomSheetView> createState() => _BottomSheetViewState();
}

class _BottomSheetViewState extends State<BottomSheetView> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  String errMsg = "";

  @override
  void initState() {
    super.initState();
    // Populate fields if editing
    if (widget.isUpdate && widget.existingNote != null) {
      print('Editing note: ${widget.existingNote}');
      titleController.text = widget.existingNote!['title'] ?? '';
      descController.text = widget.existingNote!['desc'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
      ),
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
            widget.isUpdate ? 'Edit Note' : 'Add Note', // Dynamic title
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
              hintText: 'Enter title here ',
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
              hintText: 'Enter description here ',
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
                    bool check;
                    if (widget.isUpdate) {
                      final sno = widget.existingNote?['sno'] ?? 0;
                      print("Attempting to update note...");
                      print("Title: $title, Desc: $desc, SNO: $sno");
                      check = await widget.dbRef.updateNote(
                        sno: sno,
                        title: title,
                        desc: desc,
                      );
                    } else {
                      check = await widget.dbRef.addNote(
                        title: title,
                        desc: desc,
                      );
                    }
                    if (check) {
                      widget.onNoteAdded(); // Refresh the notes list
                    }
                    Navigator.pop(context); // Close the modal
                  }
                },
                child: Text(widget.isUpdate ? 'Update' : 'Save'),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the modal
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
    );
  }
}
