import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:SEEVIO/loading.dart';
import 'package:SEEVIO/result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

const SP_KEY_SETTINGS = "bubi";
bool loaded = false;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlutterTts flutterTts = FlutterTts();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SEEVIO',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(32, 235, 166, 1.0),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SeevioHome(
        flutterTts: flutterTts,
      ),
    );
  }
}

class SeevioHome extends StatefulWidget {
  SeevioHome({Key key, this.flutterTts}) : super(key: key);
  final FlutterTts flutterTts; // Text to Speech

  @override
  _SeevioHomeState createState() => _SeevioHomeState();
}

class _SeevioHomeState extends State<SeevioHome> {
  String locale = "ro-RO";
  Position position;
  int undeOAjunsLaTTSPentruPOI = 0; // :)

  Future<bool> getSettings() async {
    /// Get the seetings
    ///
    /// Returns [true] when done
    if (loaded) return true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String _settings = prefs.getString(SP_KEY_SETTINGS);
      List<String> settings = _settings.split("&");
      setState(() {
        locale = settings[0];
      });
    } catch (e) {
      setState(() {
        locale = "ro-RO";
      });
    }

    // Permissions
    await Permission.location.request();

    // TTS Setup:
    await widget.flutterTts.setLanguage(locale);
    await widget.flutterTts.setSpeechRate(1.5);
    await widget.flutterTts.setPitch(1.2);

    // Get location
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    await geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position pos) {
      setState(() {
        position = pos;
      });
    }).catchError((err) => print("[GEOLOC ERROR] $err"));

    loaded = true;

    return true;
  }

  Future<bool> setSettings() async {
    /// Save the seetings
    ///
    /// Returns [true] when done
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SP_KEY_SETTINGS, "$locale&");
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final double appWidth = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: getSettings(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            backgroundColor: Color.fromRGBO(4, 44, 84, 1.0),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/logo_back.png'),
                    height: MediaQuery.of(context).size.height * 0.18,
                    semanticLabel: "Seevio logo",
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: SizedBox(
                          width: appWidth * 0.45,
                          height: appWidth * 0.45,
                          child: RaisedButton(
                            elevation: 30,
                            color: Color.fromRGBO(32, 235, 166, 1.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            child: Text(
                              "Română",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 20, 20, 20),
                                  fontFamily: 'LibreFranklin',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 24),
                            ),
                            onPressed: () async {
                              await widget.flutterTts.setLanguage("ro-RO");
                              setState(() {
                                locale = "ro-RO";
                                setSettings();
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: SizedBox(
                          width: appWidth * 0.45,
                          height: appWidth * 0.45,
                          child: RaisedButton(
                            elevation: 30,
                            color: Color.fromRGBO(32, 235, 166, 1.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            child: Text(
                              "English",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 20, 20, 20),
                                  fontFamily: 'LibreFranklin',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 24),
                            ),
                            onPressed: () async {
                              await widget.flutterTts.setLanguage("en-US");
                              setState(() {
                                locale = "en-US";
                                setSettings();
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      width: appWidth * 0.65,
                      height: appWidth * 0.45,
                      child: RaisedButton(
                        elevation: 30,
                        color: Color.fromRGBO(32, 235, 166, 1.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                        child: Text(
                          locale == "ro-RO"
                              ? "Ce se află în jurul tău?"
                              : "What's around you?",
                          style: TextStyle(
                              color: Color.fromARGB(255, 20, 20, 20),
                              fontFamily: 'LibreFranklin',
                              fontWeight: FontWeight.w500,
                              fontSize: 20),
                        ),
                        onPressed: () async {
                          List<Result> results = await fetchNearbyPlaces(
                            position: position,
                            radious: 500,
                            keyword: "restaurant",
                          );

                          while (undeOAjunsLaTTSPentruPOI < results.length) {
                            await widget.flutterTts.awaitSpeakCompletion(true);
                            var res = await widget.flutterTts.speak(
                                results[undeOAjunsLaTTSPentruPOI]
                                    .toStringWithLocale(locale));
                            if (res == 1) {
                              ++undeOAjunsLaTTSPentruPOI;
                            }
                            if (undeOAjunsLaTTSPentruPOI == results.length) {
                              await widget.flutterTts.awaitSpeakCompletion(false);
                              undeOAjunsLaTTSPentruPOI = 0;
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: SizedBox(
                      width: appWidth * 0.65,
                      height: appWidth * 0.45,
                      child: RaisedButton(
                        elevation: 30,
                        color: Color.fromRGBO(32, 235, 166, 1.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                        child: Text(
                          locale == "ro-RO"
                              ? "Oprește Text to Speech"
                              : "Stop Text to Speech",
                          style: TextStyle(
                              color: Color.fromARGB(255, 20, 20, 20),
                              fontFamily: 'LibreFranklin',
                              fontWeight: FontWeight.w500,
                              fontSize: 20),
                        ),
                        onPressed: () async {
                          await widget.flutterTts.stop();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return LoadingScreen();
        }
      },
    );
  }
}
