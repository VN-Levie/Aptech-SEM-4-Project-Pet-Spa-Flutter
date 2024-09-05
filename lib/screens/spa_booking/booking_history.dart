import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import để lưu và lấy thông tin người dùng
import 'package:intl/intl.dart';
import '../../core/database/database_helper.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/drawer.dart';
import 'package:project/constants/Theme.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  _BookingHistoryScreenState createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final _databaseHelper = DatabaseHelper.instance;
  String _username = "test_user"; // Giá trị mặc định nếu không có người dùng
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadBookings();
  }

  Future<void> _loadUsername() async {
    // Giả sử chúng ta lưu tên người dùng trong SharedPreferences hoặc lấy từ cơ sở dữ liệu
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');

    setState(() {
      // Nếu tên người dùng là null hoặc rỗng, thì sử dụng giá trị mặc định "a"
      _username = storedUsername?.isNotEmpty == true ? storedUsername! : "a";
    });

    // Sau khi lấy tên người dùng, tải lại các lịch đã đặt
    _loadBookings();
  }

  _loadBookings() async {
    // var bookings = await _databaseHelper.getUserBookings(_username);
    var bookings = await _databaseHelper.getBookings();
    setState(() {
      _bookings = bookings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        title: "Booking History",
      ),
      backgroundColor: MaterialColors.bgColorScreen,
      // key: _scaffoldKey,
      drawer: const MaterialDrawer(currentPage: "booking_history"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  var booking = _bookings[index];
                  return Card(
                    child: ListTile(
                      title: Text('Service: ${booking['service_id']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${booking['date']}'),
                          Text('Time: ${booking['time']}'),
                          Text('Pet: ${booking['pet_name']} (${booking['pet_type']})'),
                          Text('Status: ${booking['status']}'),
                          Text('Transportation: ${booking['transportation']}'),
                          Text('User: ${booking['username']} | $_username'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildCalendar(), // Bộ lịch bên dưới
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            'Booked Dates',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDateGrid(),
        ],
      ),
    );
  }

  Widget _buildDateGrid() {
    List<String> bookedDates = _bookings.map((booking) => booking['date'] as String).toList();

    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.5,
      ),
      itemCount: DateTime.daysPerWeek * 6, // 6 tuần
      itemBuilder: (context, index) {
        final DateTime currentDate = DateTime.now().add(Duration(days: index));
        final String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

        bool isBooked = bookedDates.contains(formattedDate);

        return InkWell(
          onTap: isBooked
              ? () {
                  var booking = _bookings.firstWhere((booking) => booking['date'] == formattedDate);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Booking Details'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${booking['date']}'),
                            Text('Time: ${booking['time']}'),
                            Text('Service: ${booking['service_id']}'),
                            Text('Pet: ${booking['pet_name']} (${booking['pet_type']})'),
                            Text('Status: ${booking['status']}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                }
              : null,
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isBooked ? Colors.green : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey),
            ),
            alignment: Alignment.center,
            child: Text(
              DateFormat('d').format(currentDate),
              style: TextStyle(
                color: isBooked ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
