import 'package:flutter/material.dart';
import 'Grade.dart';



class GradeSearchDelegate extends SearchDelegate<String> {
  final List<Grade> grades;

  GradeSearchDelegate(this.grades);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Grade> searchResults = grades
        .where((grade) =>
    grade.sid.toLowerCase().contains(query.toLowerCase()) ||
        grade.grade.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Student ID: ${searchResults[index].sid}'),
          subtitle: Text('Grade: ${searchResults[index].grade}'),
          onTap: () {
            close(context, searchResults[index].sid);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Grade> searchResults = grades
        .where((grade) =>
    grade.sid.toLowerCase().contains(query.toLowerCase()) ||
        grade.grade.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Student ID: ${searchResults[index].sid}'),
          subtitle: Text('Grade: ${searchResults[index].grade}'),
          onTap: () {
            close(context, searchResults[index].sid);
          },
        );
      },
    );
  }
}