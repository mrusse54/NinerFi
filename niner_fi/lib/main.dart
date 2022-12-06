import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_speedtest/flutter_speedtest.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;


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
    const WeightedLatLng(LatLng(35.3062, -80.7290)),





  ];
  //const WeightedLatLng(LatLng(35.30856378061255, -80.73375852431093)),
  //     const WeightedLatLng(LatLng(35.307574632463066, -80.73406612933738)),
  //     const WeightedLatLng(LatLng(35.30832190988692, -80.73532016506068)),
  //     const WeightedLatLng(LatLng(35.3075169529927, -80.73539086425971)),

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
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const outagePage()));
            },
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
  bool _inprogress = false;



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
              if (!_inprogress) ...{
                ElevatedButton(
                  onPressed: () {
                    _inprogress = true;
                     _progressDownload = 0;
                     _progressUpload = 0;
                     _ping = 0;

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
                      onDone: () => _inprogress = false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green
                  ),
                  child: const Text('Begin Test'),

                ),
              } else ...{
                const CircularProgressIndicator()
            }
            ],
          ),
        ),
      ),
    );
  }
}

class outagePage extends StatefulWidget {
  const outagePage({Key? key}) : super(key: key);

  @override
  State<outagePage> createState() => _outagePageState();
}

class _outagePageState extends State<outagePage> {

  String outageStatus = 'Press "Check Status" to view WIFI status';
  bool isLoading = false;

  void initState(){
    super.initState();
    getWebsiteData();
  }

  Future getWebsiteData() async {
    final response = await http.Client().get(Uri.parse("https://systemstatus.charlotte.edu/content/wi-fi"));
    if(response.statusCode == 200){
      var document = parser.parse(response.body);
      try {
        var responseString = document.getElementsByClassName("view-empty")[0]
            .children[0];

        print(responseString.text.trim());

        return responseString.text.trim();

      } catch (e) {
        return ['', '', 'ERROR: ${response.statusCode}.'];
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
        appBar: AppBar(
        title: const Text('Outages'),
    backgroundColor: Colors.green[700],
    leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () => Navigator.pop(context),
    ),
    ),
    body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // if isLoading is true show loader
            // else show Column of Texts
            isLoading
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      Text(outageStatus,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            MaterialButton(
             onPressed: () async {

              // Setting isLoading true to show the loader
                setState(() {
                  isLoading = true;
                });

                // Awaiting for web scraping function
                // to return list of
                // await causes the subsequent code to wait for the method

                final response = await getWebsiteData();
                // Setting the received strings to be
                // displayed and making isLoading false
                // to hide the loader

                if(response == "There are no active alerts at this time."){
                  setState(() {
                    outageStatus = response;
                    isLoading = false;
                  });
                } else {
                  setState(() {
                    outageStatus = "There is currently an outage on campus.";
                    isLoading = false;
                  });
                }


              },
              child: Text(
                'Check Status',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.green,
            )
          ],
        )),
      ),
    )
    );


  }
}

