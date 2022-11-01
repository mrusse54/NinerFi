import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_speedtest/flutter_speedtest.dart';


void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {

  late GoogleMapController mapController;

  final LatLng _center = const LatLng(35.303555, -80.73238);


  List<WeightedLatLng> enabledPoints = <WeightedLatLng>[
    const WeightedLatLng(LatLng(35.30856378061255, -80.73375852431093)),
  ];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('NinerFi'),
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
            heatmaps: <Heatmap>{
              Heatmap(
                heatmapId: const HeatmapId('test'),
                data: enabledPoints,
                gradient: HeatmapGradient(
                  const <HeatmapGradientColor>[
                    // Web needs a first color with 0 alpha
                    if (kIsWeb)
                      HeatmapGradientColor(
                        Color.fromARGB(0, 0, 255, 255),
                        0,
                      ),
                    HeatmapGradientColor(
                      Color.fromARGB(255, 0, 255, 255),
                      0.2,
                    ),
                    HeatmapGradientColor(
                      Color.fromARGB(255, 0, 63, 255),
                      0.4,
                    ),
                    HeatmapGradientColor(
                      Color.fromARGB(255, 0, 0, 191),
                      0.6,
                    ),
                    HeatmapGradientColor(
                      Color.fromARGB(255, 63, 0, 91),
                      0.8,
                    ),
                    HeatmapGradientColor(
                      Color.fromARGB(255, 255, 0, 0),
                      1,
                    ),
                  ],
                ),
                maxIntensity: 1,
                // Radius behaves differently on web and Android/iOS.
                radius: kIsWeb
                    ? 10
                    : defaultTargetPlatform == TargetPlatform.android
                    ? 20
                    : 40,
              )
            }
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
                    MaterialPageRoute(builder: (context) => const speedTestPage()));
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


class speedTestPage extends StatefulWidget {
  const speedTestPage({Key? key}) : super(key: key);

  @override
  State<speedTestPage> createState() => _speedTestPageState();
}

class _speedTestPageState extends State<speedTestPage> {

  final _speedtest = FlutterSpeedtest(
    baseUrl: 'https://speedtest.openfiberusa.com:8080/speedtest/upload.php',
    pathDownload: '/download',
    pathUpload: '/upload',
    pathResponseTime: '/ping',
  );

  double _progressDownload = 0;
  double _progressUpload = 0;

  int _ping = 0;
  int _jitter = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Speed Test'),
          backgroundColor: Colors.green[700],
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          alignment: Alignment.center,
         padding: EdgeInsets.only(top: 150.0),
          child: Column(
            children: [
              Text('Download: $_progressDownload mbps',style: TextStyle(fontSize: 20)),
              SizedBox(height: 7),
              Text('upload: $_progressUpload mbps',style: TextStyle(fontSize: 20)),
              SizedBox(height: 7),
              Text('Ping: $_ping',style: TextStyle(fontSize: 20)),
              SizedBox(height: 7),
              ElevatedButton(
                onPressed: () {
                  _speedtest.getDataspeedtest(
                    downloadOnProgress: ((percent, transferRate) {
                      setState(() {
                        _progressDownload = transferRate.roundToDouble();
                      });
                    }),
                    uploadOnProgress: ((percent, transferRate) {
                      setState(() {
                        _progressUpload = transferRate.roundToDouble();
                      });
                    }),
                    progressResponse: ((responseTime, jitter) {
                      setState(() {
                        _ping = responseTime;
                        _jitter = jitter;
                      });
                    }),
                    onError: ((errorMessage) {

                    }),
                    onDone: () => debugPrint('done'),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green
                ),
                child: const Text('Speed Test'),
              ),
            ],

          ),
        ),
      ),
    );
  }
}


