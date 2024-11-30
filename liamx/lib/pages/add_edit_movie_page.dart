// lib/pages/add_edit_movie_page.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AddEditMoviePage extends StatefulWidget {
  final Map<String, dynamic>? movie;

  const AddEditMoviePage({Key? key, this.movie}) : super(key: key);

  @override
  State<AddEditMoviePage> createState() => _AddEditMoviePageState();
}

class _AddEditMoviePageState extends State<AddEditMoviePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      _titleController.text = widget.movie!['title'];
      _directorController.text = widget.movie!['director'];
      _yearController.text = widget.movie!['releaseYear'].toString();
    }
  }

  Future<void> saveMovie() async {
    const String apiUrl = '$baseApiUrl/movies';
    final Map<String, dynamic> movieData = {
      'title': _titleController.text,
      'director': _directorController.text,
      'releaseYear': int.tryParse(_yearController.text) ?? 0,
    };

    try {
      http.Response response;
      if (widget.movie == null) {
        response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(movieData),
        );
      } else {
        final String updateUrl = '$apiUrl/${widget.movie!['id']}';
        response = await http.put(
          Uri.parse(updateUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(movieData),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to save movie');
      }
    } catch (e) {
      print('Error saving movie: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie == null ? 'Add Movie' : 'Edit Movie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _directorController,
                decoration: const InputDecoration(labelText: 'Director'),
                validator: (value) => value!.isEmpty ? 'Please enter a director' : null,
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Release Year'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter a release year' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveMovie();
                  }
                },
                child: Text(widget.movie == null ? 'Add Movie' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
