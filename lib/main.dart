import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:seevio/loading.dart';
import 'package:seevio/result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

const SP_KEY_SETTINGS = "bubi";

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
      title: 'Seevio',
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
  final FlutterTts flutterTts;

  @override
  _SeevioHomeState createState() => _SeevioHomeState();
}

class _SeevioHomeState extends State<SeevioHome> {
  String locale = "ro-RO";

  Future<bool> getSettings() async {
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

    await widget.flutterTts.setLanguage(locale);
    await widget.flutterTts.setSpeechRate(1.5);
    await widget.flutterTts.setPitch(1.2);
    await widget.flutterTts.awaitSpeakCompletion(true);

    return true;
  }

  Future<bool> setSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SP_KEY_SETTINGS, "$locale&");
    return true;
  }

  _playT2S(List<Result> resultList) {
    print(resultList.length);
    for (int i = 0; i < resultList.length; ++i) {
      widget.flutterTts.speak(resultList[i].toStringWithLocale(locale));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getSettings(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "SEEVIO",
                style: TextStyle(
                  fontFamily: "LibreFranklin",
                ),
              ),
            ),
            body: Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RaisedButton(
                        child: Text("Romana"),
                        onPressed: () {
                          setState(() {
                            locale = "ro-RO";
                            setSettings();
                          });
                        },
                      ),
                      RaisedButton(
                        child: Text("English"),
                        onPressed: () {
                          setState(() {
                            locale = "en-US";
                            setSettings();
                          });
                        },
                      ),
                    ],
                  ),
                  RaisedButton(
                    child: Text(locale == "ro-US"
                        ? "Ce se afla in jurul tau?"
                        : "What's around you?"),
                    onPressed: () async {
                      List<Result> results = await fetchNearbyPlaces(
                        position: Position(
                          latitude: 46.774514,
                          longitude: 23.590110,
                        ),
                        radious: 500,
                        keyword: "bar",
                      );
                      _playT2S(results);
                    },
                  ),
                  RaisedButton(
                    child: const Text("Stop text to speech"),
                    onPressed: () async {
                      await widget.flutterTts.stop();
                    },
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
