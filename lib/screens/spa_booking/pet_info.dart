import 'package:flutter/material.dart';
import 'spa_confirm.dart';

class PetInfo extends StatefulWidget {
  final int serviceId;
  PetInfo({required this.serviceId});

  @override
  _PetInfoState createState() => _PetInfoState();
}

class _PetInfoState extends State<PetInfo> {
  final _petNameController = TextEditingController();
  String _petType = 'Dog';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pet Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _petNameController,
              decoration: InputDecoration(labelText: 'Pet Name'),
            ),
            DropdownButton<String>(
              value: _petType,
              onChanged: (String? newValue) {
                setState(() {
                  _petType = newValue!;
                });
              },
              items: <String>['Dog', 'Cat']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpaConfirm(
                      serviceId: widget.serviceId,
                      petName: _petNameController.text,
                      petType: _petType,
                    ),
                  ),
                );
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
