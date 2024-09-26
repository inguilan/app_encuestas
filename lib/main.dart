import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const SurveyApp());
}

class SurveyApp extends StatelessWidget {
  const SurveyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      home: const SurveyHome(),
    );
  }
}

class SurveyHome extends StatefulWidget {
  const SurveyHome({super.key});

  @override
  State<SurveyHome> createState() => _SurveyHomeState();
}

class _SurveyHomeState extends State<SurveyHome> {
  final Map<String, int> _surveyResults = {
    'Option 1': 0,
    'Option 2': 0,
    'Option 3': 0,
  };

  String _selectedOption = 'Option 1';
  bool _isVotingEnabled = true;
  int _remainingTime = 30; // Tiempo en segundos
  Timer? _timer;
  double _progressValue = 1.0;

  @override
  void initState() {
    super.initState();
    _startTimer(); // Inicia el temporizador cuando la encuesta empieza
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela el temporizador al salir
    super.dispose();
  }

  void _startTimer() {
    _progressValue = 1.0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
          _progressValue = _remainingTime / 30;
        });
      } else {
        timer.cancel();
        setState(() {
          _isVotingEnabled = false; // Desactiva la votación
        });
      }
    });
  }

  void _vote() {
    setState(() {
      _surveyResults[_selectedOption] = _surveyResults[_selectedOption]! + 1;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voto registrado para $_selectedOption')),
      );
    });
  }

  void _resetSurvey() {
    setState(() {
      _surveyResults.updateAll((key, value) => 0); // Resetea los votos
      _remainingTime = 30; // Restablece el temporizador
      _isVotingEnabled = true;
      _startTimer(); // Inicia el temporizador nuevamente
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Encuesta - Tiempo restante: $_remainingTime s'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24.0),
          const Text(
            'Seleccione una opción:',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          ..._surveyResults.keys.map((option) {
            return RadioListTile(
              title: Text(option),
              value: option,
              groupValue: _selectedOption,
              onChanged: _isVotingEnabled
                  ? (String? value) {
                      setState(() {
                        _selectedOption = value!;
                      });
                    }
                  : null, // Desactiva las opciones cuando el tiempo ha terminado
            );
          }).toList(),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: _progressValue,
            backgroundColor: Colors.grey[300],
            color: _isVotingEnabled ? Colors.blue : Colors.red,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isVotingEnabled
                ? _vote
                : null, // Desactiva el botón si ha terminado el tiempo
            child: Text(_isVotingEnabled ? 'Votar' : 'Tiempo terminado'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Resultados:',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          _buildBarChart(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _resetSurvey,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reiniciar encuesta'),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final totalVotes = _surveyResults.values.reduce((a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: _surveyResults.keys.map((option) {
          final percentage =
              totalVotes == 0 ? 0.0 : _surveyResults[option]! / totalVotes;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: <Widget>[
                Text('$option (${_surveyResults[option]!.toStringAsFixed(1)} votos)'),
                const SizedBox(width: 10),
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage,
                    color: Colors.blue,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 10),
                Text('${(percentage * 100).toStringAsFixed(2)}%'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
