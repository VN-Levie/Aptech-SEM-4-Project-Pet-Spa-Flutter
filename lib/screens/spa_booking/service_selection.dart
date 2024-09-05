import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';
import 'pet_info.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/drawer.dart';
import 'package:project/constants/Theme.dart';

class ServiceSelection extends StatefulWidget {
  final int categoryId;
  ServiceSelection({required this.categoryId});

  @override
  _ServiceSelectionState createState() => _ServiceSelectionState();
}

class _ServiceSelectionState extends State<ServiceSelection> {
  List<Map<String, dynamic>> _services = [];
  final _databaseHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  _loadServices() async {
    var services = await _databaseHelper.getSpaServices(widget.categoryId);
    setState(() {
      _services = services;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        title: "Select Service",
      ),
      backgroundColor: MaterialColors.bgColorScreen,
      // key: _scaffoldKey,
      drawer: const MaterialDrawer(currentPage: "booking_history"),
      body: ListView.builder(
        itemCount: _services.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_services[index]['name']),
            subtitle: Text(_services[index]['description']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetInfo(serviceId: _services[index]['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
