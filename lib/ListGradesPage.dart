import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'Grade.dart';
import 'GradeFormPage.dart';
import 'GradeSearch.dart';


class ListGradesPage extends StatefulWidget {
  const ListGradesPage({Key? key});

  @override
  _ListGradesPageState createState() => _ListGradesPageState();
}




class _ListGradesPageState extends State<ListGradesPage> {
  RangeValues _gradeFilterRange = RangeValues(0, 100);
  late Database database;
  List<Grade> grades = [];
  List<Grade>? gradesOriginal; // Declare gradesOriginal
  int? selectedGradeId;
  TextEditingController searchController = TextEditingController();



  void _searchGrades(String query) {
    setState(() {
      if (gradesOriginal == null) {
        // If gradesOriginal is null, initialize it with the original list
        gradesOriginal = List<Grade>.from(grades);
      }

      if (query.isEmpty) {
        grades = List<Grade>.from(gradesOriginal!);
      } else {
        grades = gradesOriginal!
            .where((grade) =>
        grade.sid.toLowerCase().contains(query.toLowerCase()) ||
            grade.grade.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }






  void _filterGradesByRange() {
    setState(() {
      // If gradesOriginal is null, initialize it with the original list
      gradesOriginal ??= List<Grade>.from(grades);

      // Restore the original list of grades before filtering
      grades = List<Grade>.from(gradesOriginal!); // Create a copy of the original list

      // Filter grades based on the selected range
      grades = grades.where((grade) {

        if (_isNumeric(grade.grade)) {
          //int numericGrade = int.parse(grade.grade);
          int gradeValue = int.tryParse(grade.grade) ?? 0;
          return gradeValue >= _gradeFilterRange.start && gradeValue <= _gradeFilterRange.end;

        } else {
          int gradeValue = _mapLetterGradeToNumeric(grade.grade);
          return gradeValue >= _gradeFilterRange.start && gradeValue <= _gradeFilterRange.end;

        }



      }).toList();
    });
  }


// Updated method to show real-time range updates
  void _updateFilterRange(RangeValues values) {
    setState(() {
      _gradeFilterRange = values;
    });
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Filter by Grade Range'),
              content: Column(
                children: [
                  RangeSlider(
                    values: _gradeFilterRange,
                    min: 0,
                    max: 100,
                    onChanged: (RangeValues values) {
                      setState(() {
                        _updateFilterRange(values);
                      });
                    },
                  ),
                  Text(
                      'Selected Range: ${_gradeFilterRange.start.toInt()} - ${_gradeFilterRange.end.toInt()}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _filterGradesByRange();
                  },
                  child: Text('Filter'),
                ),
              ],
            );
          },
        );
      },
    );
  }






  void _showEditMenu(Grade grade, BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(0, 0, 0, 0),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              _editGrade(grade, context);
            },
          ),
        ),
      ],
    );
  }



  void _showSortMenu(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(0, 0, 0, 0),
      items: [
        PopupMenuItem(
          child: ListTile(
            title: Text('Sort by SID (Increasing)'),
            onTap: () {
              Navigator.pop(context);
              _sortGrades('sid', ascending: true);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: Text('Sort by SID (Decreasing)'),
            onTap: () {
              Navigator.pop(context);
              _sortGrades('sid', ascending: false);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: Text('Sort by Grade (Increasing)'),
            onTap: () {
              Navigator.pop(context);
              _sortGrades('grade', ascending: true);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: Text('Sort by Grade (Decreasing)'),
            onTap: () {
              Navigator.pop(context);
              _sortGrades('grade', ascending: false);
            },
          ),
        ),
      ],
    );
  }


  void _sortGrades(String sortBy, {bool ascending = true}) {
    setState(() {
      switch (sortBy) {
        case 'sid':
          grades.sort((a, b) {
            int sidA = int.tryParse(a.sid) ?? 0;
            int sidB = int.tryParse(b.sid) ?? 0;
            return ascending ? sidA.compareTo(sidB) : sidB.compareTo(sidA);
          });
          break;
        case 'grade':
          grades.sort((a, b) {
            int gradeA = _mapLetterGradeToNumeric(a.grade);
            int gradeB = _mapLetterGradeToNumeric(b.grade);

            if (_isNumeric(a.grade) && _isNumeric(b.grade)) {
              int numericGradeA = int.parse(a.grade);
              int numericGradeB = int.parse(b.grade);
              return ascending ? numericGradeA.compareTo(numericGradeB) : numericGradeB.compareTo(numericGradeA);
            } else {
              return ascending ? gradeA.compareTo(gradeB) : gradeB.compareTo(gradeA);
            }
          });
          break;
      }
    });
  }

  int _mapLetterGradeToNumeric(String letterGrade) {
    // You may need to adjust this mapping based on your grading system
    switch (letterGrade.toUpperCase()) {
      case 'A+':
        return 90;
      case 'A':
        return 85;
      case 'A-':
        return 80;
      case 'B+':
        return 77;
      case 'B':
        return 74;
      case 'B-':
        return 70;
      case 'C+':
        return 67;
      case 'C':
        return 64;
      case 'C-':
        return 60;
      case 'D+':
        return 57;
      case 'D':
        return 54;
      case 'D-':
        return 50;
      default:
        return 0;
    }
  }

  bool _isNumeric(String value) {
    if (value == null) {
      return false;
    }
    return double.tryParse(value) != null;
    //return double.tryParse(value) != null || int.tryParse(value) != null;

  }







  void _showChart(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Grade Distribution Chart'),
          content: Container(
            width: 300.0,
            height: 300.0,
            child: _buildChart(),
          ),
        );
      },
    );
  }

  Widget _buildChart() {
    var data = _generateChartData();
    var series = [
      charts.Series<Grade, String>(
        id: 'Grades',
        domainFn: (Grade grade, _) => grade.grade,
        measureFn: (Grade grade, _) => grades.where((g) => g.grade == grade.grade).length.toDouble(),
        data: data,
      ),
    ];

    return charts.BarChart(
      series,
      vertical: true,
    );
  }

  List<Grade> _generateChartData() {
    // Generate a list of unique grades
    List<String> uniqueGrades = grades.map((grade) => grade.grade).toSet().toList();

    // Create a list of Grade objects with frequency
    List<Grade> data = uniqueGrades.map((grade) {
      return Grade(sid: '', grade: grade, id: null); // Only grade and id matter for chart
    }).toList();

    return data;
  }








  void _showImportMenu(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(0, 0, 0, 0),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.file_upload),
            title: Text('Import CSV'),
            onTap: () async {
              Navigator.pop(context);
              await _importCSV();
            },
          ),
        ),
      ],
    );
  }


  Future<void> _importCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.isNotEmpty) {
        String csvText = await File(result.files.first.path!).readAsString();

        if (csvText.isNotEmpty) {
          List<List<dynamic>> csvList = CsvToListConverter().convert(csvText);

          // Skip the first row if it contains headers
          bool skipFirstRow = true;
          for (List<dynamic> row in csvList) {
            if (skipFirstRow) {
              skipFirstRow = false;
              continue;
            }

            if (row.length == 2) {
              String sid = row[0].toString();
              String grade = row[1].toString();
              Grade newGrade = Grade(sid: sid, grade: grade, id: null);
              await _addGrade(newGrade);
            }
          }

          updateGradesList();
        } else {
          print("File is null or empty");
        }
      } else {
        print("No file selected");
      }
    } catch (e) {
      print("Error importing CSV: $e");
    }
  }





  void _exportCSV() async {
    try {
      String csvData = _convertToCSV(grades);

      // Get the external storage directory
      Directory? externalDirectory = await getExternalStorageDirectory();

      if (externalDirectory != null) {
        String filePath = externalDirectory.path;
        String fileName = 'grades_export.csv'; // Set the desired file name
        File file = File('$filePath/$fileName');

        await file.writeAsString(csvData);

        print('CSV file exported to: ${file.path}');
      } else {
        print('Error getting external storage directory');
      }
    } catch (e) {
      print("Error exporting CSV: $e");
    }
  }




  String _convertToCSV(List<Grade> grades) {
    List<List<dynamic>> csvData = [
      ['Student ID', 'Grade']
    ];

    for (Grade grade in grades) {
      csvData.add([grade.sid, grade.grade]);
    }

    return ListToCsvConverter().convert(csvData);
  }




  @override
  void initState() {
    super.initState();
    initializeDatabase();
  }

  Future<void> initializeDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'grades_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE grades(id INTEGER PRIMARY KEY, sid TEXT, grade TEXT)',
        );
      },
      version: 1,
    );

    setState(() {
      updateGradesList();
    });
  }

  void updateGradesList() async {
    final List<Map<String, dynamic>> maps = await database.query('grades');
    setState(() {
      grades = List.generate(maps.length, (i) {
        return Grade(
          id: maps[i]['id'],
          sid: maps[i]['sid'],
          grade: maps[i]['grade'],
        );
      });
    });
  }

  Future<void> _addGrade(Grade grade) async {
    await database.insert('grades', grade.toMap());
    updateGradesList();
  }

  Future<void> _editGrade(Grade grade, BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GradeFormPage(
          onSave: _updateGrade,
          initialGrade: grade,
        ),
      ),
    );

    if (result != null) {
      // Check if result is not null
      final editedGrade = result as Grade; // Cast result to Grade

      if (editedGrade.id != null) {
        await _updateGrade(editedGrade);
      }
    }
    selectedGradeId = null;
    updateGradesList();
  }

  Future<void> _deleteGrade(Grade grade, BuildContext context) async {
    await database.delete('grades', where: 'id = ?', whereArgs: [grade.id]);
    selectedGradeId = null;
    updateGradesList();
  }

  Future<void> _updateGrade(Grade grade) async {
    await database.update('grades', grade.toMap(),
        where: 'id = ?', whereArgs: [grade.id]);
    updateGradesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Grades',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              _showSortMenu(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: () {
              _showChart(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: () {
              _showImportMenu(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              _exportCSV();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              String? query = await showSearch<String>(
                context: context,
                delegate: GradeSearchDelegate(grades),
              );

              if (query != null) {
                _searchGrades(query);
              }
            },
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: grades.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              _deleteGrade(grades[index], context);
            },
            background: Container(
              color: Colors.red,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            child: GestureDetector(
              onLongPress: () {
                _showEditMenu(grades[index], context);
              },
              child: ListTile(
                title: Text('Student ID: ${grades[index].sid}'),
                subtitle: Text('Grade: ${grades[index].grade}'),
                onTap: () {
                  setState(() {
                    selectedGradeId = grades[index].id;
                  });
                },
                tileColor: selectedGradeId == grades[index].id ? Colors.blue : null,
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GradeFormPage(onSave: _addGrade),
            ),
          );
        },
        tooltip: 'Add Grade',
        child: Icon(Icons.add),
      ),
    );
  }
}
