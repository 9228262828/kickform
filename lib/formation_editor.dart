import 'package:flutter/material.dart';
import 'main.dart';

const availableSchemes = [
  '4-3-3',
  '4-4-2',
  '3-5-2',
  '5-3-2',
  '3-4-3',
  '4-2-3-1',
];

class FormationEditorScreen extends StatefulWidget {
  final FormationModel? formation;

  const FormationEditorScreen({
    super.key,
    this.formation,
  });

  @override
  State<FormationEditorScreen> createState() => _FormationEditorScreenState();
}

class _FormationEditorScreenState extends State<FormationEditorScreen> {
  late final TextEditingController nameController;
  late String scheme;
  late bool favorite;
  late List<PlayerModel> players;

  @override
  void initState() {
    super.initState();

    final formation = widget.formation;

    nameController = TextEditingController(
      text: formation?.name ?? 'My Formation',
    );

    scheme = formation?.scheme ?? '4-3-3';
    favorite = formation?.favorite ?? false;
    players = formation?.players ?? defaultPlayersForScheme(scheme);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void changeScheme(String newScheme) {
    final confirmedPlayers = defaultPlayersForScheme(newScheme);

    setState(() {
      scheme = newScheme;
      players = confirmedPlayers;
    });
  }

  void saveFormation() {
    final name = nameController.text.trim();

    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid formation name')),
      );
      return;
    }

    final now = DateTime.now();

