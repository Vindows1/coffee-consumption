import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.brown,
    brightness: Brightness.light,
  ),
),
darkTheme: ThemeData(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.brown,
    brightness: Brightness.dark,
  ),
),
themeMode: ThemeMode.system,
      home: const MyHomePage(title:'Coffe Consumption counter'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Map<String, int> _dailyStats = {};
  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  void _incrementCounter() {
  setState(() {
    _counter++;
    final today = DateTime.now();
    final key = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    _dailyStats[key] = (_dailyStats[key] ?? 0) + 1;
  });
  _saveCounter();
}
  void _decremtCounter(){
    setState(() {
      if(_counter == 0){
        return;
      }
      _counter--;
      
    final today = DateTime.now();
    final key = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    _dailyStats[key] = (_dailyStats[key] ?? 0) -1;
    });
    _saveCounter();
  }
  void _resetCounter() {
    setState(() {
      _counter = 0;
    final today = DateTime.now();
    final key = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    _dailyStats[key]= 0;
    });
    _saveCounter();
  }
Future<void> _saveCounter() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('counter', _counter);
  prefs.setString('dailyStats', _dailyStats.entries.map((e) => "${e.key}:${e.value}").join(';'));
}

Future<void> _loadCounter() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _counter = prefs.getInt('counter') ?? 0;
    final statsString = prefs.getString('dailyStats');
    if (statsString != null && statsString.isNotEmpty) {
      _dailyStats = Map.fromEntries(
        statsString.split(';').where((e) => e.contains(':')).map((e) {
          final parts = e.split(':');
          return MapEntry(parts[0], int.tryParse(parts[1]) ?? 0);
        }),
      );
    }
  });
}
List<MapEntry<String, int>> _getLast7DaysStats() {
  final today = DateTime.now();
  return List.generate(7, (i) {
    final date = today.subtract(Duration(days: i));
    final key = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return MapEntry(key, _dailyStats[key] ?? 0);
  }).reversed.toList();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        titleSpacing: 0, 
        title: Text(widget.title, style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: Icon(Icons.history),
          tooltip: ('History'),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              showDragHandle: true,
              builder: (BuildContext context) {
                return Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Konsum-Historie (letzte 7 Tage)',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          children: _getLast7DaysStats()
                              .map((entry) => ListTile(
                                    title: Text(entry.key),
                                    trailing: Text('${entry.value}x'),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.coffee, size: 64,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'This is your Coffe consumption counter',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall
                ),
            ),
            const Text('You have drunk coffe this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton.large(
                onPressed: (){
                  HapticFeedback.mediumImpact();
                  _incrementCounter();
                },
                tooltip: "Increment",
                child: Icon(Icons.add),
                ),
            ),
            
        FloatingActionButton(
          onPressed:(){
            HapticFeedback.lightImpact();
            _decremtCounter();
            },
          tooltip: "minus",
          child: Icon(Icons.remove),
        ),
          ],
        ),
      ),  
    floatingActionButton: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          onPressed: () async {
            final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
            title: Text('Reset?'),
            content: Text('Do you want to reset the counter?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
              ],
            ),
          );
          if (confirm == true) _resetCounter();
        },
          tooltip: "reset",
          icon: Icon(Icons.refresh),
          label: const Text('Reset'),
        ),
        SizedBox(width: 16),
      ],
    ),
    );
  }
}