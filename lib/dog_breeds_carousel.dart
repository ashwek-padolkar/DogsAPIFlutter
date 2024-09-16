import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:cached_network_image/cached_network_image.dart';
import 'config.dart';

class DogBreedsCarousel extends StatefulWidget {
  const DogBreedsCarousel({Key? key}) : super(key: key);

  @override
  _DogBreedsCarouselState createState() => _DogBreedsCarouselState();
}

class _DogBreedsCarouselState extends State<DogBreedsCarousel> {
  final PageController _pageController = PageController(
    viewportFraction: 0.33, // Adjust fraction for visible cards
    initialPage: 1,
  );

  int _currentPage = 1;
  List<Map<String, String>> _dogBreeds = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchDogBreeds(); // Initial load of dog breeds
  }

  Future<void> fetchDogBreeds() async {
    String apiKey = Config.apiKey;
    String url =
        'https://api.thedogapi.com/v1/images/search?size=med&mime_types=jpg&format=json&has_breeds=true&order=RANDOM&page=0&limit=10';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-api-key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, String>> fetchedBreeds = data.map((item) {
          var breedInfo = item['breeds'].isNotEmpty ? item['breeds'][0] : {};
          return {
            'name': breedInfo['name'] ?? 'Unknown',
            'origin': breedInfo['origin'] ?? '-',
            'lifeSpan': breedInfo['life_span'] ?? 'Unknown',
            'temperament': breedInfo['temperament'] ?? 'Unknown',
            'bredFor': breedInfo['bred_for'] ?? 'Unknown',
            'image': item['url'], // Use the URL from the image
          }.map((key, value) => MapEntry(key, value.toString()));
        }).toList();

        setState(() {
          _dogBreeds.addAll(fetchedBreeds); // Append new data
          isLoading = false;
          isLoadingMore = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch data from API';
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _dogBreeds.length - 1) { // Ensure there are pages left
      _currentPage +=1;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 1) { // Ensure not on the first page
      _currentPage -=1;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadMoreBreeds() async {
    setState(() {
      isLoadingMore = true; // Show loading indicator for "Load More"
    });
    await fetchDogBreeds(); // Fetch more breeds and append them
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    } else {
      return Column(
        children: [
          const SizedBox(height: 20),
          // Container to center the row and set its width
          Container(
            width: MediaQuery.of(context).size.width * 0.789, // 78.9% width of the screen
            alignment: Alignment.center, // Align it at the center
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text at the start of the row
                const Text(
                  'Everyday is a dog day', // The text displayed below the carousel
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF727277), // Adjust as needed
                  ),
                ),
                // Arrow buttons at the end of the row
                Row(
                  children: [
                    // Left arrow button for previous group of 3 cards
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200], // Light grey background color
                        border: Border.all(
                          color: Colors.grey, // Border color
                          width: 1, // Border width
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: _currentPage > 1 ? _previousPage : null,
                        iconSize: 24, // Adjust icon size if needed
                        padding: EdgeInsets.zero, // Remove default padding
                        color: Colors.grey[600], // Icon color
                      ),
                    ),
                    const SizedBox(width: 8), // Space between buttons
                    // Right arrow button for next group of 3 cards
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200], // Light grey background color
                        border: Border.all(
                          color: Colors.grey, // Border color
                          width: 1, // Border width
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: _currentPage < _dogBreeds.length - 1 ? _nextPage : null,
                        iconSize: 24, // Adjust icon size if needed
                        padding: EdgeInsets.zero, // Remove default padding
                        color: Colors.grey[600], // Icon color
                      ),
                    ),
                  ],
                )

              ],
            ),
          ),
          const SizedBox(height: 10),
            SizedBox(
              height: 470, // Height of the carousel
              child: ClipRect( // Ensure that overflow is clipped
                child: Align(
                  alignment: Alignment.centerLeft, // Align the carousel to the left within the 88% width
                  child: Container(
                    margin: const EdgeInsets.only(left: 150), // Left margin of 10px
                    width: MediaQuery.of(context).size.width * 0.78, // 88% width of the screen
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _dogBreeds.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _buildCard(_dogBreeds[index]);
                      },
                    ),
                  ),
                ),
              ),
            ),


          const SizedBox(height: 20),
          // Load More button
          ElevatedButton(
            onPressed: (_currentPage >= _dogBreeds.length - 1 && !isLoadingMore)
                ? _loadMoreBreeds // Enable only if on the last group of items and not loading more
                : null, // Disable otherwise (button will be grayed out)
            child: isLoadingMore
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Load More'),
          ),
        ],
      );
    }
  }

  Widget _buildCard(Map<String, String?> breed) {
  final imageUrl = breed['image'] ?? '';

  return SizedBox(
  child: Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 10,
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image with rounded corners at the top
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          child: CachedNetworkImage(
            imageUrl: 'https://cors-anywhere.herokuapp.com/' + imageUrl,
            width: double.infinity,
            height: 250,
            fit: BoxFit.fill,
            placeholder: (context, url) => const SizedBox(
              width: 10, // Adjust width as needed
              height: 10, // Adjust height as needed
              child: CircularProgressIndicator(strokeWidth: 2), // strokeWidth controls the thickness
            ),
            errorWidget: (context, url, error) => const Placeholder(fallbackHeight: 250),
          ),
        ),
        const SizedBox(height: 10),
        // Content section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                breed['name'] ?? '-',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                breed['origin'] ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,  // Set fontWeight to bold for origin
                  color: Color.fromARGB(255, 122, 122, 122),
                ),
              ),
              const SizedBox(height: 5),  // Margin of 10px above lifeSpan text
              Text(
                breed['lifeSpan'] ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 122, 122, 122),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                breed['temperament'] ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 122, 122, 122),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                breed['bredFor'] ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 122, 122, 122),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    ),
  ),
);


}
}

