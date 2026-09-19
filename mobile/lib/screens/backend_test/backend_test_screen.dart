import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../services/ai/adaptive_difficulty_service.dart';
import '../../services/ai/memory_game_compiler.dart';
import '../../services/ai/safety_circuit_service.dart';
import '../../services/api_service.dart';

class BackendTestScreen extends StatefulWidget {
  const BackendTestScreen({super.key});

  @override
  State<BackendTestScreen> createState() => _BackendTestScreenState();
}

class _BackendTestScreenState extends State<BackendTestScreen> {
  String _backendStatus = 'Press a button below to run a test.';
  bool _isLoading = false;

  Future<void> _testRootConnection() async {
    setState(() => _isLoading = true);
    final result = await ApiService.testBackend();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _backendStatus = 'Flask Server: $result\n(Target: ${ApiService.baseUrl})';
    });
  }

  Future<void> _testActivitiesEndpoint() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(Uri.parse('${ApiService.baseUrl}/api/ai/activities'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final count = data['data']['total_activities'];
        final domains = (data['data']['domains'] as List).join(', ');
        setState(() {
          _isLoading = false;
          _backendStatus = 'SUCCESS: Activity Registry Loaded!\n• Total Activities: $count\n• Domains: $domains';
        });
      } else {
        setState(() {
          _isLoading = false;
          _backendStatus = 'Error fetching activities: ${res.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _backendStatus = 'Connection failed: $e\nMake sure python app.py is running on PC!';
      });
    }
  }

  void _testOnDeviceDADE() {
    final dade = AdaptiveDifficultyService();
    // Simulate high-performing session
    final eval = dade.evaluateSession(
      accuracy: 0.88,
      avgResponseTimeMs: 1950,
      assignedDifficulty: 2,
      hintCount: 0,
      errorStreakMax: 1,
      roundsCompleted: 10,
    );

    setState(() {
      _backendStatus = 'ON-DEVICE DADE (Pure Dart Engine):\n'
          '• Cognitive Performance Index (CPI): ${eval.cpiScore}/100\n'
          '• Adjustment: +${eval.difficultyAdjustment} (Step Up)\n'
          '• Difficulty: Level ${eval.currentDifficulty} ➔ Level ${eval.recommendedDifficulty}\n'
          '• Clinical Reasoning: "${eval.clinicalReasoning}"';
    });
  }

  void _testSafetyCircuit() {
    final safety = SafetyCircuitService();
    // Simulate caregiver flagging agitation
    final preCheck = safety.evaluatePreSessionMood('Anxious');

    setState(() {
      _backendStatus = 'SAFETY CIRCUIT ("No Game Today" Fallback):\n'
          '• Allow Cognitive Game: ${preCheck.allowCognitiveGame}\n'
          '• Mode: ${preCheck.recommendedMode}\n'
          '• Action: ${preCheck.message}\n'
          '• Fallback Activity: "${preCheck.fallbackActivityTitle}" (${preCheck.fallbackType})';
    });
  }

  void _testMemoryCompiler() {
    final compiler = MemoryGameCompiler();
    final mockPeople = [
      {'name': 'Meera', 'relation': 'Granddaughter'},
      {'name': 'Arup', 'relation': 'Son'},
    ];
    final trial = compiler.compileFaceRecallTrial(mockPeople, difficulty: 2);

    setState(() {
      _backendStatus = 'PROCEDURAL MEMORY COMPILER:\n'
          '• Target Family Member: ${trial.correctName} (${trial.relationship})\n'
          '• Generated Options: ${trial.options.join(" | ")}\n'
          '• Correct Choice Index: ${trial.correctIndex}\n'
          '• Offline On-Device Synthesis: 100% Complete';
    });
  }

  Future<void> _syncSessionToLaptop() async {
    setState(() => _isLoading = true);
    final telemetry = {
      'session_id': 'SESS_MOBILE_${DateTime.now().millisecondsSinceEpoch}',
      'patient_id': 'PAT_001_ASHA',
      'cohort': 'Consistent_High_Functioning',
      'time_of_day': 'Morning',
      'domain': 'Memory',
      'game_id': 'act_mem_face_recall',
      'interaction_mode': 'Cognitive_Together',
      'assigned_difficulty': 2,
      'rounds_completed': 8,
      'accuracy': 0.88,
      'avg_response_time_ms': 1950,
      'hint_count': 0,
      'error_streak_max': 1,
      'abandoned_early': 0,
      'caregiver_observed_mood': 'Engaged',
    };

    final result = await ApiService.syncSessionTelemetry(telemetry);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result != null && result['status'] == 'success') {
        _backendStatus = 'SUCCESS! Session JSON written to your laptop:\n'
            '• ${result['message']}\n\n'
            'Open this file in VS Code on your laptop to inspect all 18 parameters and AI model routing!';
      } else {
        _backendStatus = 'Failed to sync session to laptop.\nMake sure python app.py is running on your PC!';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        title: const Text('AI & Backend Diagnostics', style: AppTypography.caregiverHeading),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics_outlined, color: AppColors.forestPrimary),
                      const SizedBox(width: 8),
                      const Text('Diagnostic Results', style: AppTypography.caregiverHeading),
                      if (_isLoading) ...[
                        const Spacer(),
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.forestPrimary),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    _backendStatus,
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.5,
                      fontFamily: 'monospace',
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('On-Device Edge AI Tests (Zero Internet Required)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _testOnDeviceDADE,
              icon: const Icon(Icons.speed),
              label: const Text('Test Adaptive Difficulty (DADE)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _testSafetyCircuit,
              icon: const Icon(Icons.shield_outlined),
              label: const Text('Test "No Game Today" Safety Circuit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warningWarm,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _testMemoryCompiler,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Test Procedural Memory Compiler'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sage,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Write Session Telemetry to Laptop (backend/data/sessions/)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _syncSessionToLaptop,
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Save & Export Session JSON to Laptop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Live Flask Backend Tests (http://10.0.2.2:5000)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _testRootConnection,
              icon: const Icon(Icons.cloud_sync_outlined),
              label: const Text('Check Flask Server Ping'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.forestPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _testActivitiesEndpoint,
              icon: const Icon(Icons.list_alt_outlined),
              label: const Text('Fetch Activity Registry (14 Games)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.forestPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
