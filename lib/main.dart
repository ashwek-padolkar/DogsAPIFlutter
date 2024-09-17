import 'package:flutter/material.dart';
import 'dog_breeds_table.dart';
import 'dog_breeds_carousel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  // TODO: implement key
  Key? get key => super.key;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog Breeds',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DogBreedsScreen(),
    );
  }
}

class DogBreedsScreen extends StatefulWidget {
  @override
  _DogBreedsScreenState createState() => _DogBreedsScreenState();
}

class _DogBreedsScreenState extends State<DogBreedsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(
          kToolbarHeight + 20), // Height of AppBar + top margin
      child: Container(
        margin: EdgeInsets.only(
          top: 40.0,
          left: screenWidth < 675 ? 20.0 : 146.0, // Adjust left margin based on screen size
        ),
        child: AppBar(
          title: Row(
            mainAxisAlignment: screenWidth < 675
                ? MainAxisAlignment.start // Move content to the left for smaller screens
                : MainAxisAlignment.start, // Keep it aligned as in your original code
            children: [
              const Text(
                'Dog Breeds',
                style: TextStyle(
                  fontSize: 25, // Adjust font size for the title
                  color: Color(0xFF464B64), // Title color
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth < 675 ? 8.0 : 20.0, // Adjust left margin for button
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Change tab to Table
                        _tabController.index = 0;
                      },
                      child: const Text('Table'),
                    ),
                  ),
                  const SizedBox(width: 8), // Space between buttons
                  ElevatedButton(
                    onPressed: () {
                      // Change tab to Carousel
                      _tabController.index = 1;
                    },
                    child: const Text('Carousel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    body: TabBarView(
      controller: _tabController,
      children: const [
        DogBreedsTable(),
        DogBreedsCarousel(),
      ],
    ),
  );
}

}
