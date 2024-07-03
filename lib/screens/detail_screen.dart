// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DetailScreen extends StatefulWidget {
  static const String routeName = "/detail";

  final Map<String, dynamic> item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailScreen> {
  final issuesBox = Hive.box('issues');
  final _formKey = GlobalKey<FormState>();
  String _newIssueTitle = "";
  String _newIssueDescription = "";
  List<Map<String, dynamic>> issues = [];

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  void _loadIssues() {
    final comicData = widget.item;
    final issuesKey = comicData["issuesKey"];
    if (issuesKey != null) {
      final retrievedIssues = issuesBox.get(issuesKey);
      if (retrievedIssues != null && retrievedIssues is List<dynamic>) {
        List<Map<String, String>> convertedIssues = [];
        for (var issue in retrievedIssues) {
          if (issue is Map<dynamic, dynamic>) {
            // Convert dynamic map to Map<String, String>
            Map<String, String> convertedIssue = {};
            issue.forEach((key, value) {
              convertedIssue[key.toString()] = value.toString();
            });
            convertedIssues.add(convertedIssue);
          }
        }
        setState(() {
          issues = convertedIssues;
          _sortIssues();
        });
      }
    }
  }

  void _sortIssues() {
    issues.sort((a, b) {
      return a["issue title"]!
          .toLowerCase()
          .compareTo(b["issue title"]!.toLowerCase());
    });
  }

  void _addNewIssue(String title, String description, [int? index]) {
    final newIssue = {
      "issue title": title,
      "issue description": description,
    };

    setState(() {
      if (index != null) {
        issues[index] = newIssue;
      } else {
        issues.add(newIssue);
      }
      _sortIssues();
    });

    final issuesKey = widget.item["issuesKey"];
    issuesBox.put(issuesKey, issues);

    // Print all issues after adding/updating the issue
    final keys = issuesBox.keys;
    for (var key in keys) {
      final issueList = issuesBox.get(key);
      if (issueList is List) {
        print('Issue Key: $key');
        for (var issue in issueList) {
          print('Issue Title: ${issue['issue title']}');
          print('Issue Description: ${issue['issue description']}');
        }
      }
    }
  }

  Future<void> _deleteIssue(int index) async {
    setState(() {
      issues.removeAt(index);
    });
    final issuesKey = widget.item["issuesKey"];
    issuesBox.put(issuesKey, issues);
    _deletedIssueMessage();
  }

  Future<void> _deletedIssueMessage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Quadrinho deletado da coleção."),
      ),
    );
  }

  void _showForm(BuildContext context,
      [Map<String, dynamic>? currentIssue, int? index]) {
    if (currentIssue != null) {
      _newIssueTitle = currentIssue["issue title"]!;
      _newIssueDescription = currentIssue["issue description"]!;
    } else {
      _newIssueTitle = "";
      _newIssueDescription = "";
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 10,
              left: 15,
              right: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _newIssueTitle,
                decoration: const InputDecoration(
                  labelText: "Título da edição",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, insira um título";
                  }
                  return null;
                },
                onSaved: (value) => setState(() => _newIssueTitle = value!),
              ),
              TextFormField(
                initialValue: _newIssueDescription,
                decoration: const InputDecoration(
                  labelText: "Descrição da edição",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, insira uma descrição";
                  }
                  return null;
                },
                onSaved: (value) =>
                    setState(() => _newIssueDescription = value!),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _addNewIssue(_newIssueTitle, _newIssueDescription, index);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Adicionar edição"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item["comic"] ?? "Detalhes",
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: issues.isEmpty
                  ? const Center(
                      child: Text(
                        "Nenhuma edição adicionada ainda.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: issues.length,
                      itemBuilder: (context, index) {
                        final currentIssue = issues[index];
                        return Card(
                          color: Colors.blue.shade100,
                          margin: const EdgeInsets.all(5),
                          elevation: 3,
                          child: ListTile(
                            title: Text(currentIssue["issue title"]!),
                            subtitle: Text(currentIssue["issue description"]!),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showForm(context, currentIssue, index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteIssue(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
