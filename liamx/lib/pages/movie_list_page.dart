// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:liamx/pages/notification_page.dart';
import 'package:share_plus/share_plus.dart'; // For sharing functionality
import 'add_edit_movie_page.dart';
import 'next_page.dart'; // Import the new page
import 'shared_preferences.dart'; // Import the new page

const String baseUrl = 'http://192.168.0.23:3000'; // Base URL

class MovieListPage extends StatefulWidget {
  const MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  List<dynamic> movies = [];
  bool isLoading = true;

  Future<void> fetchMovies() async {
    const String apiUrl = '$baseUrl/movies';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          movies = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching movies: $e');
    }
  }

  Future<void> deleteMovie(int id) async {
    final String apiUrl = '$baseUrl/movies/$id';
    try {
      final response = await http.delete(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          movies.removeWhere((movie) => movie['id'] == id);
        });
      } else {
        throw Exception('Failed to delete movie');
      }
    } catch (e) {
      print('Error deleting movie: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies List'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Dismissible(
                  key: Key(movie['id'].toString()),
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.share, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Swipe right to share
                      Share.share(
                          'Check out this movie: ${movie['title']} directed by ${movie['director']}');
                      return false; // Prevent dismissal for sharing
                    } else if (direction == DismissDirection.endToStart) {
                      // Swipe left to delete
                      final confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: Text(
                              'Are you sure you want to delete "${movie['title']}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      return confirm == true;
                    }
                    return false;
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      deleteMovie(movie['id']);
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(
                        movie['title'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Director: ${movie['director']}'),
                          Text('Release Year: ${movie['releaseYear']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddEditMoviePage(movie: movie),
                            ),
                          ).then((value) {
                            if (value == true) {
                              fetchMovies();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addButton',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddEditMoviePage()),
              ).then((value) {
                if (value == true) {
                  fetchMovies();
                }
              });
            },
            tooltip: 'Add Movie',
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10), // Add spacing between buttons
          FloatingActionButton.extended(
            heroTag: 'nextButton', 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NextPage()),
              );
            },
            label: const Text('Next'),
          ),
          const SizedBox(width: 10), // Add spacing between buttons
          FloatingActionButton.extended(
            heroTag: 'storeButton', 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PreferencesPage()),
              );
            },
            label: const Text('Save'),
          ),
          const SizedBox(width: 10), // Add spacing between buttons
          FloatingActionButton.extended(
            heroTag: 'notifyButton', 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationPage()),
              );
            },
            label: const Text('Notify'),
          ),
        ],
      ),
    );
  }
}
