import 'dart:convert';
import 'dart:io';
import 'dart:math';

Future<void> main() async {
  final rng = Random(42);
  final outputDir = Directory('assets/questions');
  if (!outputDir.existsSync()) outputDir.createSync(recursive: true);

  const shapeColors = [0xFF818CF8, 0xFFF472B6, 0xFF34D399, 0xFFFBBF24, 0xFFFB923C, 0xFF67E8F9, 0xFFA78BFA, 0xFFF87171];
  const shapes = ['circle', 'square', 'triangle', 'pentagon', 'hexagon', 'oval', 'star', 'diamond'];

  String rs() => shapes[rng.nextInt(shapes.length)];
  int rc() => shapeColors[rng.nextInt(shapeColors.length)];

  Map<String, dynamic> ms(String t, int c, {double r = 0, double sc = 1.0, int co = 1}) =>
      {'type': t, 'color': c, 'rotationDeg': r, 'scale': sc, 'count': co};

  List<Map<String, dynamic>> makeOpts(Map<String, dynamic> ok, Random rng) {
    final opts = <Map<String, dynamic>>[ok];
    while (opts.length < 6) {
      final w = ms(rs(), rc());
      final isDup = opts.any((o) => o['type'] == w['type'] && o['color'] == w['color']);
      if (!isDup) opts.add(w);
    }
    opts.shuffle(rng);
    return opts;
  }

  for (int level = 1; level <= 100; level++) {
    final qs = <Map<String, dynamic>>[];
    for (int qi = 0; qi < 20; qi++) {
      final pat = (level <= 10) ? qi % 2 : (level <= 20) ? qi % 4 : (level <= 40) ? qi % 5 : (level <= 60) ? qi % 6 : (level <= 80) ? qi % 6 : qi % 8;
      final seq = <Map<String, dynamic>>[];
      final opts = <Map<String, dynamic>>[];
      int ci = 0;

      if (pat == 0) { // colorCycle
        final sh = rs(); final cl = level <= 15 ? 3 : (level <= 50 ? 4 : 5);
        final cols = List<int>.from(shapeColors)..shuffle(rng); final cc = cols.take(cl).toList();
        for (int i = 0; i < 8; i++) { seq.add(ms(sh, cc[i % cl])); }
        final ok = ms(sh, cc[8 % cl]);
        opts.addAll(makeOpts(ok, rng));
        ci = opts.indexWhere((o) => o['color'] == ok['color'] && o['type'] == ok['type']);
      } else if (pat == 1) { // sequence
        final cl2 = level <= 20 ? 2 : (level <= 50 ? 3 : 4);
        final shs = List.generate(cl2, (_) => rs()); final col = rc();
        for (int i = 0; i < 8; i++) { seq.add(ms(shs[i % cl2], col)); }
        final ok = ms(shs[8 % cl2], col);
        opts.addAll(makeOpts(ok, rng));
        ci = opts.indexWhere((o) => o['type'] == ok['type'] && o['color'] == ok['color']);
      } else if (pat == 2) { // rotation
        final sh = rs(); final col = rc(); final step = level <= 30 ? 90.0 : (level <= 60 ? 45.0 : 30.0);
        for (int i = 0; i < 8; i++) { seq.add(ms(sh, col, r: step * i)); }
        final ok = ms(sh, col, r: step * 8);
        opts.addAll(makeOpts(ok, rng));
        ci = opts.indexWhere((o) => o['type'] == ok['type'] && o['color'] == ok['color']);
      } else if (pat == 3) { // countPattern
        final sh = rs(); final col = rc(); final inc = level <= 30 ? 1 : (rng.nextBool() ? 1 : 2);
        for (int i = 0; i < 8; i++) { seq.add(ms(sh, col, co: (1 + i * inc).clamp(1, 5))); }
        final cnt = (1 + 8 * inc).clamp(1, 5);
        final ok = ms(sh, col, co: cnt);
        opts.addAll(makeOpts(ok, rng));
        ci = opts.indexWhere((o) => o['type'] == ok['type'] && o['color'] == ok['color']);
      } else if (pat == 4) { // sizeScale
        final sh = rs(); final col = rc();
        for (int i = 0; i < 8; i++) { seq.add(ms(sh, col, sc: 0.6 + 0.17 * i)); }
        final ok = ms(sh, col, sc: 0.6 + 0.17 * 8);
        opts.addAll(makeOpts(ok, rng));
        ci = opts.indexWhere((o) => o['type'] == ok['type'] && o['color'] == ok['color']);
      } else if (pat == 5) { // matrix3x3
        final cols = List<int>.from(shapeColors)..shuffle(rng); final cc = cols.take(3).toList();
        final shs = [rs(), rs(), rs()];
        for (int row = 0; row < 3; row++) {
          for (int col = 0; col < 3; col++) {
            if (row == 2 && col == 2) { continue; }
            seq.add(ms(shs[row], cc[col]));
          }
        }
        final ok = ms(shs[2], cc[2]);
        opts.addAll(makeOpts(ok, rng));
        ci = opts.indexWhere((o) => o['type'] == ok['type'] && o['color'] == ok['color']);
      } else if (pat == 6) { // symmetry
        final sh = rs(); final col = rc();
        for (int i = 0; i < 8; i++) { final m = i % 2 == 1; seq.add(ms(sh, m ? ((col + 0x40000000) & 0xFFFFFFFF) : col, r: m ? 180 : 0)); }
        final cm = 8 % 2 == 1;
        final ok = ms(sh, cm ? ((col + 0x40000000) & 0xFFFFFFFF) : col, r: cm ? 180 : 0);
        opts.addAll(makeOpts(ok, rng));
        ci = opts.indexWhere((o) => o['type'] == ok['type'] && o['color'] == ok['color']);
      } else { // combination
        final s1 = rs(), s2 = rs(), c1 = rc(), c2 = rc();
        for (int i = 0; i < 8; i++) { seq.add(ms(i % 2 == 0 ? s1 : s2, i % 3 == 0 ? c1 : c2)); }
        final ok = ms(8 % 2 == 0 ? s1 : s2, 8 % 3 == 0 ? c1 : c2);
        opts.addAll(makeOpts(ok, rng));
        ci = opts.indexWhere((o) => o['type'] == ok['type'] && o['color'] == ok['color']);
      }

      qs.add({
        'id': 'L${level}_Q${qi + 1}',
        'level': level,
        'orderInLevel': qi + 1,
        'pattern': ['colorCycle', 'sequence', 'rotation', 'countPattern', 'sizeScale', 'matrix3x3', 'symmetry', 'combination'][pat],
        'sequence': seq,
        'options': opts,
        'correctOptionIndex': ci,
        'isMatrix': pat == 5,
      });
    }

    final ls = level.toString().padLeft(3, '0');
    await File('assets/questions/level_$ls.json').writeAsString(jsonEncode(qs));
    stdout.write('\rGenerated level $level/100');
  }
  print('\nDone! Generated 100 level files with 2000 total questions.');
}
