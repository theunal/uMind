import 'dart:convert';
import 'dart:io';
import 'dart:math';

Random rng = Random(42);

const shapeColors = [
  0xFF818CF8,
  0xFFF472B6,
  0xFF34D399,
  0xFFFBBF24,
  0xFFFB923C,
  0xFF67E8F9,
  0xFFA78BFA,
  0xFFF87171,
  0xFFFF6B6B,
  0xFF4ECDC4,
  0xFF45B7D1,
  0xFF96CEB4,
  0xFFDDA0DD,
  0xFF98D8C8,
  0xFFF7DC6F,
  0xFF82E0AA,
];

const lineColors = [
  0xFFEF4444,
  0xFF3B82F6,
  0xFF22C55E,
  0xFFFBBF24,
  0xFFF97316,
  0xFF8B5CF6,
  0xFFEC4899,
  0xFF06B6D4,
];
const shapes = [
  'circle',
  'square',
  'triangle',
  'pentagon',
  'hexagon',
  'oval',
  'star',
  'diamond',
];
const linePatterns = [
  'horizontal',
  'vertical',
  'cross',
  'diagonal',
  'plus',
  'minus',
  'times',
  'dot',
];

String rs() => shapes[rng.nextInt(shapes.length)];
int rc() => shapeColors[rng.nextInt(shapeColors.length)];
String rlp() => linePatterns[rng.nextInt(linePatterns.length)];

Map<String, dynamic> shape(
  String t,
  int c, {
  double r = 0,
  double sc = 1.0,
  bool o = false,
  String? lp,
}) => {
  'type': t,
  'color': c,
  'rotationDeg': r,
  'scale': sc,
  if (o) 'outlineOnly': true,
  'linePattern': ?lp,
};

Map<String, dynamic> cell(
  List<Map<String, dynamic>> layerData, {
  int count = 1,
}) {
  if (layerData.length == 1 && count == 1) {
    return layerData[0];
  }
  return {
    'type': layerData[0]['type'],
    'color': layerData[0]['color'],
    'rotationDeg': layerData[0]['rotationDeg'] ?? 0,
    'scale': layerData[0]['scale'] ?? 1.0,
    'count': count,
    'layers': layerData,
  };
}

List<Map<String, dynamic>> makeOpts(Map<String, dynamic> ok, Random rng) {
  final opts = <Map<String, dynamic>>[ok];
  int attempts = 0;
  while (opts.length < 6 && attempts < 200) {
    attempts++;
    final r = rng.nextDouble();
    Map<String, dynamic> w;
    if (ok.containsKey('layers')) {
      final layers = ok['layers'] as List;
      if (r < 0.3 && layers.length > 1) {
        w = cell([layers[0] as Map<String, dynamic>]);
      } else if (r < 0.5) {
        final newLayers = layers.map((l) {
          final m = Map<String, dynamic>.from(l as Map);
          m['color'] = rc();
          return m;
        }).toList();
        w = cell(List<Map<String, dynamic>>.from(newLayers));
      } else if (r < 0.7) {
        final newLayers = layers.map((l) {
          final m = Map<String, dynamic>.from(l as Map);
          m['type'] = rs();
          return m;
        }).toList();
        w = cell(List<Map<String, dynamic>>.from(newLayers));
      } else {
        w = cell([shape(rs(), rc())]);
      }
    } else {
      if (r < 0.25) {
        w = shape(ok['type'] as String, rc());
      } else if (r < 0.45) {
        w = shape(rs(), ok['color'] as int);
      } else if (r < 0.6) {
        w = shape(rs(), rc());
      } else if (r < 0.75) {
        w = shape(
          ok['type'] as String,
          rc(),
          o: !(ok['outlineOnly'] as bool? ?? false),
        );
      } else {
        w = shape(ok['type'] as String, rc(), lp: rlp());
      }
    }
    final isDup = opts.any((o) => jsonEncode(o) == jsonEncode(w));
    if (!isDup) opts.add(w);
  }
  while (opts.length < 6) {
    opts.add(shape(rs(), rc()));
  }
  opts.shuffle(rng);
  return opts;
}

int findCorrectIndex(List<Map<String, dynamic>> opts, Map<String, dynamic> ok) {
  for (int i = 0; i < opts.length; i++) {
    if (jsonEncode(opts[i]) == jsonEncode(ok)) return i;
  }
  return 0;
}

