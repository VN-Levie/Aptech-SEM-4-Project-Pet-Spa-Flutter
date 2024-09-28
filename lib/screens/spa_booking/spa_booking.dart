import 'package:flutter/material.dart';
import 'service_selection.dart';
import '../../core/database_helper.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/drawer.dart';
import 'package:project/constants/Theme.dart';
class SpaBooking extends StatefulWidget {
  const SpaBooking({super.key});

  @override
  _SpaBookingState createState() => _SpaBookingState();
}

class _SpaBookingState extends State<SpaBooking> {
  List<Map<String, dynamic>> _categories = [];
  final _databaseHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  _loadCategories() async {
    var categories = await _databaseHelper.getSpaCategories();
    setState(() {
      _categories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(     
      appBar: Navbar(
        title: "Spa Booking",
      ),
      backgroundColor: MaterialColors.bgColorScreen,
      // key: _scaffoldKey,
      drawer: const MaterialDrawer(currentPage: "booking"),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_categories[index]['name']),
            subtitle: Text(_categories[index]['description']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceSelection(categoryId: _categories[index]['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
