import 'package:flutter/material.dart';
import '../../core/database_helper.dart';
import 'package:intl/intl.dart';

class SpaConfirm extends StatefulWidget {
  final int serviceId;
  final String petName;
  final String petType;

  const SpaConfirm({super.key, required this.serviceId, required this.petName, required this.petType});

  @override
  _SpaConfirmState createState() => _SpaConfirmState();
}

class _SpaConfirmState extends State<SpaConfirm> {
  final _databaseHelper = DatabaseHelper.instance;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _transportation = 'Self-drop-off';

  _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  _bookService() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time')),
      );
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    String formattedTime = _selectedTime!.format(context);

    Map<String, dynamic> booking = {
      'username': 'test_user', // Thay bằng username thực tế của người dùng
      'service_id': widget.serviceId,
      'date': formattedDate,
      'time': formattedTime,
      'pet_name': widget.petName,
      'pet_type': widget.petType,
      'status': 'Pending',
      'transportation': _transportation,
    };

    await _databaseHelper.insertBooking(booking);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking confirmed!')),
    );
    Navigator.pushReplacementNamed(context, '/booking_history');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Service: ${widget.serviceId}'),
            Text('Pet: ${widget.petName} (${widget.petType})'),
            ListTile(
              title: Text(_selectedDate == null ? 'Select Date' : 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            ListTile(
              title: Text(_selectedTime == null ? 'Select Time' : 'Selected Time: ${_selectedTime!.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),
            DropdownButton<String>(
              value: _transportation,
              onChanged: (String? newValue) {
                setState(() {
                  _transportation = newValue!;
                });
              },
              items: <String>[
                'Self-drop-off',
                'Pick-up by staff'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _bookService,
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
