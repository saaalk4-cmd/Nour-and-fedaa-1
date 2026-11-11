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
        scaffoldBackgroundColor: const Color(0xFFF7F5EF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF315C4A),
          brightness: Brightness.light,
        ),
        fontFamily: 'sans',
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
  int streak = 0;
  int completed = 0;

  @override
  void initState() {
    super.initState();
    child = widget.prefs.getString('child');
    xp = widget.prefs.getInt('xp') ?? 0;
    stars = widget.prefs.getInt('stars') ?? 0;
    streak = widget.prefs.getInt('streak') ?? 0;
    completed = widget.prefs.getInt('completed') ?? 0;
  }

  Future<void> chooseChild(String name) async {
    await widget.prefs.setString('child', name);
    setState(() => child = name);
  }

  Future<void> completeMission() async {
    final newXp = xp + 20;
    final newStars = stars + 1;
    final newStreak = streak + 1;
    final newCompleted = completed + 1;
    await widget.prefs.setInt('xp', newXp);
    await widget.prefs.setInt('stars', newStars);
    await widget.prefs.setInt('streak', newStreak);
    await widget.prefs.setInt('completed', newCompleted);
    setState(() {
      xp = newXp;
      stars = newStars;
      streak = newStreak;
      completed = newCompleted;
    });
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('يا سلام! ⭐', textAlign: TextAlign.center),
        content: const Text(
          'خلصتي مهمة النهارده! كسبتي نجمة و20 نقطة.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('نكمل الرحلة'),
          ),
        ],
      ),
    );
  }

  void showLocked(String title) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, textAlign: TextAlign.center),
        content: const Text(
          'لسه بدري عليها 🌱\nكمّلي رحلتك وهتتفتح واحدة واحدة.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حاضر'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return _WelcomeScreen(onChoose: chooseChild);
    }

    final level = (xp ~/ 100) + 1;
    final progress = (xp % 100) / 100;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HeroHeader(
                childName: child!,
                level: level,
                xp: xp,
                stars: stars,
                streak: streak,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 14),
                  _SectionTitle(title: 'مهمة النهارده', icon: Icons.auto_awesome_rounded),
                  const SizedBox(height: 10),
                  _MissionCard(
                    childName: child!,
                    onTap: completeMission,
                  ),
                  const SizedBox(height: 22),
                  _LevelCard(level: level, progress: progress, xp: xp),
                  const SizedBox(height: 22),
                  const _SectionTitle(title: 'رحلة نُور وفداء', icon: Icons.map_rounded),
                  const SizedBox(height: 10),
                  _JourneyMap(
                    xp: xp,
                    onLocked: showLocked,
                  ),
                  const SizedBox(height: 22),
                  const _SectionTitle(title: 'إنجازاتي', icon: Icons.emoji_events_rounded),
                  const SizedBox(height: 10),
                  _Achievements(stars: stars, completed: completed),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen({required this.onChoose});
  final Future<void> Function(String) onChoose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E4D3A), Color(0xFF5C8067), Color(0xFFF7F5EF)],
            stops: [0, .48, 1],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 34, 22, 24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD978),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .18),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    size: 70,
                    color: Color(0xFF315C4A),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'نُور وفداء',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'رحلة صغيرة... مليانة معرفة وفرحة ✨',
                  style: TextStyle(color: Colors.white, fontSize: 17),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .96),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'مين هيبدأ الرحلة؟',
                        style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 16),
                      _ProfileButton(
                        name: 'فداء',
                        age: '5 سنين',
                        icon: Icons.star_rounded,
                        onTap: () => onChoose('فداء'),
                      ),
                      const SizedBox(height: 10),
                      _ProfileButton(
                        name: 'نور',
                        age: '3 سنين',
                        icon: Icons.wb_sunny_rounded,
                        onTap: () => onChoose('نور'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({
    required this.name,
    required this.age,
    required this.icon,
    required this.onTap,
  });
  final String name;
  final String age;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF2EEE4),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFFFFD978),
                child: Icon(icon, color: const Color(0xFF315C4A), size: 29),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                    Text(age, style: const TextStyle(color: Color(0xFF6B716B))),
                  ],
                ),
              ),
              const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.childName,
    required this.level,
    required this.xp,
    required this.stars,
    required this.streak,
  });
  final String childName;
  final int level;
  final int xp;
  final int stars;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF214D3A), Color(0xFF47765B)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 27,
                backgroundColor: Color(0xFFFFD978),
                child: Icon(Icons.face_rounded, color: Color(0xFF315C4A), size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أهلًا يا $childName 👋',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'المستوى $level',
                      style: const TextStyle(color: Color(0xFFDDE9DF), fontSize: 15),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.settings_rounded, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _StatPill(icon: Icons.star_rounded, value: '$stars', label: 'نجوم'),
              const SizedBox(width: 8),
              _StatPill(icon: Icons.local_fire_department_rounded, value: '$streak', label: 'أيام'),
              const SizedBox(width: 8),
              _StatPill(icon: Icons.bolt_rounded, value: '$xp', label: 'XP'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFFD978), size: 21),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.childName, required this.onTap});
  final String childName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOlder = childName == 'فداء';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE9E3D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE9A9),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(Icons.lightbulb_rounded, color: Color(0xFF8C6811), size: 30),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مهمة اليوم', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    Text('مهمة قصيرة وممتعة', style: TextStyle(color: Color(0xFF7A807B))),
                  ],
                ),
              ),
              const Text('+20 XP', style: TextStyle(color: Color(0xFF315C4A), fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            isOlder
                ? 'اختاري خلقًا جميلًا اليوم، واحكي مثالًا بسيطًا عليه. 💚'
                : 'اختاري شيئًا جميلًا فعلتيه اليوم: مساعدة، شكر، أو ابتسامة. 😊',
            style: const TextStyle(fontSize: 17, height: 1.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('ابدئي المهمة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF315C4A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level, required this.progress, required this.xp});
  final int level;
  final double progress;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final remaining = 100 - (xp % 100);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F0E9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.rocket_launch_rounded, color: Color(0xFF315C4A)),
              const SizedBox(width: 9),
              Text('المستوى $level', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const Spacer(),
              Text('$remaining XP للمرحلة الجاية', style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress == 0 ? .01 : progress,
              minHeight: 11,
              backgroundColor: Colors.white,
              color: const Color(0xFF315C4A),
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyMap extends StatelessWidget {
  const _JourneyMap({required this.xp, required this.onLocked});
  final int xp;
  final void Function(String) onLocked;

  @override
  Widget build(BuildContext context) {
    final nodes = [
      ('🌱', 'حديقة البداية', 'ابدئي هنا', true),
      ('📚', 'وادي المعرفة', '100 XP', xp >= 100),
      ('🌟', 'مدينة النجوم', '250 XP', xp >= 250),
      ('🏆', 'قصر الإنجازات', '500 XP', xp >= 500),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE9E3D7)),
      ),
      child: Column(
        children: List.generate(nodes.length, (i) {
          final n = nodes[i];
          return Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: n.$4 ? null : () => onLocked(n.$2),
                child: Opacity(
                  opacity: n.$4 ? 1 : .52,
                  child: Row(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: n.$4 ? const Color(0xFFFFF1BF) : const Color(0xFFE8E9E7),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(n.$1, style: const TextStyle(fontSize: 29)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.$2, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                            Text(n.$3, style: const TextStyle(color: Color(0xFF777D78))),
                          ],
                        ),
                      ),
                      Icon(
                        n.$4 ? Icons.check_circle_rounded : Icons.lock_rounded,
                        color: n.$4 ? const Color(0xFF315C4A) : const Color(0xFF888D88),
                      ),
                    ],
                  ),
                ),
              ),
              if (i != nodes.length - 1)
                Container(
                  width: 3,
                  height: 22,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8DCD6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _Achievements extends StatelessWidget {
  const _Achievements({required this.stars, required this.completed});
  final int stars;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('🌟', 'أول نجمة', stars >= 1),
      ('🎯', 'أول مهمة', completed >= 1),
      ('🔥', 'ثلاثة أيام', completed >= 3),
    ];
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE9E3D7)),
            ),
            child: Opacity(
              opacity: item.$3 ? 1 : .38,
              child: Column(
                children: [
                  Text(item.$1, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(item.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF315C4A), size: 22),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
