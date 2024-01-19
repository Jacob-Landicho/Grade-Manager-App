import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Grade.dart';


class GradeFormPage extends StatefulWidget {
  final Function(Grade) onSave;
  final Grade? initialGrade;

  GradeFormPage({required this.onSave, this.initialGrade, Key? key});

  @override
  _GradeFormPageState createState() => _GradeFormPageState();
}

class _GradeFormPageState extends State<GradeFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController sidController;
  late TextEditingController gradeController;

  @override
  void initState() {
    super.initState();
    sidController = TextEditingController(text: widget.initialGrade?.sid ?? '');
    gradeController = TextEditingController(text: widget.initialGrade?.grade ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grade Form',
          style: TextStyle(
            color: Colors.white, // Set text color to white
            fontWeight: FontWeight.bold, // Make text bold
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: sidController,
              decoration: const InputDecoration(labelText: 'Student ID'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Student ID';
                }
                return null;
              },
            ),
            TextFormField(
              controller: gradeController,
              decoration: const InputDecoration(labelText: 'Grade'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Grade';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final newGrade = Grade(
              id: widget.initialGrade?.id, // Retain the existing ID
              sid: sidController.text,
              grade: gradeController.text,
            );

            widget.onSave(newGrade);
            Navigator.pop(context, newGrade); // Return the edited or new grade
          }
        },
        tooltip: 'Save',
        child: const Icon(Icons.save),
      ),
    );
  }

  @override
  void dispose() {
    sidController.dispose();
    gradeController.dispose();
    super.dispose();
  }
}
