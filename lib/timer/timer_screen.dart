import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreen();
}

class _TimerScreen extends State<TimerScreen> {
  int _currentSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _setDuration(int newTotalSeconds) {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    if (mounted) {
      setState(() {
        _currentSeconds = newTotalSeconds;
      });
    }
  }

  void _startTimer() {
    if (_isRunning && !_isPaused) return;
    if (_currentSeconds == 0) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('먼저 시간을 설정해주세요.')));
      }
      return;
    }

    _isPaused = false;
    _isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSeconds > 0) {
        if (mounted) {
          setState(() {
            _currentSeconds--;
          });
        }
      } else {
        _timer?.cancel();
        _isRunning = false;
        if (mounted) {
          setState(() {});
        }
        _showTimerEndDialog();
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  void _pauseTimer() {
    if (_isRunning && !_isPaused) {
      _timer?.cancel();
      _isPaused = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _resetTimer() {
    _setDuration(0);
  }

  void _showTimerEndDialog() {
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
            title: const Text('독서 끝!'),
            content: const Text('설정한 시간이 모두 경과했습니다.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetTimer();
                },
              ),
            ],
          ),
      );
    }
  }

  Future<void> _showSetTimeDialogWithPicker() async {
    Duration initialDuration = Duration(seconds: _currentSeconds);
    Duration pickedDuration = initialDuration;


    await showModalBottomSheet(
      context: context,
      builder: (BuildContext builderContext) {
        return SizedBox(
          height: 350,
          child: Column(
            children: [
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.ms,
                  initialTimerDuration: initialDuration,
                  onTimerDurationChanged: (Duration newDuration) {
                    pickedDuration = newDuration;
                  },
                ),
              ),
              CupertinoButton(
                child: const Text('완료'),
                onPressed: () {
                  _setDuration(pickedDuration.inSeconds);
                  Navigator.of(builderContext).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canStart = _currentSeconds > 0 && !_isRunning && !_isPaused; // 정지 상태이고 시간이 설정된 경우
    bool canPause = _isRunning && !_isPaused; // 실행 중인 경우
    bool canResume = _isPaused && _currentSeconds > 0; // 일시정지 상태이고 시간이 남은 경우

    return Scaffold(
      appBar: CupertinoNavigationBar(
          middle: Text('독서 타이머', style: TextStyle(fontSize: 20)),
          backgroundColor: Color.fromARGB(127, 101, 69, 1),
          border: Border(
            bottom: BorderSide(
              color: Color.fromARGB(127, 101, 69, 1),
              width: 0.1,
            )
          )
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Color.fromARGB(162, 132, 94, 1),
              Color.fromARGB(127, 101, 69, 1),
            ],
          ),
        ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: _showSetTimeDialogWithPicker,
              child: Text(
                _formatTime(_currentSeconds),
                style: TextStyle(
                  fontSize: 83,
                  fontWeight: FontWeight.bold,
                  color:
                      (_isRunning && !_isPaused && _currentSeconds <= 10 && _currentSeconds != 0)
                          ? CupertinoColors.destructiveRed
                          : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isRunning && !_isPaused
                  ? '독서에 집중합시다'
                  : (_isPaused
                      ? '일시정지'
                      : (_currentSeconds > 0 ? '책을 읽어봅시다' : '독서 시간을 설정하세요')),
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton.icon(
                  icon: Icon(canPause ? CupertinoIcons.pause_fill : CupertinoIcons.play_arrow_solid),
                  label: Text(canPause ? '일시정지' : (canResume ? '재시작' : '시작')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        (canStart || canResume)
                            ? CupertinoColors.systemGreen
                            : (canPause ? CupertinoColors.inactiveGray : CupertinoColors.systemGrey),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed:
                      (canStart || canPause || canResume)
                          ? () {
                            if (canPause) {
                              _pauseTimer();
                            } else {
                              _startTimer();
                            }
                          }
                          : null,
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  icon: const Icon(CupertinoIcons.refresh),
                  label: const Text('초기화'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CupertinoColors.systemRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: _resetTimer,
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
