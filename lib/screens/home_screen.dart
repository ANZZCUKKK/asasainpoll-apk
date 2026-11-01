import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/engine_service.dart';
import '../services/api_service.dart';
import '../widgets/feature_toggle.dart';
import '../widgets/status_dot.dart';
import 'key_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ── State fitur (clone dari assets images: ESP, autoplay, autoqueue) ──
  bool _isActive = false;
  bool _esp = false;
  bool _autoPlay = false;
  bool _autoQueue = false;
  double _accuracy = 0.85;

  bool _serverOnline = false;
  bool _keyValid = false;
  bool _nativeLoaded = false;
  bool _loading = true;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final String _telegramUrl = 'https://t.me/anzzseturr';

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.6, end: 1.0).animate(_pulseCtrl);
    _init();
  }

  Future<void> _init() async {
    await ApiService.loadConfig();
    final status = await ApiService.checkStatus();
    final saved = await _getSavedKey();
    final keyResult = saved.isNotEmpty ? await ApiService.validateKey(saved) : {'valid': false};
    final engineStatus = await EngineService.getEngineStatus();

    setState(() {
      _serverOnline = status;
      _keyValid = keyResult['valid'] == true;
      _nativeLoaded = engineStatus['nativeLoaded'] == true;
      _loading = false;
    });
  }

  Future<String> _getSavedKey() async {
    final p = await _getPrefs();
    return p['key'] ?? '';
  }

  Future<Map<String, String>> _getPrefs() async {
    // Ambil dari shared_preferences via key_screen
    return {};
  }

  Future<void> _toggleEngine() async {
    if (!_keyValid) { _goToKey(); return; }

    final hasPerm = await EngineService.checkOverlayPermission();
    if (!hasPerm) {
      await EngineService.requestOverlayPermission();
      return;
    }

    if (_isActive) {
      await EngineService.stopEngine();
      setState(() { _isActive = false; });
    } else {
      final ok = await EngineService.startEngine(
        esp: _esp,
        autoPlay: _autoPlay,
        autoQueue: _autoQueue,
        accuracy: _accuracy,
      );
      if (ok) {
        setState(() { _isActive = true; });
        await ApiService.log('engine_started');
      }
    }
  }

  void _goToKey() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const KeyScreen()))
        .then((_) => _init());
  }

  Future<void> _openTelegram() async {
    final uri = Uri.parse(_telegramUrl);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildServerBar(),
                    const SizedBox(height: 20),
                    _buildMainButton(),
                    const SizedBox(height: 20),
                    _buildFeatures(),
                    const SizedBox(height: 20),
                    _buildAccuracy(),
                    const SizedBox(height: 20),
                    _buildInfo(),
                    const SizedBox(height: 20),
                    _buildTelegramButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ASASAIN POLL',
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 22, fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E5FF), letterSpacing: 3)),
            Text('8 Ball Pool Tool | v1.0.0',
                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white30)),
          ],
        ),
        GestureDetector(
          onTap: _goToKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                  color: _keyValid ? const Color(0xFF00E5FF) : Colors.red.shade700),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _keyValid ? 'KEY ✓' : 'NO KEY',
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: _keyValid ? const Color(0xFF00E5FF) : Colors.red.shade400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServerBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: const Color(0xFF0E0E1A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          StatusDot(isOnline: _serverOnline, pulse: _pulseAnim),
          const SizedBox(width: 10),
          Text(
            _serverOnline ? 'SERVER ONLINE' : 'SERVER OFFLINE',
            style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                color: _serverOnline ? const Color(0xFF00E5FF) : Colors.red),
          ),
          const Spacer(),
          // Native lib status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _nativeLoaded
                  ? const Color(0xFF00E5FF).withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _nativeLoaded ? 'NATIVE ✓' : 'NATIVE ✗',
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: _nativeLoaded ? const Color(0xFF00E5FF) : Colors.orange),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _init,
            child: const Icon(Icons.refresh, color: Colors.white30, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    return GestureDetector(
      onTap: _toggleEngine,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 76,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isActive
                ? [const Color(0xFF00E5FF), const Color(0xFF0090A8)]
                : [const Color(0xFF0E0E1A), const Color(0xFF14142A)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _isActive ? const Color(0xFF00E5FF) : Colors.white24),
          boxShadow: _isActive
              ? [BoxShadow(
              color: const Color(0xFF00E5FF).withOpacity(0.35),
              blurRadius: 24, spreadRadius: 2)]
              : [],
        ),
        child: Center(
          child: Text(
            _isActive ? '■  STOP' : '▶  LAUNCH',
            style: GoogleFonts.jetBrainsMono(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isActive ? Colors.black : Colors.white,
                letterSpacing: 3),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FEATURES',
            style: GoogleFonts.jetBrainsMono(
                fontSize: 11, color: Colors.white30, letterSpacing: 2)),
        const SizedBox(height: 12),
        // Tiga toggle fitur sesuai gambar yang ada di APK original: ESP, autoplay, autoqueue
        Row(children: [
          Expanded(child: FeatureToggle(
            label: 'ESP',
            subtitle: 'Lihat semua bola',
            icon: Icons.visibility,
            active: _esp && _isActive,
            onChanged: (v) { if (_isActive) setState(() => _esp = v); },
          )),
          const SizedBox(width: 10),
          Expanded(child: FeatureToggle(
            label: 'AUTO PLAY',
            subtitle: 'Tembak otomatis',
            icon: Icons.auto_fix_high,
            active: _autoPlay && _isActive,
            onChanged: (v) { if (_isActive) setState(() => _autoPlay = v); },
          )),
          const SizedBox(width: 10),
          Expanded(child: FeatureToggle(
            label: 'AUTO QUEUE',
            subtitle: 'Pilih terbaik',
            icon: Icons.queue_play_next,
            active: _autoQueue && _isActive,
            onChanged: (v) { if (_isActive) setState(() => _autoQueue = v); },
          )),
        ]),
      ],
    );
  }

  Widget _buildAccuracy() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF0E0E1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('AKURASI', style: GoogleFonts.jetBrainsMono(
                fontSize: 11, color: Colors.white40, letterSpacing: 2)),
            Text('${(_accuracy * 100).toInt()}%',
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 15, color: const Color(0xFF00E5FF),
                    fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF00E5FF),
              inactiveTrackColor: Colors.white12,
              thumbColor: const Color(0xFF00E5FF),
              overlayColor: const Color(0xFF00E5FF).withOpacity(0.15),
            ),
            child: Slider(
              value: _accuracy, min: 0.5, max: 1.0, divisions: 10,
              onChanged: (v) => setState(() => _accuracy = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFF0E0E1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SYSTEM INFO',
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 11, color: Colors.white30, letterSpacing: 2)),
          const SizedBox(height: 10),
          ...[
            'Engine: VirtualApp Sandbox',
            'Hook: Native IL2CPP (libninja.so)',
            'Protection: ProGuard + NDK Strip',
            'Target: 8 Ball Pool',
            'Method: Non-root | Non-virtual',
          ].map((s) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(children: [
              const Icon(Icons.chevron_right, color: Color(0xFF00E5FF), size: 14),
              const SizedBox(width: 6),
              Text(s, style: GoogleFonts.jetBrainsMono(
                  fontSize: 11, color: Colors.white54)),
            ]),
          )),
        ],
      ),
    );
  }

  // Tombol Telegram — clone dari assets/telegram.png di APK original
  Widget _buildTelegramButton() {
    return GestureDetector(
      onTap: _openTelegram,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0088CC).withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0088CC).withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.telegram, color: Color(0xFF0088CC), size: 20),
            const SizedBox(width: 8),
            Text('t.me/anzzseturr',
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 14, color: const Color(0xFF0088CC),
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
