const express = require('express');
const fs = require('fs');
const app = express();
const cors = require('cors');
app.use(cors());

app.use(express.json()); // Middleware to parse JSON bodies

const filePath = './movies.json';

// Helper function to read data from JSON file
const readMovies = () => {
    const data = fs.readFileSync(filePath, 'utf-8');
    return JSON.parse(data);
  };


  // Helper function to write data to JSON file
const writeMovies = (data) => {
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf-8');
  };

// GET all movies
app.get('/movies', (req, res) => {
    const movies = readMovies();
    res.json(movies);
  });

// GET a movie by ID
app.get('/movies/:id', (req, res) => {
    const movies = readMovies();
    const movie = movies.find((m) => m.id === parseInt(req.params.id));
  
    if (!movie) return res.status(404).json({ message: 'Movie not found' });
  
    res.json(movie);
  });


// POST a new movie
app.post('/movies', (req, res) => {
    const movies = readMovies();
    const newMovie = {
      id: movies.length ? movies[movies.length - 1].id + 1 : 1,
      title: req.body.title,
      director: req.body.director,
      releaseYear: req.body.releaseYear,
    };

    console.log(req.body.title)
  
    if (!newMovie.title || !newMovie.director || !newMovie.releaseYear) {
        return res.status(400).json({ message: 'All fields are required' });
      }
  
    movies.push(newMovie);
    writeMovies(movies);
  
    res.status(201).json(newMovie);
  });

// PUT to update a movie
app.put('/movies/:id', (req, res) => {
    const movies = readMovies();
    const movieIndex = movies.findIndex((m) => m.id === parseInt(req.params.id));
  
    if (movieIndex === -1) return res.status(404).json({ message: 'Movie not found' });
  
    const updatedMovie = { ...movies[movieIndex], ...req.body };
    movies[movieIndex] = updatedMovie;
  
    writeMovies(movies);
    res.json(updatedMovie);
  });


  // DELETE a movie
app.delete('/movies/:id', (req, res) => {
    const movies = readMovies();
    const movieIndex = movies.findIndex((m) => m.id === parseInt(req.params.id));
  
    if (movieIndex === -1) return res.status(404).json({ message: 'Movie not found' });
  
    const deletedMovie = movies.splice(movieIndex, 1);
    writeMovies(movies);
  
    res.json(deletedMovie);
  });

// Start the server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});