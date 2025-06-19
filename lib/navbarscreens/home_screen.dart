import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreenMap extends StatefulWidget {
  const HomeScreenMap({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<HomeScreenMap> {
  ScrollController _scrollController = ScrollController();

  late MapController mapController;
  List<LatLng> routePoints = [];
  bool isLoading = false;
  bool isExpanded = false;
  String? _selectedZoneName;
  bool _showBusDetails = false;

  // Station selection variables
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _zones = [];
  List<dynamic> _stations = [];
  List<dynamic> _endStations = [];
  String? _selectedStation;
  String? _selectedEndStation;
  String _busNumber = '';
  String _estimated_time = '';
  String? _start_station_id;

  // Dynamic points
  LatLng? selectedStartPoint;
  LatLng? selectedEndPoint;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    loadEndStations();
  }

  Future<void> searchZones(String query) async {
    try {
      final response = await http.get(
          Uri.parse('https://tech-bus-egy.vercel.app/zones/search/$query'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _zones = data['data'] ?? [];
        });
      } else {
        setState(() => _zones = []);
      }
    } catch (e) {
      print('Zone search error: $e');
      setState(() => _zones = []);
    }
  }

  Future<void> loadStations(int zoneId) async {
    try {
      final response = await http.get(
          Uri.parse('https://tech-bus-egy.vercel.app/stations/menu/$zoneId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _stations = data['data'] ?? [];
          _selectedStation = null;
          _busNumber = '';
          _estimated_time = '';
        });
      }
    } catch (e) {
      print('Load stations error: $e');
      setState(() => _stations = []);
    }
  }

  Future<void> loadEndStations() async {
    try {
      print("loading end stations id: $_start_station_id");
      final response = await http.get(Uri.parse(
          'https://tech-bus-egy.vercel.app/end-stations/menu/$_start_station_id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          _endStations = data['data'] ?? [];
          _selectedEndStation = null;
          _busNumber = '';
          _estimated_time = '';
        });
      }
    } catch (e) {
      print('Load end stations error: $e');
      setState(() => _endStations = []);
    }
  }

  Future<void> fetchBusNumbers() async {
    if (_selectedStation == null || _selectedEndStation == null) return;

    try {
      final response = await http.post(
        Uri.parse('https://tech-bus-egy.vercel.app/get-bus-numbers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'start_station': int.tryParse(_selectedStation!) ?? 0,
          'end_station': int.tryParse(_selectedEndStation!) ?? 0,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("data: $data");
        setState(() {
          _busNumber = (data['data'] is List && data['data'].isNotEmpty)
              ? ' ${data['data'][0]['number']}'
              : 'No buses available';
          _estimated_time = (data['data'] is List && data['data'].isNotEmpty)
              ? '${data['data'][0]['estimated_time']}'
              : 'unknown estimated time';
        });
      }
    } catch (e) {
      print('Fetch bus numbers error: $e');
      setState(() => _busNumber = 'Error loading buses');
    }
  }

  Future<void> fetchRoute() async {
    if (_selectedStation == null ||
        _selectedEndStation == null ||
        _stations.isEmpty ||
        _endStations.isEmpty) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final startStation = _stations.firstWhere(
        (s) => s['id'].toString() == _selectedStation,
        orElse: () => null,
      );

      final endStation = _endStations.firstWhere(
        (s) => s['id'].toString() == _selectedEndStation,
        orElse: () => null,
      );

      if (startStation == null || endStation == null) {
        setState(() => isLoading = false);
        return;
      }
      print(startStation);

      setState(() {
        selectedStartPoint = LatLng(startStation['lat']?.toDouble() ?? 0.0,
            startStation['long']?.toDouble() ?? 0.0);
        selectedEndPoint = LatLng(endStation['lat']?.toDouble() ?? 0.0,
            endStation['long']?.toDouble() ?? 0.0);
      });

      final String osrmUrl = 'https://router.project-osrm.org/route/v1/driving/'
          '${startStation['long']},${startStation['lat']};'
          '${endStation['long']},${endStation['lat']}?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(osrmUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coordinates = data['routes']?[0]?['geometry']?['coordinates'];

        if (coordinates is List && coordinates.isNotEmpty) {
          setState(() {
            routePoints = coordinates
                .map<LatLng>((coord) => LatLng(
                    (coord[1] as num).toDouble(), (coord[0] as num).toDouble()))
                .toList();
          });
        }
      }
    } catch (e) {
      print('Route fetch error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildPanelContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'From',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zone',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search zone',
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey.shade300),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.blue.shade400, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: Colors.grey.shade300,
                    ),
                    onChanged: searchZones,
                  ),
                  if (_zones.isNotEmpty)
                    SizedBox(
                      height: 180,
                      child: Container(
                        margin: EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          controller: _scrollController,
                          itemCount: _zones.length,
                          itemBuilder: (context, index) {
                            final zone = _zones[index];
                            return ListTile(
                              title: Text(zone['name']),
                              onTap: () async {
                                await loadStations(zone['id']);
                                print(zone['id']);
                                setState(() {
                                  _searchController.text = zone['name'];
                                  _selectedZoneName = zone['name'];
                                  _zones = [];
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Station',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedStation,
                    hint: Text('Select station'),
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    items: _stations.map((station) {
                      return DropdownMenuItem<String>(
                        value: station['id'].toString(),
                        child: Text(station['name']),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.blue.shade400, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      print('a $value');
                      setState(() {
                        _start_station_id = value;
                        _selectedStation = value;
                        _showBusDetails = false;
                      });
                      print('after updated: $_start_station_id');
                      loadEndStations();
                      final station = _stations.firstWhere(
                        (s) => s['id'].toString() == value,
                        orElse: () => null,
                      );
                      if (station != null) {
                        mapController.move(
                          LatLng(station['lat'], station['long']),
                          14.0,
                        );
                      }
                      fetchBusNumbers();
                      fetchRoute();
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Text('To',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Container(
            child: DropdownButtonFormField<String>(
              value: _selectedEndStation,
              hint: Text('Select destination'),
              dropdownColor: Colors.white,
              isExpanded: true,
              items: _endStations.map((station) {
                return DropdownMenuItem<String>(
                  value: station['id'].toString(),
                  child: Text(station['name']),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                   borderSide: BorderSide(color: Color(0xFF0F5A5F), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                print(value);
                setState(() {
                  _selectedEndStation = value;
                  _showBusDetails = false;
                });
                final endStation = _endStations.firstWhere(
                  (s) => s['id'].toString() == value,
                  orElse: () => null,
                );
                if (endStation != null) {
                  mapController.move(
                    LatLng(endStation['lat'], endStation['long']),
                    14.0,
                  );
                }
                fetchBusNumbers();
                fetchRoute();
              },
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() => _showBusDetails = true);
            },
            style: ElevatedButton.styleFrom(
              alignment: Alignment.center,
              backgroundColor: Color.fromARGB(255, 15, 90, 95),
              minimumSize: Size(double.infinity, 56),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Show Bus Details'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(),
            SizedBox(
              width: 8,
            ),
            Image.asset(
              'assets/images/Logo.png',
              width: 192,
              height: 50,
              fit: BoxFit.contain,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications_active_outlined,
                size: 26,
              ),
            )
          ],
        ),
        toolbarHeight: 80,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter:
                        LatLng(30.100703, 31.588865), // Default center
                    maxZoom: 30.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    if (routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            color: Colors.blue,
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (selectedStartPoint != null)
                          Marker(
                            point: selectedStartPoint!,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        if (selectedEndPoint != null)
                          Marker(
                            point: selectedEndPoint!,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 40,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                SlidingUpPanel(
                  minHeight: 250, // Collapsed height
                  maxHeight: 650, // Expanded height
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  panel: _buildPanelContent(),
                ),
                if (_showBusDetails && _busNumber.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(top: 16, left: 16, bottom: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Bus Details',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: IconButton(
                                        onPressed: () {
                                          setState(
                                              () => _showBusDetails = false);
                                        },
                                        icon: Icon(Icons.close, size: 20),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Bus Number',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Estimated Time',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Location',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on_outlined,
                                                  color: Colors.teal, size: 20),
                                              SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'From',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                  Text(
                                                    _selectedStation != null
                                                        ? _stations.firstWhere(
                                                            (station) =>
                                                                station['id']
                                                                    .toString() ==
                                                                _selectedStation)['name']
                                                        : 'Current Station',
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on_outlined,
                                                  color: Colors.teal, size: 20),
                                              SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'To',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                  Text(
                                                    _selectedEndStation != null
                                                        ? _endStations.firstWhere(
                                                            (station) =>
                                                                station['id']
                                                                    .toString() ==
                                                                _selectedEndStation)['name']
                                                        : 'Destination Station',
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.teal.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _busNumber,
                                              style: TextStyle(
                                                color: Colors.teal,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.teal.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _estimated_time,
                                              style: TextStyle(
                                                color: Colors.teal,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Image.asset(
                                            'assets/images/Bus.png',
                                            width: 128,
                                            height: 104,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (isLoading) Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}