Map<String, dynamic> q(
  String pattern,
  List<Map<String, dynamic>> seq,
  List<Map<String, dynamic>> opts,
  int ci,
  bool isMatrix,
) => {
  'sequence': seq,
  'options': opts,
  'correctOptionIndex': ci,
  'pattern': pattern,
  'isMatrix': isMatrix,
};

// ═══════════════════════════════════════════════════════════
// GRUP A: Temel Kalıplar
// ═══════════════════════════════════════════════════════════

Map<String, dynamic> genCountIncrement(int level, int order) {
  final sh = rs();
  final c1 = rc();
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    seq.add(cell([shape(sh, c1)], count: i + 1));
  }
  final ok = cell([shape(sh, c1)], count: 9);
  return q(
    'countIncrement',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

Map<String, dynamic> genColorCycle(int level, int order) {
  final sh = rs();
  final cl = level <= 20 ? 3 : (level <= 50 ? 4 : 5);
  final cols = List<int>.from(shapeColors)..shuffle(rng);
  final cc = cols.take(cl).toList();
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    seq.add(cell([shape(sh, cc[i % cl])]));
  }
  final ok = cell([shape(sh, cc[8 % cl])]);
  return q(
    'colorCycle',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

Map<String, dynamic> genOutlineToggle(int level, int order) {
  final sh = rs();
  final c = rc();
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    seq.add(cell([shape(sh, c, o: i % 2 == 1)]));
  }
  final ok = cell([shape(sh, c)]);
  return q(
    'outlineToggle',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

Map<String, dynamic> genRotationBasic(int level, int order) {
  final sh = rs();
  final c = rc();
  final step = level <= 30 ? 45.0 : (level <= 60 ? 30.0 : 22.5);
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    seq.add(cell([shape(sh, c, r: step * i)]));
  }
  final ok = cell([shape(sh, c, r: step * 8)]);
  return q(
    'rotationBasic',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

Map<String, dynamic> genScaleProgression(int level, int order) {
  final sh = rs();
  final c = rc();
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    seq.add(cell([shape(sh, c, sc: 0.5 + 0.15 * i)]));
  }
  final ok = cell([shape(sh, c, sc: 0.5 + 0.15 * 8)]);
  return q(
    'scaleProgression',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

Map<String, dynamic> genLinePatternCycle(int level, int order) {
  final sh = rs();
  final c = rc();
  final patterns = ['horizontal', 'vertical', 'cross', 'diagonal'];
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    seq.add(cell([shape(sh, c, lp: patterns[i % patterns.length])]));
  }
  final ok = cell([shape(sh, c, lp: patterns[8 % patterns.length])]);
  return q(
    'linePatternCycle',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

Map<String, dynamic> genSymmetryOutline(int level, int order) {
  final sh = rs();
  final c = rc();
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    seq.add(cell([shape(sh, c, o: i % 2 == 0)]));
  }
  final ok = cell([shape(sh, c, o: true)]);
  return q(
    'symmetryOutline',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

Map<String, dynamic> genCountdownShrink(int level, int order) {
  final sh = rs();
  final c = rc();
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    seq.add(cell([shape(sh, c, sc: 1.5 - 0.12 * i)]));
  }
  final ok = cell([shape(sh, c, sc: 1.5 - 0.12 * 8)]);
  return q(
    'countdownShrink',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

Map<String, dynamic> genInnerShapeEvolution(int level, int order) {
  final sh = rs();
  final c = rc();
  final innerShapes = ['circle', 'square', 'triangle', 'diamond'];
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    final inner = innerShapes[i % innerShapes.length];
    seq.add(cell([shape(sh, c), shape(inner, rc(), sc: 0.4)]));
  }
  final ok = cell([
    shape(sh, c),
    shape(innerShapes[8 % innerShapes.length], rc(), sc: 0.4),
  ]);
  return q(
    'innerShapeEvolution',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

Map<String, dynamic> genScaleColorPair(int level, int order) {
  final sh = rs();
  final c1 = rc();
  final c2 = rc();
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    seq.add(
      cell([shape(sh, i % 2 == 0 ? c1 : c2, sc: i % 2 == 0 ? 0.6 : 1.2)]),
    );
  }
  final ok = cell([shape(sh, c1, sc: 0.6)]);
  return q(
    'scaleColorPair',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

Map<String, dynamic> genMirrorSymmetry(int level, int order) {
  final sh = rs();
  final c = rc();
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    seq.add(cell([shape(sh, c, r: i % 2 == 0 ? 0 : 180)]));
  }
  final ok = cell([shape(sh, c, r: 0)]);
  return q(
    'mirrorSymmetry',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

Map<String, dynamic> genSimpleMatrix3x3(int level, int order) {
  final cols = List<int>.from(shapeColors)..shuffle(rng);
  final cc = cols.take(3).toList();
  final shs = [rs(), rs(), rs()];
  final seq = <Map<String, dynamic>>[];
  for (int row = 0; row < 3; row++) {
    for (int col = 0; col < 3; col++) {
      if (row == 2 && col == 2) continue;
      seq.add(cell([shape(shs[row], cc[col])]));
    }
  }
  final ok = cell([shape(shs[2], cc[2])]);
  return q(
    'simpleMatrix3x3',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    true,
  );
}

// ═══════════════════════════════════════════════════════════
// GRUP B: Orta Kalıplar (çoklu katmanlı)
// ═══════════════════════════════════════════════════════════

/// Örnek: Üst üste iki şekil (triangle on circle)
Map<String, dynamic> genShapeStack(int level, int order) {
  final sh1 = rs();
  final sh2 = rs();
  final c1 = rc();
  final c2 = rc();
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    final rotateSecond = (level > 30 && i % 2 == 1);
    seq.add(
      cell([
        shape(sh1, c1, sc: 0.9),
        shape(sh2, c2, sc: 0.6, r: rotateSecond ? 45.0 * i : 0),
      ]),
    );
  }
  final ok = cell([shape(sh1, c1, sc: 0.9), shape(sh2, c2, sc: 0.6)]);
  return q(
    'shapeStack',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

/// Örnek: İç içe şekil evrimi (dış sabit, iç değişir)
Map<String, dynamic> genNestedEvolution(int level, int order) {
  final outerSh = rs();
  final outerC = rc();
  final inners = [
    'circle',
    'square',
    'triangle',
    'diamond',
    'pentagon',
    'hexagon',
  ];
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    final innerIdx = (i * (level > 40 ? 2 : 1)) % inners.length;
    seq.add(
      cell([shape(outerSh, outerC), shape(inners[innerIdx], rc(), sc: 0.4)]),
    );
  }
  final ok = cell([
    shape(outerSh, outerC),
    shape(inners[(8 * (level > 40 ? 2 : 1)) % inners.length], rc(), sc: 0.4),
  ]);
  return q(
    'nestedEvolution',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

/// Örnek: Shape composition — her adımda bir katman eklenir
Map<String, dynamic> genAdditiveComposition(int level, int order) {
  final baseSh = rs();
  final baseC = rc();
  final extras = [rs(), rs(), rs()];
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    final layers = <Map<String, dynamic>>[shape(baseSh, baseC, sc: 0.8)];
    final addCount = (i ~/ 2).clamp(0, extras.length);
    for (int j = 0; j < addCount; j++) {
      layers.add(shape(extras[j], rc(), sc: 0.4));
    }
    seq.add(cell(layers));
  }
  final ok = cell([
    shape(baseSh, baseC, sc: 0.8),
    shape(extras[0], rc(), sc: 0.4),
    shape(extras[1], rc(), sc: 0.4),
  ]);
  return q(
    'additiveComposition',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

/// Örnek: Shape + line overlay (şekil üstüne çizgi)
Map<String, dynamic> genShapeLineOverlay(int level, int order) {
  final sh = rs();
  final c = rc();
  final patterns = [
    'horizontal',
    'vertical',
    'cross',
    'diagonal',
    'plus',
    'minus',
    'times',
    'dot',
  ];
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    seq.add(cell([shape(sh, c, lp: patterns[i % patterns.length])]));
  }
  final ok = cell([shape(sh, c, lp: patterns[8 % patterns.length])]);
  return q(
    'shapeLineOverlay',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

/// Örnek: Renk döngüsü + outlineToggle (iki bağımsız döngü)
Map<String, dynamic> genDualCycle(int level, int order) {
  final sh = rs();
  final c1 = rc();
  final c2 = rc();
  final c3 = rc();
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    final color = [c1, c2, c3][i % 3];
    final outline = i % 2 == 1;
    seq.add(cell([shape(sh, color, o: outline)]));
  }
  final ok = cell([shape(sh, c1, o: false)]);
  return q(
    'dualCycle',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

/// Örnek: Grid convergence — count azalırken boyut artar
Map<String, dynamic> genGridConvergence(int level, int order) {
  final sh = rs();
  final c = rc();
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    final cnt = (8 - i).clamp(1, 5);
    final sz = 0.5 + (i * 0.12);
    seq.add(cell([shape(sh, c, sc: sz)], count: cnt));
  }
  final ok = cell([shape(sh, c, sc: 0.5 + 8 * 0.12)], count: 1);
  return q(
    'gridConvergence',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

/// Örnek: Shape type change (şekil tipi değişir, renk sabit)
Map<String, dynamic> genShapeTypeProgression(int level, int order) {
  final c = rc();
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    seq.add(cell([shape(shapes[i % shapes.length], c)]));
  }
  final ok = cell([shape(shapes[8 % shapes.length], c)]);
  return q(
    'shapeTypeProgression',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

/// Örnek: Rotation + outline (iki bağımsız özellik)
Map<String, dynamic> genRotationOutlineCombo(int level, int order) {
  final sh = rs();
  final c = rc();
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    seq.add(cell([shape(sh, c, r: 45.0 * i, o: i % 3 == 2)]));
  }
  final ok = cell([shape(sh, c, r: 45.0 * 8, o: false)]);
  return q(
    'rotationOutlineCombo',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

/// Örnek: Color alternation + scale
Map<String, dynamic> genColorScaleAlt(int level, int order) {
  final sh = rs();
  final c1 = rc();
  final c2 = rc();
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    final useC1 = i % 2 == 0;
    final sc = useC1 ? 0.7 : 1.1;
    seq.add(cell([shape(sh, useC1 ? c1 : c2, sc: sc)]));
  }
  final ok = cell([shape(sh, c1, sc: 0.7)]);
  return q(
    'colorScaleAlt',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

// ═══════════════════════════════════════════════════════════
// GRUP C: İleri Kalıplar
// ═══════════════════════════════════════════════════════════

/// Örnek: Full attribute matrix (3x3, her satırda şekil, her sütunda renk)
Map<String, dynamic> genFullAttributeMatrix(int level, int order) {
  final shs = [rs(), rs(), rs()];
  final cols = List<int>.from(shapeColors)..shuffle(rng);
  final cc = cols.take(3).toList();
  final seq = <Map<String, dynamic>>[];
  for (int row = 0; row < 3; row++) {
    for (int col = 0; col < 3; col++) {
      if (row == 2 && col == 2) continue;
      final layers = <Map<String, dynamic>>[shape(shs[row], cc[col])];
      if (level > 50 && row == col) {
        layers.add(shape(rs(), rc(), sc: 0.35));
      }
      seq.add(cell(layers));
    }
  }
  final ok = cell([shape(shs[2], cc[2])]);
  return q(
    'fullAttributeMatrix',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    true,
  );
}

/// Örnek: Transformation chain (A→B→C→D)
Map<String, dynamic> genTransformationChain(int level, int order) {
  final baseC = rc();
  final seq = <Map<String, dynamic>>[];
  final chainShapes = [
    'circle',
    'square',
    'triangle',
    'pentagon',
    'hexagon',
    'star',
    'diamond',
    'oval',
  ];
  for (int i = 0; i < 8; i++) {
    final layers = <Map<String, dynamic>>[
      shape(chainShapes[i], baseC, r: 30.0 * i),
    ];
    if (level > 30 && i > 2) {
      layers.add(
        shape(chainShapes[(i - 1) % chainShapes.length], rc(), sc: 0.35),
      );
    }
    seq.add(cell(layers));
  }
  final ok = cell([
    shape(chainShapes[8 % chainShapes.length], baseC, r: 30.0 * 8),
  ]);
  return q(
    'transformationChain',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

/// Örnek: Multi-variable chain (şekil, renk, boyut farklı hızlarda değişir)
Map<String, dynamic> genMultiVariableChain(int level, int order) {
  final seq = <Map<String, dynamic>>[];
  final cols = [rc(), rc(), rc(), rc()];
  for (int i = 0; i < 8; i++) {
    final sh = shapes[i % shapes.length];
    final c = cols[i % cols.length];
    final sc = 0.6 + (i % 3) * 0.2;
    seq.add(cell([shape(sh, c, sc: sc, r: 45.0 * (i % 4))]));
  }
  final ok = cell([
    shape(shapes[8 % shapes.length], cols[8 % cols.length], sc: 0.6, r: 0),
  ]);
  return q(
    'multiVariableChain',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

/// Örnek: XOR mantığı (outlineOnly)
Map<String, dynamic> genXorLogic(int level, int order) {
  final sh = rs();
  final c1 = rc();
  final c2 = rc();
  final c3 = rc();
  final seq = <Map<String, dynamic>>[];
  for (int row = 0; row < 3; row++) {
    for (int col = 0; col < 3; col++) {
      if (row == 2 && col == 2) continue;
      final color = col == 0 ? c1 : (col == 1 ? c2 : c3);
      final isOutline = (row + col) % 2 == 1;
      seq.add(cell([shape(sh, color, o: isOutline)]));
    }
  }
  final ok = cell([shape(sh, c3, o: true)]);
  return q(
    'xorLogic',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    true,
  );
}

/// Örnek: Latin square (her şekil satırda/sütunda bir kez)
Map<String, dynamic> genLatinSquare(int level, int order) {
  final usedShapes = shapes.take(4).toList()..shuffle(rng);
  final usedColors = [rc(), rc(), rc(), rc()];
  final seq = <Map<String, dynamic>>[];

  final grid = [
    [0, 1, 2],
    [1, 2, 3],
    [2, 3, 0],
  ];

  for (int row = 0; row < 3; row++) {
    for (int col = 0; col < 3; col++) {
      if (row == 2 && col == 2) continue;
      final idx = grid[row][col];
      seq.add(cell([shape(usedShapes[idx], usedColors[idx])]));
    }
  }
  final ok = cell([shape(usedShapes[grid[2][2]], usedColors[grid[2][2]])]);
  return q(
    'latinSquare',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    true,
  );
}

/// Örnek: Matrix with exception
Map<String, dynamic> genMatrixWithException(int level, int order) {
  final sh = rs();
  final c1 = rc();
  final c2 = rc();
  final seq = <Map<String, dynamic>>[];
  for (int row = 0; row < 3; row++) {
    for (int col = 0; col < 3; col++) {
      if (row == 2 && col == 2) continue;
      final isException = (row == 1 && col == 1);
      final layers = <Map<String, dynamic>>[
        shape(sh, isException ? c2 : c1, o: isException),
      ];
      if (isException && level > 40) {
        layers.add(shape(rs(), rc(), sc: 0.35));
      }
      seq.add(cell(layers));
    }
  }
  final ok = cell([shape(sh, c1)]);
  return q(
    'matrixWithException',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    true,
  );
}

/// Örnek: Weighted combo
Map<String, dynamic> genWeightedCombo(int level, int order) {
  final sh = rs();
  final c1 = rc();
  final c2 = rc();
  final c3 = rc();
  final seq = <Map<String, dynamic>>[];
  for (int i = 0; i < 8; i++) {
    final weight = i % 3;
    final color = weight == 0 ? c1 : (weight == 1 ? c2 : c3);
    final layers = <Map<String, dynamic>>[
      shape(sh, color, sc: 0.7 + 0.1 * weight),
    ];
    if (weight == 2) {
      layers.add(shape(rs(), rc(), sc: 0.3));
    }
    seq.add(cell(layers));
  }
  final ok = cell([shape(sh, c1, sc: 0.7)]);
  return q(
    'weightedCombo',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

/// Örnek: Shape decomposition (composite → parts)
Map<String, dynamic> genShapeDecomposition(int level, int order) {
  final sh1 = rs();
  final sh2 = rs();
  final c1 = rc();
  final c2 = rc();
  final seq = <Map<String, dynamic>>[];

  for (int i = 0; i < 8; i++) {
    if (i % 3 == 0) {
      seq.add(cell([shape(sh1, c1, sc: 0.9), shape(sh2, c2, sc: 0.5)]));
    } else if (i % 3 == 1) {
      seq.add(cell([shape(sh1, c1, sc: 0.9)]));
    } else {
      seq.add(cell([shape(sh2, c2, sc: 0.7)]));
    }
  }

  final ok = cell([shape(sh1, c1, sc: 0.9), shape(sh2, c2, sc: 0.5)]);
  return q(
    'shapeDecomposition',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    false,
  );
}

/// Örnek: Nested shape matrix (dış şekil sabit, iç şekil matris mantığıyla)
Map<String, dynamic> genNestedShapeMatrix(int level, int order) {
  final outerSh = rs();
  final inners = ['circle', 'square', 'triangle'];
  final cols = [rc(), rc(), rc()];
  final seq = <Map<String, dynamic>>[];
  for (int row = 0; row < 3; row++) {
    for (int col = 0; col < 3; col++) {
      if (row == 2 && col == 2) continue;
      seq.add(
        cell([shape(outerSh, cols[col]), shape(inners[row], rc(), sc: 0.4)]),
      );
    }
  }
  final ok = cell([shape(outerSh, cols[2]), shape(inners[2], rc(), sc: 0.4)]);
  return q(
    'nestedShapeMatrix',
    seq,
    makeOpts(ok, rng),
    findCorrectIndex(makeOpts(ok, rng), ok),
    true,
  );
}

// ═══════════════════════════════════════════════════════════
// GRUP D: Çizgi Kayıp Parça Soruları
// ═══════════════════════════════════════════════════════════

Map<String, dynamic> lineQ(
  List<Map<String, dynamic>> lines,
  double mx,
  double my,
  double mw,
  double mh,
) {
  return {
    'sequence': [],
    'options': [],
    'correctOptionIndex': 0,
    'pattern': 'linePattern',
    'isMatrix': false,
    'linePattern': {
      'lines': lines,
      'missingX': mx,
      'missingY': my,
      'missingW': mw,
      'missingH': mh,
    },
  };
}

Map<String, dynamic> line(
  double x1,
  double y1,
  double x2,
  double y2,
  int color, {
  double sw = 3.0,
}) {
  return {
    'x1': x1,
    'y1': y1,
    'x2': x2,
    'y2': y2,
    'color': color,
    'strokeWidth': sw,
  };
}

double rr() => rng.nextDouble();
double rra(double min, double max) => min + rng.nextDouble() * (max - min);
int rlc() => lineColors[rng.nextInt(lineColors.length)];

/// Soru 1: Kesişim Yıldızı - 4-5 çizgi tek noktada kesişir
Map<String, dynamic> genLineIntersection(int level, int order) {
  final numLines = 4 + (level / 30).floor().clamp(0, 2);
  final cx = 0.4 + rr() * 0.2;
  final cy = 0.35 + rr() * 0.3;
  final lines = <Map<String, dynamic>>[];
  final usedColors = <int>{};
  for (int i = 0; i < numLines; i++) {
    int c;
    do {
      c = rlc();
    } while (usedColors.contains(c) && usedColors.length < lineColors.length);
    usedColors.add(c);
    final angle = (2 * pi * i / numLines) + rr() * 0.3;
    final len = 0.4 + rr() * 0.3;
    lines.add(
      line(
        cx - cos(angle) * len,
        cy - sin(angle) * len,
        cx + cos(angle) * len,
        cy + sin(angle) * len,
        c,
        sw: 2.5 + rr() * 3.0,
      ),
    );
  }
  final mx = (cx - 0.18).clamp(0.0, 0.5);
  final my = (cy - 0.2).clamp(0.0, 0.5);
  return lineQ(lines, mx, my, 0.36, 0.4);
}

/// Soru 2: Radyal Patlama - 5-6 çizgi merkezden dışarı
Map<String, dynamic> genLineStarburst(int level, int order) {
  final numLines = 5 + (level / 40).floor().clamp(0, 1);
  final cx = 0.5;
  final cy = 0.5;
  final lines = <Map<String, dynamic>>[];
  final usedColors = <int>{};
  for (int i = 0; i < numLines; i++) {
    int c;
    do {
      c = rlc();
    } while (usedColors.contains(c) && usedColors.length < lineColors.length);
    usedColors.add(c);
    final angle = (2 * pi * i / numLines) + rr() * 0.2;
    final innerR = 0.05 + rr() * 0.1;
    final outerR = 0.35 + rr() * 0.15;
    lines.add(
      line(
        cx + cos(angle) * innerR,
        cy + sin(angle) * innerR,
        cx + cos(angle) * outerR,
        cy + sin(angle) * outerR,
        c,
        sw: 3.0 + rr() * 3.0,
      ),
    );
  }
  return lineQ(lines, 0.32, 0.32, 0.36, 0.36);
}

/// Soru 3: Paralel Kayma - 4-5 paralel çizgi
Map<String, dynamic> genLineParallelShift(int level, int order) {
  final numLines = 4 + (level / 35).floor().clamp(0, 1);
  final angle = rra(-0.3, 0.3);
  final baseY = 0.2;
  final spacing = 0.6 / (numLines + 1);
  final lines = <Map<String, dynamic>>[];
  final usedColors = <int>{};
  for (int i = 0; i < numLines; i++) {
    int c;
    do {
      c = rlc();
    } while (usedColors.contains(c) && usedColors.length < lineColors.length);
    usedColors.add(c);
    final y = baseY + spacing * (i + 1);
    final yOffset = rr() * 0.08;
    lines.add(
      line(
        0.05,
        y + yOffset + angle * 0.1,
        0.95,
        y + yOffset - angle * 0.1,
        c,
        sw: 2.0 + i * 0.8,
      ),
    );
  }
  return lineQ(lines, 0.35, 0.3, 0.3, 0.4);
}

/// Soru 4: Dokuma Deseni - 5-7 çizgi çapraz kesişim
Map<String, dynamic> genLineWeave(int level, int order) {
  final numLines = 5 + (level / 30).floor().clamp(0, 2);
  final lines = <Map<String, dynamic>>[];
  final usedColors = <int>{};
  for (int i = 0; i < numLines; i++) {
    int c;
    do {
      c = rlc();
    } while (usedColors.contains(c) && usedColors.length < lineColors.length);
    usedColors.add(c);
    final up = i % 2 == 0;
    final y1 = up ? 0.9 : 0.1;
    final y2 = up ? 0.1 : 0.9;
    final x1 = rr() * 0.3;
    final x2 = 0.7 + rr() * 0.3;
    lines.add(line(x1, y1, x2, y2, c, sw: 2.5 + rr() * 2.5));
  }
  final mx = 0.25 + rr() * 0.2;
  final my = 0.25 + rr() * 0.2;
  return lineQ(lines, mx, my, 0.35, 0.35);
}

/// Soru 5: Köşe Yakınsaması - 4-6 çizgi köşelerden merkeze
Map<String, dynamic> genLineConverge(int level, int order) {
  final numLines = 4 + (level / 35).floor().clamp(0, 2);
  final cx = 0.45 + rr() * 0.1;
  final cy = 0.4 + rr() * 0.2;
  final corners = [
    [0.0, 0.0],
    [1.0, 0.0],
    [0.0, 1.0],
    [1.0, 1.0],
    [0.0, 0.5],
    [1.0, 0.5],
    [0.5, 0.0],
    [0.5, 1.0],
  ];
  final lines = <Map<String, dynamic>>[];
  final usedColors = <int>{};
  final usedCorners = <int>{};
  for (int i = 0; i < numLines; i++) {
    int c;
    do {
      c = rlc();
    } while (usedColors.contains(c) && usedColors.length < lineColors.length);
    usedColors.add(c);
    int ci;
    do {
      ci = rng.nextInt(corners.length);
    } while (usedCorners.contains(ci));
    usedCorners.add(ci);
    final corner = corners[ci];
    lines.add(
      line(
        corner[0],
        corner[1],
        cx + rr() * 0.1 - 0.05,
        cy + rr() * 0.1 - 0.05,
        c,
        sw: 2.5 + rr() * 3.0,
      ),
    );
  }
  return lineQ(lines, 0.33, 0.3, 0.34, 0.35);
}

/// Soru 6: Kaotik Çapraz - 6-7 rastgele çizgi
Map<String, dynamic> genLineChaos(int level, int order) {
  final numLines = 6 + (level / 40).floor().clamp(0, 1);
  final lines = <Map<String, dynamic>>[];
  final usedColors = <int>{};
  for (int i = 0; i < numLines; i++) {
    int c;
    do {
      c = rlc();
    } while (usedColors.contains(c) && usedColors.length < lineColors.length);
    usedColors.add(c);
    lines.add(line(rr(), rr(), rr(), rr(), c, sw: 2.0 + rr() * 4.0));
  }
  final mx = 0.2 + rr() * 0.3;
  final my = 0.2 + rr() * 0.3;
  return lineQ(lines, mx, my, 0.3 + rr() * 0.15, 0.3 + rr() * 0.15);
}

// ═══════════════════════════════════════════════════════════
// Kalıp Seçici
// ═══════════════════════════════════════════════════════════

typedef PatternGen = Map<String, dynamic> Function(int level, int order);

List<PatternGen> getPatternsForLevel(int level) {
  if (level <= 10) {
    return [
      genCountIncrement,
      genColorCycle,
      genOutlineToggle,
      genRotationBasic,
      genShapeStack,
      genLineIntersection,
    ];
  } else if (level <= 20) {
    return [
      genShapeStack,
      genNestedEvolution,
      genColorCycle,
      genDualCycle,
      genShapeLineOverlay,
      genLineIntersection,
      genLineParallelShift,
    ];
  } else if (level <= 30) {
    return [
      genAdditiveComposition,
      genGridConvergence,
      genShapeTypeProgression,
      genRotationOutlineCombo,
      genColorScaleAlt,
      genLineParallelShift,
      genLineStarburst,
    ];
  } else if (level <= 40) {
    return [
      genFullAttributeMatrix,
      genLatinSquare,
      genTransformationChain,
      genShapeDecomposition,
      genNestedShapeMatrix,
      genLineStarburst,
      genLineConverge,
    ];
  } else if (level <= 50) {
    return [
      genMultiVariableChain,
      genXorLogic,
      genMatrixWithException,
      genNestedEvolution,
      genAdditiveComposition,
      genLineConverge,
      genLineWeave,
    ];
  } else if (level <= 60) {
    return [
      genWeightedCombo,
      genFullAttributeMatrix,
      genLatinSquare,
      genTransformationChain,
      genShapeDecomposition,
      genLineWeave,
      genLineConverge,
    ];
  } else if (level <= 70) {
    return [
      genMultiVariableChain,
      genXorLogic,
      genNestedShapeMatrix,
      genWeightedCombo,
      genMatrixWithException,
      genLineWeave,
      genLineChaos,
    ];
  } else if (level <= 80) {
    return [
      genFullAttributeMatrix,
      genLatinSquare,
      genTransformationChain,
      genXorLogic,
      genAdditiveComposition,
      genLineChaos,
      genLineWeave,
    ];
  } else if (level <= 90) {
    return [
      genMultiVariableChain,
      genNestedShapeMatrix,
      genWeightedCombo,
      genShapeDecomposition,
      genMatrixWithException,
      genLineChaos,
      genLineConverge,
    ];
  } else {
    return [
      genFullAttributeMatrix,
      genLatinSquare,
      genXorLogic,
      genMultiVariableChain,
      genTransformationChain,
      genWeightedCombo,
      genLineChaos,
      genLineWeave,
    ];
  }
}

// ═══════════════════════════════════════════════════════════
// Ana Fonksiyon
// ═══════════════════════════════════════════════════════════

Future<void> main() async {
  final outputDir = Directory('assets/questions');
  if (!outputDir.existsSync()) outputDir.createSync(recursive: true);

  for (int level = 1; level <= 100; level++) {
    if (level >= 1 && level <= 3) continue;

    final patterns = getPatternsForLevel(level);
    final qs = <Map<String, dynamic>>[];

    for (int qi = 0; qi < 20; qi++) {
      final gen = patterns[qi % patterns.length];
      final qData = gen(level, qi + 1);
      qData['id'] = 'L${level}_Q${qi + 1}';
      qData['level'] = level;
      qData['orderInLevel'] = qi + 1;
      qs.add(qData);
    }

    final ls = level.toString().padLeft(3, '0');
    await File('assets/questions/level_$ls.json').writeAsString(jsonEncode(qs));
    stdout.write('\rGenerated level $level/100');
  }
  stdout.writeln('\nDone! Generated levels 4-100.');
}
