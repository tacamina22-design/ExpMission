
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() {
  runApp(const ExpMissionApp());
}

class ExpMissionApp extends StatelessWidget {
  const ExpMissionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExpMission',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int exp = 0;
  int level = 1;
  int streakDays = 0;
  DateTime? lastLogin;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      exp = prefs.getInt('exp') ?? 0;
      level = prefs.getInt('level') ?? 1;
      streakDays = prefs.getInt('streakDays') ?? 0;
      final lastLoginStr = prefs.getString('lastLogin');
      if (lastLoginStr != null) {
        lastLogin = DateTime.tryParse(lastLoginStr);
      }
    });
    _checkDailyStreak();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('exp', exp);
    prefs.setInt('level', level);
    prefs.setInt('streakDays', streakDays);
    prefs.setString('lastLogin', DateTime.now().toIso8601String());
  }

  void _checkDailyStreak() {
    final now = DateTime.now();
    if (lastLogin != null) {
      final diff = now.difference(lastLogin!).inDays;
      if (diff == 1) {
        streakDays++;
        exp += 10; // bonus streak
      } else if (diff > 1) {
        streakDays = 1;
      }
    } else {
      streakDays = 1;
    }
    _saveData();
  }

  void _completeMission(String type) {
    int gain = 0;
    switch (type) {
      case 'normal':
        gain = 20;
        break;
      case 'timed':
        gain = 40;
        break;
      case 'boss':
        gain = 100;
        break;
    }
    setState(() {
      exp += gain;
      if (exp >= level * 100) {
        level++;
        exp = 0;
      }
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ExpMission")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Level: $level", style: const TextStyle(fontSize: 20)),
            Text("EXP: $exp / ${level * 100}"),
            Text("Chuỗi ngày: $streakDays"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _completeMission('normal'),
              child: const Text("Làm nhiệm vụ thường (+20 EXP)"),
            ),
            ElevatedButton(
              onPressed: () => _completeMission('timed'),
              child: const Text("Làm nhiệm vụ giới hạn thời gian (+40 EXP)"),
            ),
            ElevatedButton(
              onPressed: () => _completeMission('boss'),
              child: const Text("Đánh Boss (+100 EXP)"),
            ),
          ],
        ),
      ),
    );
  }
}
