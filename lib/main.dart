import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(NourFedaaApp(prefs: prefs));
}

class NourFedaaApp extends StatelessWidget {
  const NourFedaaApp({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نور وفداء', // ChatGPT build v1
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      ),
      home: HomeScreen(prefs: prefs),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? child;
  int xp = 0;
  int stars = 0;

  @override
  void initState() {
    super.initState();
    child = widget.prefs.getString('child');
    xp = widget.prefs.getInt('xp') ?? 0;
    stars = widget.prefs.getInt('stars') ?? 0;
  }

  Future<void> chooseChild(String name) async {
    await widget.prefs.setString('child', name);
    setState(() => child = name);
  }

  Future<void> startLesson() async {
    final newXp = xp + 25;
    final newStars = stars + 1;
    await widget.prefs.setInt('xp', newXp);
    await widget.prefs.setInt('stars', newStars);
    setState(() {
      xp = newXp;
      stars = newStars;
    });
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('أحسنتِ! 🌟'),
        content: const Text('أنجزتِ مهمة اليوم وحصلتِ على 25 XP ونجمة جديدة.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('رائع!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = (xp ~/ 100) + 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('نور وفداء ✨'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (child == null) ...[
              const Text(
                'مين هتبدأ الرحلة؟',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              _ChildButton(name: 'فداء', age: 5, onTap: () => chooseChild('فداء')),
              const SizedBox(height: 12),
              _ChildButton(name: 'نور', age: 3, onTap: () => chooseChild('نور')),
            ] else ...[
              Text(
                'أهلًا يا $child 🌟',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('المستوى $level  •  $xp XP  •  $stars ⭐'),
              const SizedBox(height: 18),
              LinearProgressIndicator(value: (xp % 100) / 100, minHeight: 12),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('مهمة اليوم 🎯',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('تعلّمي شيئًا جديدًا عن الصلاة والذكر والأخلاق الجميلة.'),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: startLesson,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('ابدئي المهمة'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('رحلتي 🗺️',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const _JourneyTile(icon: '🌱', title: 'بداية الرحلة', subtitle: 'مفتوحة الآن'),
              const _JourneyTile(icon: '🌳', title: 'حديقة المعرفة', subtitle: 'اجمعي 100 XP لفتحها'),
              const _JourneyTile(icon: '✨', title: 'مدينة النجوم', subtitle: 'قريبًا'),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChildButton extends StatelessWidget {
  const _ChildButton({required this.name, required this.age, required this.onTap});
  final String name;
  final int age;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      child: Text('$name  •  $age سنوات', style: const TextStyle(fontSize: 20)),
    );
  }
}

class _JourneyTile extends StatelessWidget {
  const _JourneyTile({required this.icon, required this.title, required this.subtitle});
  final String icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Text(icon, style: const TextStyle(fontSize: 30)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
        ),
      );
}
