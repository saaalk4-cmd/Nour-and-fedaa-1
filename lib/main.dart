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
    const green = Color(0xFF236B57);
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
        fontFamily: 'sans',
        scaffoldBackgroundColor: const Color(0xFFF8F5ED),
        colorScheme: ColorScheme.fromSeed(seedColor: green),
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
  int level = 1;
  int completed = 0;
  bool missionDoneToday = false;

  @override
  void initState() {
    super.initState();
    child = widget.prefs.getString('child');
    stars = widget.prefs.getInt('stars') ?? 0;
    level = widget.prefs.getInt('level') ?? 1;
    completed = widget.prefs.getInt('completed') ?? 0;
    final today = DateTime.now();
    final savedDay = widget.prefs.getString('missionDay');
    final todayKey = '${today.year}-${today.month}-${today.day}';
    missionDoneToday = savedDay == todayKey;
  }

  Future<void> selectChild(String value) async {
    await widget.prefs.setString('child', value);
    setState(() => child = value);
  }

  Future<void> completeMission() async {
    if (missionDoneToday) return;
    final newStars = stars + 1;
    final newCompleted = completed + 1;
    final newLevel = 1 + (newStars ~/ 5);
    await widget.prefs.setInt('stars', newStars);
    await widget.prefs.setInt('completed', newCompleted);
    await widget.prefs.setInt('level', newLevel);
    final now = DateTime.now();
    await widget.prefs.setString('missionDay', '${now.year}-${now.month}-${now.day}');
    if (!mounted) return;
    setState(() {
      stars = newStars;
      completed = newCompleted;
      level = newLevel;
      missionDoneToday = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('برافو يا $child! 🌟 نجمة جديدة!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (child == null) return _SelectionPage(onSelect: selectChild);

    const starsPerLevel = 5;
    final progress = ((stars % starsPerLevel) / starsPerLevel).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('نُور وفداء', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'تغيير الطفل',
            onPressed: () => setState(() => child = null),
            icon: const Icon(Icons.swap_horiz_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          _HeroCard(child: child!, stars: stars, level: level, progress: progress),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'مهمة اليوم', emoji: '🎯'),
          const SizedBox(height: 10),
          _MissionCard(child: child!, completed: missionDoneToday, onComplete: completeMission),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'رحلتي', emoji: '🗺️'),
          const SizedBox(height: 10),
          _MapCard(stars: stars),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'إنجازاتي', emoji: '🏆'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatCard(icon: Icons.star_rounded, value: '$stars', label: 'نجوم')),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(icon: Icons.check_circle_rounded, value: '$completed', label: 'مهام')),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(icon: Icons.emoji_events_rounded, value: '$level', label: 'مستوى')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectionPage extends StatelessWidget {
  const _SelectionPage({required this.onSelect});
  final Future<void> Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 116,
                  height: 116,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFE08A), Color(0xFFFFC94A)],
                    ),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, size: 64, color: Color(0xFF236B57)),
                ),
                const SizedBox(height: 24),
                const Text('نُور وفداء', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text(
                  'رحلة صغيرة كل يوم… وفرحة كبيرة مع كل خطوة 🌱',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, height: 1.5),
                ),
                const SizedBox(height: 34),
                const Text('مين هيبدأ الرحلة؟', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                const SizedBox(height: 18),
                _ChildButton(name: 'فداء', age: '٥ سنين', icon: Icons.star_rounded, onTap: () => onSelect('فداء')),
                const SizedBox(height: 12),
                _ChildButton(name: 'نور', age: '٣ سنين', icon: Icons.wb_sunny_rounded, onTap: () => onSelect('نور')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildButton extends StatelessWidget {
  const _ChildButton({required this.name, required this.age, required this.icon, required this.onTap});
  final String name;
  final String age;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFFFE08A),
              child: Icon(icon, color: const Color(0xFF236B57), size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            ),
            Text(age, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.child, required this.stars, required this.level, required this.progress});
  final String child;
  final int stars;
  final int level;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF236B57), Color(0xFF4D9074)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Color(0x22000000))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFFFDF79),
                child: Icon(Icons.face_rounded, size: 38, color: Color(0xFF236B57)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('أهلًا يا $child! 👋', style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                    Text('المستوى $level  •  $stars ⭐', style: const TextStyle(color: Colors.white70, fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text('رحلتك ماشية حلو! كمّل خطوة كمان ✨', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFDF79)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.child, required this.completed, required this.onComplete});
  final String child;
  final bool completed;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final mission = child == 'فداء'
        ? 'اعملي عملًا جميلًا لشخص تحبيه، وبعدها احكي لماما أو بابا عنه.'
        : 'قولي كلمة حلوة لحد بتحبيه، أو ساعديه في حاجة بسيطة.';
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💛', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 10),
                const Expanded(child: Text('الخير الجميل', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900))),
                if (!completed) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFFFF0BC), borderRadius: BorderRadius.circular(20)),
                  child: const Text('+1 ⭐', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(mission, style: const TextStyle(fontSize: 17, height: 1.55)),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: completed
                  ? FilledButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('تم إنجاز مهمة اليوم ✓', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                    )
                  : FilledButton.icon(
                      onPressed: onComplete,
                      icon: const Icon(Icons.celebration_rounded),
                      label: const Text('أنجزت المهمة 🎉', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.stars});
  final int stars;

  @override
  Widget build(BuildContext context) {
    final unlocked = stars >= 3;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _MapRow(icon: '🌱', title: 'بوابة البداية', subtitle: 'أنت هنا', unlocked: true),
            _MapRow(icon: '📚', title: 'حديقة المعرفة', subtitle: unlocked ? 'مفتوحة! ابدأ الاستكشاف' : 'تفتح عند ٣ نجوم', unlocked: unlocked),
            _MapRow(icon: '🌟', title: 'مدينة النجوم', subtitle: stars >= 7 ? 'مفتوحة!' : 'تفتح عند ٧ نجوم', unlocked: stars >= 7),
          ],
        ),
      ),
    );
  }
}

class _MapRow extends StatelessWidget {
  const _MapRow({required this.icon, required this.title, required this.subtitle, required this.unlocked});
  final String icon;
  final String title;
  final String subtitle;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: unlocked ? const Color(0xFFF0F7F2) : const Color(0xFFF4F2ED),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Text(icon, style: const TextStyle(fontSize: 30)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
        trailing: Icon(unlocked ? Icons.check_circle_rounded : Icons.lock_rounded),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.emoji});
  final String title;
  final String emoji;

  @override
  Widget build(BuildContext context) => Text('$emoji  $title', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900));
}
