import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'locations.dart' as locations;


void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {

  late GoogleMapController mapController;

  final LatLng _center = const LatLng(35.303555, -80.73238);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DummyName'),
          backgroundColor: Colors.green[700],
        ),
        drawer: const NavigationDrawer(),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 17.0,

          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          tileOverlays: const <TileOverlay>{

          },
        ),
      ),
    );
  }
}

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {

  // 1 = heatmap, 2 = speed test, 3 = outages
  // currently not used until pages are completed
  // I think having back arrows that pop context will work the best
  // this will allow is to just pop context and not reload the map everytime

  int currentScreen = 1; //this will be the heatmap screen because it is always the first screen


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            drawerHeader(context),
            drawerContents(context),
          ],
        ),
      ),
    );
  }


  Widget drawerHeader(BuildContext context) {
    return(Container(
      color: Colors.green,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: 24
      ),
      child: Column( children: [
        Text("NinerFi", style: TextStyle(fontSize: 30),)
      ],)
      ,
    ));
  }

  Widget drawerContents(BuildContext context) {
    return(Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text("Heat Map"),
            onTap: () {
              if(currentScreen == 1) {
                Navigator.pop(context);
              }else {
                currentScreen = 1;
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const MyApp()));
              }
            },
          ),
          const Divider( thickness: 1, color: Colors.black,),
          ListTile(
            leading: const Icon(Icons.speed),
            title: const Text("Speed Test"),
            onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const dummyPage()));
            },
          ),
          const Divider( thickness: 1, color: Colors.black,),
          ListTile(
            leading: const Icon(Icons.wifi_off_outlined),
            title: const Text("Outages"),
            onTap: () {},
          ),
          const Divider( thickness: 1, color: Colors.black,)
        ],
      ),
    ));
  }

}

class dummyPage extends StatelessWidget {
  const dummyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dummy Page'),
          backgroundColor: Colors.green[700],
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
          ),
        );
  }
}

