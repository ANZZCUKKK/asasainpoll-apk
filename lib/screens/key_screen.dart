import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class KeyScreen extends StatefulWidget {
  const KeyScreen({super.key});
  @override
  State<KeyScreen> createState() => _KeyScreenState();
}

class _KeyScreenState extends State<KeyScreen> {
  final _keyCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  bool _loading = false;
  String _msg = '';
  bool _ok = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _keyCtrl.text = p.getString('license_key') ?? '';
      _urlCtrl.text = p.getString('api_url') ?? 'http://YOUR_VPS_IP:3000';
    });
  }

  Future<void> _validate() async {
    setState(() { _loading = true; _msg = ''; });
    await ApiService.saveConfig(_urlCtrl.text.trim());
    final res = await ApiService.validateKey(_keyCtrl.text.trim());
    if (res['valid'] == true) {
      final p = await SharedPreferences.getInstance();
      await p.setString('license_key', _keyCtrl.text.trim());
      setState(() { _ok = true; _msg = 'Key valid!'; _loading = false; });
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) Navigator.pop(context);
    } else {
      setState(() { _ok = false; _msg = res['message'] ?? 'Key tidak valid'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF00E5FF)),
        title: Text('LICENSE', style: GoogleFonts.jetBrainsMono(
            color: const Color(0xFF00E5FF), fontSize: 14, letterSpacing: 2)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 20),
          _field(_urlCtrl, 'API Server URL', Icons.dns),
          const SizedBox(height: 14),
          _field(_keyCtrl, 'License Key', Icons.key),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _validate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : Text('VALIDASI', style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.bold, letterSpacing: 2)),
            ),
          ),
          if (_msg.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(_msg, style: GoogleFonts.jetBrainsMono(
                color: _ok ? const Color(0xFF00E5FF) : Colors.red, fontSize: 13)),
          ],
        ]),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 12),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF00E5FF))),
        prefixIcon: Icon(icon, color: Colors.white38),
      ),
    );
  }
}
