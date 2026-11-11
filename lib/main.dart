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
      title: 'نُور وفداء',
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F3E8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF286B55)),
      ),
      home: HomePage(prefs: prefs),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? child;
  int stars = 0;

  @override
  void initState() {
    super.initState();
    child = widget.prefs.getString('child');
    stars = widget.prefs.getInt('stars') ?? 0;
  }

  Future<void> selectChild(String value) async {
    await widget.prefs.setString('child', value);
    setState(() => child = value);
  }

  Future<void> earnStar() async {
    final value = stars + 1;
    await widget.prefs.setInt('stars', value);
    setState(() => stars = value);
  }

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 58,
                    backgroundColor: Color(0xFFFFD86B),
                    child: Icon(Icons.explore_rounded, size: 68, color: Color(0xFF286B55)),
                  ),
                  const SizedBox(height: 24),
                  const Text('نُور وفداء', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text('رحلة تعلم وفرحة صغيرة كل يوم', textAlign: TextAlign.center, style: TextStyle(fontSize: 17)),
                  const SizedBox(height: 34),
                  const Text('مين هيبدأ الرحلة؟', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 18),
                  _ChildCard(name: 'فداء', age: 5, icon: Icons.star_rounded, onTap: () => selectChild('فداء')),
                  const SizedBox(height: 12),
                  _ChildCard(name: 'نور', age: 3, icon: Icons.wb_sunny_rounded, onTap: () => selectChild('نور')),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('أهلًا يا $child 🌟'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _WelcomeCard(child: child!, stars: stars),
          const SizedBox(height: 20),
          const Text('مهمة اليوم 🎯', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الخير الجميل', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    child == 'فداء'
                        ? 'اعملي عملًا جميلًا لشخص تحبيه واحكي عنه.'
                        : 'ساعدي حد أو قولي كلمة حلوة النهارده.',
                    style: const TextStyle(fontSize: 17, height: 1.5),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: earnStar,
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('أنجزت المهمة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('رحلتي 🗺️', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const _JourneyItem(icon: '🌱', title: 'بداية الرحلة', open: true),
          const _JourneyItem(icon: '📚', title: 'حديقة المعرفة', open: false),
          const _JourneyItem(icon: '⭐', title: 'مدينة النجوم', open: false),
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.name, required this.age, required this.icon, required this.onTap});
  final String name;
  final int age;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Text('$name  •  $age سنين', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
        ),
      );
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.child, required this.stars});
  final String child;
  final int stars;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF286B55), Color(0xFF4B8A6F)]),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xFFFFD86B),
              child: Icon(Icons.face_rounded, size: 38, color: Color(0xFF286B55)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('يلا يا $child!', style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text('$stars ⭐ نجمة', style: const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _JourneyItem extends StatelessWidget {
  const _JourneyItem({required this.icon, required this.title, required this.open});
  final String icon;
  final String title;
  final bool open;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          leading: Text(icon, style: const TextStyle(fontSize: 30)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          subtitle: Text(open ? 'مفتوحة الآن' : 'هتتفتح مع تقدمك'),
          trailing: Icon(open ? Icons.check_circle_rounded : Icons.lock_rounded),
        ),
      );
}
