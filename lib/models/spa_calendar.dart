class SpaCalendar {
  final int id;
  final String username;
  final int serviceId;
  final String date;
  final String time;
  final String petName;
  final String petType;
  final String status;
  final String transportation;

  SpaCalendar({
    required this.id,
    required this.username,
    required this.serviceId,
    required this.date,
    required this.time,
    required this.petName,
    required this.petType,
    required this.status,
    required this.transportation,
  });

  factory SpaCalendar.fromMap(Map<String, dynamic> map) {
    return SpaCalendar(
      id: map['id'],
      username: map['username'],
      serviceId: map['service_id'],
      date: map['date'],
      time: map['time'],
      petName: map['pet_name'],
      petType: map['pet_type'],
      status: map['status'],
      transportation: map['transportation'],
    );
  }
}
