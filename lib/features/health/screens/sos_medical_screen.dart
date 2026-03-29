import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';

class SosMedicalScreen extends StatefulWidget {
  const SosMedicalScreen({super.key});

  @override
  State<SosMedicalScreen> createState() => _SosMedicalScreenState();
}

class _SosMedicalScreenState extends State<SosMedicalScreen> {
  final FlutterTts _tts = FlutterTts();
  final Dio _dio = Dio();

  bool _sendingAlert = false;
  bool _smartwatchEnabled = false;
  String _locationStatus = 'Récupération...';
  Position? _latestPosition;

  @override
  void initState() {
    super.initState();
    _prepareVoice();
    _fetchCurrentLocation();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _prepareVoice() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _locationStatus = 'Récupération...';
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = 'GPS désactivé. Activez la localisation.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = 'Permission localisation refusée.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _latestPosition = position;
        _locationStatus =
            'Position envoyée avec l’alerte : '
            '${position.latitude.toStringAsFixed(4)}, '
            '${position.longitude.toStringAsFixed(4)}';
      });
    } catch (_) {
      setState(() {
        _locationStatus = 'Impossible de récupérer la localisation.';
      });
    }
  }

  Future<void> _sendSosAlert() async {
    if (_sendingAlert) return;
    setState(() => _sendingAlert = true);

    try {
      var position = _latestPosition;
      if (position == null) {
        await _fetchCurrentLocation();
        position = _latestPosition;
      }

      if (position == null) {
        _showSnack('Localisation indisponible. Réessayez.');
        return;
      }

      // Message vocal local immédiat pour confirmer l’alerte.
      await _tts.speak(
        'Alerte SOS envoyée. Votre localisation est transmise '
        'immédiatement à votre accompagnant.',
      );

      final payload = {
        'type': 'SOS_MEDICAL',
        'message': 'Besoin d’assistance immédiate',
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'timestamp': DateTime.now().toIso8601String(),
        },
      };

      final baseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:3000',
      );

      // Le backend doit router cette alerte vers l’accompagnant lié.
      await _dio.post(
        '$baseUrl/sos/alert',
        data: payload,
        options: Options(
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      _showSnack('Alerte SOS envoyée à votre accompagnant.');
    } on DioException catch (e) {
      _showSnack(
        'Alerte locale lancée, échec d’envoi serveur (${e.response?.statusCode ?? 'réseau'}).',
      );
    } catch (_) {
      _showSnack('Erreur inattendue pendant l’envoi SOS.');
    } finally {
      if (mounted) {
        setState(() => _sendingAlert = false);
      }
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFF1E78D7),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'SOS Médical',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30 / 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  children: [
                    _MapPreviewCard(position: _latestPosition),
                    const SizedBox(height: 10),
                    _SosOptionCard(
                      iconBg: const Color(0xFFDCEEFF),
                      icon: Icons.location_on,
                      iconColor: const Color(0xFF2E86DE),
                      title: 'Envoi automatique de localisation',
                      subtitle: _locationStatus,
                      trailing: IconButton(
                        onPressed: _fetchCurrentLocation,
                        icon: const Icon(
                          Icons.open_in_new,
                          color: Color(0xFF6A6A6A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SosOptionCard(
                      iconBg: const Color(0xFFFFE7E4),
                      icon: Icons.favorite,
                      iconColor: const Color(0xFFE74C3C),
                      title: 'Constantes (smartwatch)',
                      subtitle:
                          'Connectez une montre pour envoyer fréquence cardiaque et SpO2',
                      trailing: Switch(
                        value: _smartwatchEnabled,
                        onChanged: (value) {
                          setState(() => _smartwatchEnabled = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _SosOptionCard(
                      iconBg: Color(0xFFE3F6E8),
                      icon: Icons.call,
                      iconColor: Color(0xFF49B36A),
                      title: 'Appel + SMS contact proche',
                      subtitle: 'Aucun contact d’urgence. Ajoutez-en dans votre profil.',
                    ),
                    const SizedBox(height: 10),
                    _SosOptionCard(
                      iconBg: const Color(0xFFF3E7FF),
                      icon: Icons.record_voice_over,
                      iconColor: const Color(0xFF8E44AD),
                      title: 'Message vocal automatique (IA)',
                      subtitle:
                          'Exemple : « [Prénom] a besoin d’assistance immédiate. '
                          'Il se trouve à cette position GPS. »',
                      trailing: IconButton(
                        onPressed: () {
                          _tts.speak(
                            'Alerte SOS de Ma3ak. '
                            'La personne a besoin d’assistance immédiate.',
                          );
                        },
                        icon: const Icon(Icons.volume_up, color: Color(0xFF5D5D5D)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _sendingAlert ? null : _sendSosAlert,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4438),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _sendingAlert
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.emergency, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Envoyer l’alerte SOS',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard({required this.position});

  final Position? position;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 165,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage(
            'https://tile.openstreetmap.org/14/8420/5870.png',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withOpacity(0.12),
            ),
          ),
          const Center(
            child: Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
          if (position != null)
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'GPS: ${position!.latitude.toStringAsFixed(4)}, '
                  '${position!.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SosOptionCard extends StatelessWidget {
  const _SosOptionCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
