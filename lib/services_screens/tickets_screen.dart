import 'package:busapp/shared/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:busapp/models/user_model.dart';

import 'dart:convert';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({Key? key}) : super(key: key);

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  bool _isLoading = false;

  List<Ticket> tickets = [];
  // static final String authToken = "Bearer $token";  (remove static)
  final String authToken = "Bearer $token"; //(New)

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final response = await http.get(
        Uri.parse('https://tech-bus-egy.vercel.app/mobile/invoice'),
        headers: {
          'Authorization': authToken,
          'Accept': 'application/json',
        },
      );
      // print('token: ${authToken}');
      print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          tickets = (jsonData['data'] as List)
              .map((item) => Ticket.fromJson(item))
              .toList();
        });
        print('Tickets length: ${tickets.length}');
      } else {
        throw Exception('Failed to load tickets');
      }
    } catch (e) {
      print('Error fetching tickets: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       backgroundColor: Colors.white,
  //       appBar: AppBar(
  //         backgroundColor: Colors.white,
  //         surfaceTintColor: Colors.white,
  //         title: Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Image.asset(
  //               'assets/images/Logo.png',
  //               width: 192,
  //               height: 50,
  //               fit: BoxFit.contain,
  //             ),
  //           ],
  //         ),
  //         elevation: 8,
  //         shadowColor: Colors.black.withOpacity(0.8),
  //         shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
  //         ),
  //         toolbarHeight: 80,
  //         iconTheme: const IconThemeData(color: Colors.black),
  //       ),
  //       body: Column(
  //         children: [
  //           Container(
  //             padding:
  //                 EdgeInsets.all(16), // This ensures the container has space
  //             width: double
  //                 .infinity, // Makes the container take up all available width
  //             height: 60,
  //             child: const Text(
  //               'My Tickets',
  //               style: TextStyle(
  //                 color: Colors.black,
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //           Container(
  //               color: Colors.white,
  //               padding: const EdgeInsets.all(16),
  //               child: _isLoading
  //                   ? const Center(child: CircularProgressIndicator())
  //                   : (tickets.isEmpty
  //                       ?
  //                       // hna aktby an mafy4 tickts ..
  //                       Center(child: Text('There is no tickets'))
  //                       : ListView.builder(
  //                           itemCount: tickets.length,
  //                           itemBuilder: (context, index) {
  //                             return TicketWidget(ticket: tickets[index]);
  //                             // return Container(
  //                             //     width: 100,
  //                             //     height: 100,
  //                             //     color: Colors.red,
  //                             //     child: Text("Asd ${tickets[index]} ${index}"));
  //                             // // )));
  //                           },
  //                         ))),
  //         ],
  //       ));
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Logo.png',
              width: 192,
              height: 50,
              fit: BoxFit.contain,
            ),
          ],
        ),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        toolbarHeight: 80,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16), // Padding for inner space
            width:
                double.infinity, // Make the container take all available width
            height: 60, // Set a fixed height
            child: const Text(
              'My Tickets',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (tickets.isEmpty
                      ? const Center(child: Text('There are no tickets'))
                      : ListView.builder(
                          itemCount: tickets.length,
                          itemBuilder: (context, index) {
                            return TicketWidget(ticket: tickets[index]);
                          },
                        )),
            ),
          ),
        ],
      ),
    );
  }
}

class TicketWidget extends StatelessWidget {
  final Ticket ticket;

  const TicketWidget({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Container(
            constraints: BoxConstraints(
              maxWidth: 400, // تحديد الحد الأقصى للعرض بـ 400 بكسل
            ),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/tic.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Printed on: ${ticket.date}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'time:${ticket.time}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price: ${ticket.payed} LE',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (ticket.bus.length > 0)
                            Text(
                              'Bus: ${ticket.bus[0].route.number}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Ticket {
  final int id;
  final String userId;
  final String ticketId;
  final String date;
  final String time;
  final double payed;
  final List<Bus> bus;

  Ticket({
    required this.id,
    required this.userId,
    required this.ticketId,
    required this.date,
    required this.time,
    required this.payed,
    required this.bus,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      userId: json['user_id'],
      ticketId: json['ticket_id'],
      date: json['date'],
      time: json['time'],
      payed: json['payed'].toDouble(),
      bus: (json['bus'] as List).map((item) => Bus.fromJson(item)).toList(),
    );
  }
}

class Bus {
  final String routeId;
  final Route route;

  Bus({required this.routeId, required this.route});

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      routeId: json['route_id'],
      route: Route.fromJson(json['route']),
    );
  }
}

class Route {
  final String customId;
  final String number;

  Route({required this.customId, required this.number});

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      customId: json['custom_id'],
      number: json['number'],
    );
  }
}
