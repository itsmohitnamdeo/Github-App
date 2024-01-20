import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> repositories = [];

  @override
  void initState() {
    super.initState();
    _fetchRepositories();
  }

  Future<void> _fetchRepositories() async {
    final response = await http.get(Uri.parse('https://api.github.com/users/freeCodeCamp/repos'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        repositories = List<Map<String, dynamic>>.from(data);
      });
      _fetchLastCommits();
    } else {
      throw Exception('Failed to load repositories');
    }
  }

  Future<void> _fetchLastCommits() async {
    for (var repo in repositories) {
      final response = await http.get(Uri.parse('https://api.github.com/repos/freeCodeCamp/${repo['name']}/commits'));
      if (response.statusCode == 200) {
        final List<dynamic> commits = json.decode(response.body);
        setState(() {
          repo['last_commit'] = commits.isNotEmpty ? commits[0]['commit']['message'] : 'No commits';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Explorer'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                repositories.clear();
              });
              _fetchRepositories();
            },
          ),
        ],
      ),
      body: _buildListView(),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: repositories.length,
      itemBuilder: (context, index) {
        final repo = repositories[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.all(8),
          child: ListTile(
            title: Text(
              repo['name'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(repo['description'] ?? 'No description available'),
                SizedBox(height: 8),
                Text('Last Commit: ${repo.containsKey('last_commit') ? repo['last_commit'] : 'Loading...'}'),
              ],
            ),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(repo['owner']['avatar_url']),
            ),
            onTap: () {
              // Add additional action on repository tap if needed
            },
          ),
        );
      },
    );
  }
}