    Navigator.pop(
      context,
      FormationModel(
        id: widget.formation?.id ?? now.microsecondsSinceEpoch.toString(),
        name: name,
        scheme: scheme,
        favorite: favorite,
        createdAt: widget.formation?.createdAt ?? now,
        updatedAt: now,
        players: players,
      ),
    );
  }

  Future<void> editPlayer(PlayerModel player) async {
    final result = await showModalBottomSheet<PlayerModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF08130D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PlayerEditorSheet(player: player),
    );

    if (result == null) return;

    setState(() {
      players = players.map((p) => p.id == result.id ? result : p).toList();
    });
  }

  void movePlayer(PlayerModel player, Offset localPosition, Size fieldSize) {
    final x = (localPosition.dx / fieldSize.width).clamp(.04, .96);
    final y = (localPosition.dy / fieldSize.height).clamp(.04, .96);

    setState(() {
      players = players
          .map(
            (p) => p.id == player.id
            ? p.copyWith(
          x: x.toDouble(),
          y: y.toDouble(),
        )
            : p,
      )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        backgroundColor: kBlack,
        foregroundColor: kWhite,
        title: const Text('Formation Editor'),
        actions: [
          IconButton(
            tooltip: 'Favorite',
            onPressed: () => setState(() => favorite = !favorite),
            icon: Icon(
              favorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: kGreen,
            ),
          ),
          TextButton(
            onPressed: saveFormation,
            child: const Text(
              'SAVE',
              style: TextStyle(
                color: kGreen,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(
                      color: kWhite,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Formation name',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(.6)),
                      prefixIcon: const Icon(Icons.badge_rounded, color: kGreen),
                      filled: true,
                      fillColor: const Color(0xFF0D1A12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: availableSchemes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final item = availableSchemes[index];
                        final active = scheme == item;

                        return ChoiceChip(
                          selected: active,
                          label: Text(item),
                          selectedColor: kGreen,
                          backgroundColor: const Color(0xFF0D1A12),
                          labelStyle: TextStyle(
                            color: active ? kBlack : kWhite,
                            fontWeight: FontWeight.w900,
                          ),
                          side: BorderSide(
                            color: active ? kGreen : kGreen.withOpacity(.25),
                          ),
                          onSelected: (_) => changeScheme(item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fieldSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(34),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kField,
                          border: Border.all(color: kGreen.withOpacity(.35)),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: FullPitchPainter(),
                              ),
                            ),
                            ...players.map(
                                  (player) {
                                final left =
                                    (player.x * fieldSize.width) - 27;
                                final top =
                                    (player.y * fieldSize.height) - 27;

                                return Positioned(
                                  left: left,
                                  top: top,
                                  child: GestureDetector(
                                    onTap: () => editPlayer(player),
                                    onPanUpdate: (details) {
                                      final box = context.findRenderObject()
                                      as RenderBox?;
                                      if (box == null) return;

                                      final local = box.globalToLocal(
                                        details.globalPosition,
                                      );

                                      movePlayer(
                                        player,
                                        local,
                                        fieldSize,
                                      );
                                    },
                                    child: PlayerBubble(player: player),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 16,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: kBlack.withOpacity(.72),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: kGreen.withOpacity(.25),
                                  ),
                                ),
                                child: const Text(
                                  'Tip: drag players to adjust positions. Tap a player to edit name, number, position, or captain.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: kWhite,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerBubble extends StatelessWidget {
  final PlayerModel player;

  const PlayerBubble({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
      '${player.name}, ${player.position}, number ${player.number}${player.captain ? ', captain' : ''}',
      button: true,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: player.captain ? kGreen : kWhite,
              shape: BoxShape.circle,
              border: Border.all(
                color: player.captain ? kWhite : kGreen,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: kGreen.withOpacity(.28),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                player.number.toString(),
                style: TextStyle(
                  color: player.captain ? kBlack : kDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxWidth: 72),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: kBlack.withOpacity(.75),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              player.position,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: kGreen,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullPitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withOpacity(.24)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final thickLine = Paint()
      ..color = Colors.white.withOpacity(.18)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final grass = Paint()
      ..color = Colors.white.withOpacity(.035)
      ..style = PaintingStyle.fill;

    final stripeHeight = size.height / 8;

    for (int i = 0; i < 8; i++) {
      if (i.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight),
          grass,
        );
      }
    }

    final outer = Rect.fromLTWH(
      14,
      14,
      size.width - 28,
      size.height - 28,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(outer, const Radius.circular(24)),
      line,
    );

    canvas.drawLine(
      Offset(14, size.height / 2),
      Offset(size.width - 14, size.height / 2),
      line,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      46,
      line,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      4,
      Paint()..color = Colors.white.withOpacity(.35),
    );

    final topBox = Rect.fromCenter(
      center: Offset(size.width / 2, 14),
      width: size.width * .45,
      height: 96,
    );

    final bottomBox = Rect.fromCenter(
      center: Offset(size.width / 2, size.height - 14),
      width: size.width * .45,
      height: 96,
    );

    canvas.drawRect(topBox, thickLine);
    canvas.drawRect(bottomBox, thickLine);

    final topSmallBox = Rect.fromCenter(
      center: Offset(size.width / 2, 14),
      width: size.width * .23,
      height: 46,
    );

    final bottomSmallBox = Rect.fromCenter(
      center: Offset(size.width / 2, size.height - 14),
      width: size.width * .23,
      height: 46,
    );

    canvas.drawRect(topSmallBox, line);
    canvas.drawRect(bottomSmallBox, line);

    canvas.drawCircle(
      Offset(size.width / 2, 102),
      3,
      Paint()..color = Colors.white.withOpacity(.4),
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height - 102),
      3,
      Paint()..color = Colors.white.withOpacity(.4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PlayerEditorSheet extends StatefulWidget {
  final PlayerModel player;

  const PlayerEditorSheet({
    super.key,
    required this.player,
  });

  @override
  State<PlayerEditorSheet> createState() => _PlayerEditorSheetState();
}

class _PlayerEditorSheetState extends State<PlayerEditorSheet> {
  late final TextEditingController nameController;
  late final TextEditingController numberController;
  late String position;
  late bool captain;

  final positions = const [
    'GK',
    'LB',
    'CB',
    'RB',
    'LWB',
    'RWB',
    'DM',
    'CM',
    'CAM',
    'LM',
    'RM',
    'LW',
    'RW',
    'ST',
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.player.name);
    numberController =
        TextEditingController(text: widget.player.number.toString());
    position = positions.contains(widget.player.position)
        ? widget.player.position
        : 'CM';
    captain = widget.player.captain;
  }

  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    super.dispose();
  }

  void savePlayer() {
    final name = nameController.text.trim();
    final number = int.tryParse(numberController.text.trim());

    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid player name')),
      );
      return;
    }

    if (number == null || number < 1 || number > 99) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player number must be between 1 and 99')),
      );
      return;
    }

    Navigator.pop(
      context,
      widget.player.copyWith(
        name: name,
        number: number,
        position: position,
        captain: captain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Edit Player',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kWhite,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: kWhite),
            decoration: InputDecoration(
              labelText: 'Player name',
              labelStyle: TextStyle(color: Colors.white.withOpacity(.6)),
              prefixIcon: const Icon(Icons.person_rounded, color: kGreen),
              filled: true,
              fillColor: const Color(0xFF0D1A12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: numberController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: kWhite),
            decoration: InputDecoration(
              labelText: 'Shirt number',
              labelStyle: TextStyle(color: Colors.white.withOpacity(.6)),
              prefixIcon: const Icon(Icons.numbers_rounded, color: kGreen),
              filled: true,
              fillColor: const Color(0xFF0D1A12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: position,
            dropdownColor: const Color(0xFF0D1A12),
            style: const TextStyle(
              color: kWhite,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              labelText: 'Position',
              labelStyle: TextStyle(color: Colors.white.withOpacity(.6)),
              prefixIcon: const Icon(Icons.sports_soccer, color: kGreen),
              filled: true,
              fillColor: const Color(0xFF0D1A12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none,
              ),
            ),
            items: positions
                .map(
                  (e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ),
            )
                .toList(),
            onChanged: (v) => setState(() => position = v ?? 'CM'),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: captain,
            activeThumbColor: kGreen,
            title: const Text(
              'Team Captain',
              style: TextStyle(
                color: kWhite,
                fontWeight: FontWeight.w800,
              ),
            ),
            secondary: const Icon(Icons.shield_rounded, color: kGreen),
            onChanged: (v) => setState(() => captain = v),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: kBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: savePlayer,
              child: const Text(
                'Save Player',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}