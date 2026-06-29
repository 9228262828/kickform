import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'formation_editor.dart';
import 'settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KickFormApp());
}

const kGreen = Color(0xFF20E070);
const kDark = Color(0xFF07130D);
const kBlack = Color(0xFF050807);
const kField = Color(0xFF0B3D22);
const kWhite = Color(0xFFFFFFFF);

const formationsKey = 'kickform.formations.v1';
const darkModeKey = 'kickform.dark.v1';

class KickFormApp extends StatefulWidget {
  const KickFormApp({super.key});

  @override
  State<KickFormApp> createState() => _KickFormAppState();
}

class _KickFormAppState extends State<KickFormApp> {
  bool darkMode = true;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => darkMode = prefs.getBool(darkModeKey) ?? true);
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(darkModeKey, value);
    setState(() => darkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KickForm',
      debugShowCheckedModeBanner: false,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: kGreen,
        scaffoldBackgroundColor: const Color(0xFFF3FFF7),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: kGreen,
        scaffoldBackgroundColor: kBlack,
      ),
      home: SplashScreen(
        darkMode: darkMode,
        onDarkModeChanged: setDarkMode,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const SplashScreen({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            darkMode: widget.darkMode,
            onDarkModeChanged: widget.onDarkModeChanged,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(
                'assets/logo.png',
                width: 170,
                height: 170,
                errorBuilder: (_, __, ___) => Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: kGreen.withOpacity(.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: kGreen, width: 3),
                  ),
                  child: const Icon(Icons.sports_soccer, color: kGreen, size: 88),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'KickForm',
                style: TextStyle(
                  color: kWhite,
                  fontSize: 46,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Build your football formation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kGreen,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: kGreen,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const HomeScreen({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum FormationFilter { all, favorites }

class _HomeScreenState extends State<HomeScreen> {
  List<FormationModel> formations = [];
  String search = '';
  FormationFilter filter = FormationFilter.all;

  @override
  void initState() {
    super.initState();
    loadFormations();
  }

  Future<void> loadFormations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(formationsKey);

    if (raw == null) {
      setState(() {
        formations = [FormationModel.defaultFormation()];
      });
      saveFormations();
      return;
    }

    try {
      final decoded = jsonDecode(raw) as List;
      setState(() {
        formations = decoded
            .map((e) => FormationModel.fromJson(Map<String, dynamic>.from(e)))
            .where((f) => f.name.trim().isNotEmpty)
            .toList();
        sortFormations();
      });
    } catch (_) {
      setState(() {
        formations = [FormationModel.defaultFormation()];
      });
      saveFormations();
    }
  }

  Future<void> saveFormations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      formationsKey,
      jsonEncode(formations.map((e) => e.toJson()).toList()),
    );
  }

  void sortFormations() {
    formations.sort((a, b) {
      if (a.favorite != b.favorite) return a.favorite ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
  }

  List<FormationModel> get visibleFormations {
    final q = search.toLowerCase();

    final list = formations.where((f) {
      final matchesSearch =
          f.name.toLowerCase().contains(q) || f.scheme.toLowerCase().contains(q);
      final matchesFilter = filter == FormationFilter.all || f.favorite;
      return matchesSearch && matchesFilter;
    }).toList();

    list.sort((a, b) {
      if (a.favorite != b.favorite) return a.favorite ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return list;
  }

  Future<void> openEditor([FormationModel? formation]) async {
    final result = await Navigator.push<FormationModel>(
      context,
      MaterialPageRoute(
        builder: (_) => FormationEditorScreen(
          formation: formation,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      final index = formations.indexWhere((f) => f.id == result.id);
      if (index == -1) {
        formations.add(result);
      } else {
        formations[index] = result;
      }
      sortFormations();
    });

    saveFormations();
  }

  Future<void> deleteFormation(FormationModel formation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete formation?'),
        content: Text('Delete "${formation.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final index = formations.indexWhere((f) => f.id == formation.id);
    setState(() => formations.removeWhere((f) => f.id == formation.id));
    await saveFormations();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${formation.name} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              formations.insert(index < 0 ? 0 : index, formation);
              sortFormations();
            });
            saveFormations();
          },
        ),
      ),
    );
  }

  Future<void> toggleFavorite(FormationModel formation) async {
    setState(() {
      final index = formations.indexWhere((f) => f.id == formation.id);
      formations[index] = formation.copyWith(
        favorite: !formation.favorite,
        updatedAt: DateTime.now(),
      );
      sortFormations();
    });
    saveFormations();
  }

  Future<void> duplicateFormation(FormationModel formation) async {
    final copy = formation.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: '${formation.name} Copy',
      favorite: false,
      updatedAt: DateTime.now(),
    );

    setState(() {
      formations.add(copy);
      sortFormations();
    });

    saveFormations();
  }

  @override
  Widget build(BuildContext context) {
    final visible = visibleFormations;
    final favoriteCount = formations.where((f) => f.favorite).length;

    return Scaffold(
      backgroundColor: kBlack,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: kField,
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: kGreen.withOpacity(.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        width: 56,
                        height: 56,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.sports_soccer,
                          color: kGreen,
                          size: 48,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'KickForm',
                          style: TextStyle(
                            color: kWhite,
                            fontSize: 31,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Settings',
                        color: kWhite,
                        icon: const Icon(Icons.settings_rounded),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SettingsScreen(
                              darkMode: widget.darkMode,
                              onDarkModeChanged: widget.onDarkModeChanged,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Build your football board.',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${formations.length} formations • $favoriteCount favorites',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.7),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: kGreen,
                        foregroundColor: kBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () => openEditor(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        'New Formation',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: kWhite),
                      onChanged: (v) => setState(() => search = v),
                      decoration: InputDecoration(
                        hintText: 'Search formations...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(.45)),
                        prefixIcon: const Icon(Icons.search_rounded, color: kGreen),
                        suffixIcon: search.isEmpty
                            ? null
                            : IconButton(
                          onPressed: () => setState(() => search = ''),
                          icon: const Icon(Icons.close_rounded, color: kWhite),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0D1A12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: filter == FormationFilter.favorites
                          ? kGreen
                          : const Color(0xFF0D1A12),
                      foregroundColor:
                      filter == FormationFilter.favorites ? kBlack : kWhite,
                    ),
                    onPressed: () {
                      setState(() {
                        filter = filter == FormationFilter.favorites
                            ? FormationFilter.all
                            : FormationFilter.favorites;
                      });
                    },
                    icon: const Icon(Icons.star_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? EmptyFormationState(onAdd: () => openEditor())
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, index) {
                  final formation = visible[index];
                  return FormationCard(
                    formation: formation,
                    onTap: () => openEditor(formation),
                    onFavorite: () => toggleFavorite(formation),
                    onDelete: () => deleteFormation(formation),
                    onDuplicate: () => duplicateFormation(formation),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormationCard extends StatelessWidget {
  final FormationModel formation;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const FormationCard({
    super.key,
    required this.formation,
    required this.onTap,
    required this.onFavorite,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${formation.name}, ${formation.scheme}, 11 players',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1A12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: kGreen.withOpacity(.18)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: kGreen.withOpacity(.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sports_soccer_rounded,
                      color: kGreen,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formation.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: kWhite,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formation.scheme} • ${formation.players.length} players',
                          style: const TextStyle(
                            color: kGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onFavorite,
                    icon: Icon(
                      formation.favorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: kGreen,
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: const Color(0xFF102015),
                    iconColor: kWhite,
                    onSelected: (v) {
                      if (v == 'duplicate') onDuplicate();
                      if (v == 'delete') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'duplicate',
                        child: Text('Duplicate'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MiniPitchPreview(formation: formation),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniPitchPreview extends StatelessWidget {
  final FormationModel formation;

  const MiniPitchPreview({super.key, required this.formation});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.8,
      child: Container(
        decoration: BoxDecoration(
          color: kField,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white24),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: MiniPitchPainter(),
              ),
            ),
            ...formation.players.map(
                  (player) => Positioned(
                left: player.x * 260,
                top: player.y * 120,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: kGreen,
                    shape: BoxShape.circle,
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

class MiniPitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRect(Rect.fromLTWH(8, 8, size.width - 16, size.height - 16), paint);
    canvas.drawLine(
      Offset(size.width / 2, 8),
      Offset(size.width / 2, size.height - 8),
      paint,
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 18, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EmptyFormationState extends StatelessWidget {
  final VoidCallback onAdd;

  const EmptyFormationState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(34),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo.png',
            width: 104,
            height: 104,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.sports_soccer,
              color: kGreen,
              size: 90,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No formations yet',
            style: TextStyle(
              color: kWhite,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first football board and organize your players.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(.72)),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Formation'),
          ),
        ],
      ),
    );
  }
}
class PlayerModel {
  final String id;
  final String name;
  final String position;
  final int number;
  final double x;
  final double y;
  final bool captain;

  const PlayerModel({
    required this.id,
    required this.name,
    required this.position,
    required this.number,
    required this.x,
    required this.y,
    required this.captain,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'position': position,
    'number': number,
    'x': x,
    'y': y,
    'captain': captain,
  };

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Player',
      position: json['position'] as String? ?? 'CM',
      number: json['number'] is int ? json['number'] as int : 1,
      x: (json['x'] is num ? json['x'] as num : .5).toDouble(),
      y: (json['y'] is num ? json['y'] as num : .5).toDouble(),
      captain: json['captain'] as bool? ?? false,
    );
  }

  PlayerModel copyWith({
    String? id,
    String? name,
    String? position,
    int? number,
    double? x,
    double? y,
    bool? captain,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      number: number ?? this.number,
      x: x ?? this.x,
      y: y ?? this.y,
      captain: captain ?? this.captain,
    );
  }
}

class FormationModel {
  final String id;
  final String name;
  final String scheme;
  final bool favorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PlayerModel> players;

  const FormationModel({
    required this.id,
    required this.name,
    required this.scheme,
    required this.favorite,
    required this.createdAt,
    required this.updatedAt,
    required this.players,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'scheme': scheme,
    'favorite': favorite,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'players': players.map((e) => e.toJson()).toList(),
  };

  factory FormationModel.fromJson(Map<String, dynamic> json) {
    return FormationModel(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'My Formation',
      scheme: json['scheme'] as String? ?? '4-3-3',
      favorite: json['favorite'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      players: ((json['players'] ?? []) as List)
          .map((e) => PlayerModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  FormationModel copyWith({
    String? id,
    String? name,
    String? scheme,
    bool? favorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PlayerModel>? players,
  }) {
    return FormationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      scheme: scheme ?? this.scheme,
      favorite: favorite ?? this.favorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      players: players ?? this.players,
    );
  }

  factory FormationModel.defaultFormation() {
    final now = DateTime.now();

    return FormationModel(
      id: now.microsecondsSinceEpoch.toString(),
      name: 'Default 4-3-3',
      scheme: '4-3-3',
      favorite: true,
      createdAt: now,
      updatedAt: now,
      players: defaultPlayersForScheme('4-3-3'),
    );
  }
}

List<PlayerModel> defaultPlayersForScheme(String scheme) {
  switch (scheme) {
    case '4-4-2':
      return _buildPlayers([
        _p('GK', .50, .90, 1),
        _p('LB', .18, .72, 3),
        _p('CB', .39, .72, 4),
        _p('CB', .61, .72, 5),
        _p('RB', .82, .72, 2),
        _p('LM', .18, .48, 11),
        _p('CM', .39, .48, 8),
        _p('CM', .61, .48, 6),
        _p('RM', .82, .48, 7),
        _p('ST', .40, .22, 9),
        _p('ST', .60, .22, 10),
      ]);

    case '3-5-2':
      return _buildPlayers([
        _p('GK', .50, .90, 1),
        _p('CB', .25, .72, 4),
        _p('CB', .50, .74, 5),
        _p('CB', .75, .72, 6),
        _p('LM', .12, .48, 11),
        _p('CM', .34, .48, 8),
        _p('CM', .50, .42, 10),
        _p('CM', .66, .48, 7),
        _p('RM', .88, .48, 2),
        _p('ST', .38, .20, 9),
        _p('ST', .62, .20, 19),
      ]);

    case '5-3-2':
      return _buildPlayers([
        _p('GK', .50, .90, 1),
        _p('LWB', .10, .70, 3),
        _p('CB', .30, .73, 4),
        _p('CB', .50, .76, 5),
        _p('CB', .70, .73, 6),
        _p('RWB', .90, .70, 2),
        _p('CM', .32, .45, 8),
        _p('CM', .50, .39, 10),
        _p('CM', .68, .45, 7),
        _p('ST', .38, .20, 9),
        _p('ST', .62, .20, 11),
      ]);

    case '3-4-3':
      return _buildPlayers([
        _p('GK', .50, .90, 1),
        _p('CB', .25, .72, 4),
        _p('CB', .50, .75, 5),
        _p('CB', .75, .72, 6),
        _p('LM', .18, .48, 11),
        _p('CM', .40, .48, 8),
        _p('CM', .60, .48, 10),
        _p('RM', .82, .48, 7),
        _p('LW', .22, .20, 17),
        _p('ST', .50, .15, 9),
        _p('RW', .78, .20, 19),
      ]);

    case '4-2-3-1':
      return _buildPlayers([
        _p('GK', .50, .90, 1),
        _p('LB', .18, .72, 3),
        _p('CB', .39, .74, 4),
        _p('CB', .61, .74, 5),
        _p('RB', .82, .72, 2),
        _p('DM', .40, .55, 6),
        _p('DM', .60, .55, 8),
        _p('LW', .22, .34, 11),
        _p('CAM', .50, .30, 10),
        _p('RW', .78, .34, 7),
        _p('ST', .50, .14, 9),
      ]);

    case '4-3-3':
    default:
      return _buildPlayers([
        _p('GK', .50, .90, 1),
        _p('LB', .18, .72, 3),
        _p('CB', .39, .74, 4),
        _p('CB', .61, .74, 5),
        _p('RB', .82, .72, 2),
        _p('CM', .32, .48, 8),
        _p('CM', .50, .42, 6),
        _p('CM', .68, .48, 10),
        _p('LW', .22, .20, 11),
        _p('ST', .50, .14, 9),
        _p('RW', .78, .20, 7),
      ]);
  }
}

_PlayerSeed _p(String position, double x, double y, int number) {
  return _PlayerSeed(position, x, y, number);
}

List<PlayerModel> _buildPlayers(List<_PlayerSeed> seeds) {
  return List.generate(seeds.length, (index) {
    final seed = seeds[index];
    return PlayerModel(
      id: '${DateTime.now().microsecondsSinceEpoch}_$index',
      name: seed.position,
      position: seed.position,
      number: seed.number,
      x: seed.x,
      y: seed.y,
      captain: seed.position == 'ST' || seed.position == 'CAM',
    );
  });
}

class _PlayerSeed {
  final String position;
  final double x;
  final double y;
  final int number;

  const _PlayerSeed(this.position, this.x, this.y, this.number);
}