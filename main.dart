import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(MyApp());
}

class UserTime {
  final String userName;
  final String time;

  UserTime(this.userName, this.time);
}

List<UserTime> _userTimes = [];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'STOPWATCH',
          style: TextStyle(fontSize:35, fontWeight: FontWeight.bold,color: Color.fromARGB(255, 4, 47, 82),),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Enter your name'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimerScreen(userName: _nameController.text),
                    ),
                  );
                },
                child: Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimerScreen extends StatefulWidget {
  final String userName;

  TimerScreen({required this.userName});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  bool _isRunning = false;
  late Stopwatch _stopwatch;
  String _formattedTime = '00:00:00';
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _ticker = Ticker(_updateTime);
  }

  void _toggleTimer() {
    if (_isRunning) {
      _stopwatch.stop();
      _ticker.stop();
    } else {
      _stopwatch.start();
      _ticker.start();
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _saveAndNavigateToDataTable() {
    if (!_isRunning && _formattedTime != '00:00:00') {
      _userTimes.add(UserTime(widget.userName, _formattedTime));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DataTableScreen(
            userTimes: _userTimes,
            navigateToHome: _navigateToHomeScreen,
          ),
        ),
      );
    }
  }

  void _navigateToHomeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void _updateTime(Duration duration) {
    setState(() {
      _formattedTime = _formatTime(duration);
    });
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    String milliseconds = twoDigits(duration.inMilliseconds.remainder(1000) ~/ 10);
    return '$minutes:$seconds:$milliseconds';
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Timer')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hello, ${widget.userName}!'),
              SizedBox(height: 20),
              Text(
                _formattedTime,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _formattedTime == '00:00:00'
                    ? _toggleTimer
                    : (_isRunning ? _toggleTimer : _saveAndNavigateToDataTable),
                child: Text(_isRunning ? 'Stop' : (_formattedTime == '00:00:00' ? 'Start' : 'Save')),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class DataTableScreen extends StatelessWidget {
  final List<UserTime> userTimes;
  final VoidCallback navigateToHome;

  DataTableScreen({required this.userTimes, required this.navigateToHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('List')),
      body: Center(
        child: Column(
          children: [
            SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Time')),
                ],
                rows: userTimes.map((userTime) {
                  return DataRow(cells: [
                    DataCell(Text(userTime.userName)),
                    DataCell(Text(userTime.time)),
                  ]);
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: navigateToHome,
              child: Text('New User'),
            ),
          ],
        ),
      ),
    );
  }
}
