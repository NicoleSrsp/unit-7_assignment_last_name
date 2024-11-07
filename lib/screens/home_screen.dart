import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Function to fetch data from the API
  Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?f=a'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return jsonData['meals']; // Access the list of meals in the 'meals' key
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
      ),
      body: FutureBuilder(
        future: fetchData(),

        builder: (context, snapshot) {
          // Consider 3 cases here
          // When the process is ongoing
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          // Error case
          if (snapshot.hasError) {
            return Center(child: Text('Oh no! Error loading data ${snapshot.error}'));
          }
          // When the process is completed
          // successful
          if (snapshot.hasData && snapshot.data != null) {
            final meals = snapshot.data!;
          
            return ExpandedTileList.builder(
              itemCount: meals.length,
              itemBuilder: (context, index, controller) {
                final meal = meals[index];
                final name = meal['strMeal'] ?? 'Unknown';
                final category = meal['strCategory'] ?? 'No Category';
                final description = meal['strInstructions'] ?? 'No Instructions';
                final imageUrl = meal['strMealThumb'] ?? '';

                return ExpandedTile(
                  controller: controller,
                  title: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(imageUrl),
                        radius: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(category, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(description),
                  ),
                );
              },
            );
          } else {
            return Text('No data found');
          }
        },
      ),
    );
  }
}
