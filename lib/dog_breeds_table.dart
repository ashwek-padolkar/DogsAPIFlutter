import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For HTTP requests
import 'config.dart';

class DogBreedsTable extends StatefulWidget {
  const DogBreedsTable({Key? key}) : super(key: key);

  @override
  _DogBreedsTableState createState() => _DogBreedsTableState();
}

class _DogBreedsTableState extends State<DogBreedsTable> {
  Map<int, List<Map<String, String>>> cachedPages = {}; // Cache for pages
  List<Map<String, String>> dogBreeds = [];
  bool isLoading = true; // To show a loading indicator
  String? errorMessage;

  int currentPage = 0; // Track current page
  ScrollController _scrollController = ScrollController(); // ScrollController

  @override
  void initState() {
    super.initState();
    _loadPage(currentPage);
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose ScrollController
    super.dispose();
  }

  /// Load page from cache if available, otherwise fetch from API
  Future<void> _loadPage(int page) async {
    setState(() {
      isLoading = true;
    });

    // Check if the page is already cached
    if (cachedPages.containsKey(page)) {
      // If cached, load data from cache
      setState(() {
        dogBreeds = cachedPages[page]!;
        isLoading = false;
        errorMessage = null;
      });
    } else {
      // If not cached, fetch data from API
      await fetchDogBreeds(page);
    }
  }

  /// Fetch dog breeds data from API and cache it
  Future<void> fetchDogBreeds(int page) async {
    String apiKey = Config.apiKey;
    String url =
        'https://api.thedogapi.com/v1/images/search?size=med&mime_types=jpg&format=json&has_breeds=true&order=RANDOM&page=$page&limit=10';

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
            'breed': breedInfo['name'] ?? 'N/A',
            'bredFor': breedInfo['bred_for'] ?? 'N/A',
            'breedGroup': breedInfo['breed_group'] ?? 'N/A',
            'lifeSpan': breedInfo['life_span'] ?? 'N/A',
            'temperament': breedInfo['temperament'] ?? 'N/A',
            'origin': breedInfo['origin'] ?? 'N/A',
          }.map((key, value) =>
              MapEntry(key, value.toString())); // Cast values to String
        }).toList();

        // Cache the fetched data
        cachedPages[page] = fetchedBreeds;

        setState(() {
          dogBreeds = fetchedBreeds;
          isLoading = false; // Stop loading
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch data from API';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  /// Change the page when a user navigates
  void _changePage(int page) {
    setState(() {
      currentPage = page;
    });
    _loadPage(page); // Load page from cache or fetch from API
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
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                scrollDirection: Axis.vertical,
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.789,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFF0F0F0), // Border color
                            width: 1.8, // Border width
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller:
                              _scrollController, // Attach ScrollController
                          child: DataTable(
                            headingRowColor: WidgetStateColor.resolveWith(
                              (states) => const Color.fromARGB(255, 240, 245,
                                  250), // Header background color
                            ),
                            headingTextStyle: const TextStyle(
                              color: Colors.white, // Header text color
                              fontSize: 12.4, // Header font size
                              fontWeight: FontWeight.w700, // Header font weight
                            ),
                            dataRowColor: WidgetStateColor.resolveWith(
                              (states) => Colors.white, // Row background color
                            ),
                            columns: _buildColumns(),
                            rows: _buildRows(),
                            columnSpacing: 20, // Adjust column spacing
                            dataTextStyle: const TextStyle(
                              color: Color(0xFF464646), // Text color
                              fontSize: 12, // Font size
                            ),
                            border: const TableBorder(
                              horizontalInside: BorderSide(
                                color: Color(
                                    0xFFF0F0F0), // Border color between rows
                                width: 1.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 8), // Space between table and pagination
                      // Apply margin to pagination
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 20.0), // Apply right margin
                        child:
                            _buildPaginationControls(), // Pagination directly under the table
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  List<DataColumn> _buildColumns() {
    return const [
      DataColumn(
        label: Text(
          'Breed Name',
          style: TextStyle(
            color: Color(0xFF232323), // Text color (#232323)
            backgroundColor: Color.fromARGB(
                255, 255, 255, 255), // Background color (#F0F5FA)
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Bred For',
          style: TextStyle(
            color: Color(0xFF232323),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Breed Group',
          style: TextStyle(
            color: Color(0xFF232323),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Life Span',
          style: TextStyle(
            color: Color(0xFF232323),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Temperament',
          style: TextStyle(
            color: Color(0xFF232323),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Origin',
          style: TextStyle(
            color: Color(0xFF232323),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
    ];
  }

  List<DataRow> _buildRows() {
    return dogBreeds.map((breed) {
      return DataRow(
        cells: [
          DataCell(Container(
            width: 150, // Set width for 'Breed Name'
            child: Text(breed['breed']!),
          )),
          DataCell(Container(
            width: 200, // Set width for 'Bred For'
            child: Text(breed['bredFor']!),
          )),
          DataCell(Container(
            width: 130, // Set width for 'Breed Group'
            child: Text(breed['breedGroup']!),
          )),
          DataCell(Container(
            width: 130, // Set width for 'Life Span'
            child: Text(breed['lifeSpan']!),
          )),
          DataCell(Container(
            width: 300, // Set width for 'Temperament'
            child: Text(breed['temperament']!),
          )),
          DataCell(Container(
            width: 150, // Set width for 'Origin'
            child: Text(breed['origin']!),
          )),
        ],
      );
    }).toList();
  }

  /// Updated pagination controls to show 4 pages at a time
  /// Updated pagination controls with a right margin
  Widget _buildPaginationControls() {
    return Container(
      margin: const EdgeInsets.only(right: 118.0), // Add right margin
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed:
                currentPage > 0 ? () => _changePage(currentPage - 1) : null,
            icon: Icon(Icons.arrow_back_ios,
                color: currentPage > 0 ? Colors.black54 : Colors.grey),
            iconSize: 18,
          ),
          ...List.generate(4, (index) {
            int startPage = currentPage <= 2 ? 0 : currentPage - 2;
            int page = startPage + index;
            return Row(
              children: [
                ElevatedButton(
                  onPressed: () => _changePage(page),
                  style: ElevatedButton.styleFrom(
                    elevation: page == currentPage
                        ? 2
                        : 0, // No elevation for unselected buttons
                    backgroundColor: page == currentPage
                        ? const Color(0xFFE1E1E6)
                        : Colors.transparent,
                    foregroundColor:
                        page == currentPage ? Colors.black : Colors.black54,
                    padding: EdgeInsets.zero, // Remove default padding
                    minimumSize:
                        const Size(28, 28), // Consistent size for buttons
                    shape: page == currentPage
                        ? const CircleBorder() // Circular shape for the selected button
                        : const RoundedRectangleBorder(
                            side: BorderSide
                                .none), // No border or background for unselected buttons
                  ),
                  child: Text(
                    (page + 1).toString(),
                    style: const TextStyle(fontSize: 13.0),
                  ),
                ),
                const SizedBox(width: 10), // Adds spacing between buttons
              ],
            );
          }),
          IconButton(
            onPressed: () => _changePage(currentPage + 1),
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.black54),
            iconSize: 18,
          ),
        ],
      ),
    );
  }
}
