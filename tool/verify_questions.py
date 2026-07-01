import json

for lvl in [1, 2, 3]:
    fn = f'assets/questions/level_{lvl:03d}.json'
    with open(fn) as f:
        qs = json.load(f)
    print(f'Level {lvl}: {len(qs)} questions')
    for q in qs:
        assert len(q['sequence']) == 8, f'Sequence wrong length in {q["id"]}'
        assert len(q['options']) == 6, f'Options wrong length in {q["id"]}'
        ci = q['correctOptionIndex']
        assert 0 <= ci < 6, f'Correct option index out of range in {q["id"]}'
        for spec in q['sequence'] + q['options']:
            assert 'type' in spec and 'color' in spec
            if 'outlineOnly' in spec:
                assert isinstance(spec['outlineOnly'], bool)
            if 'innerShape' in spec:
                valid_shapes = ['circle','square','triangle','pentagon','hexagon','oval','star','diamond']
                assert spec['innerShape'] in valid_shapes, f'Invalid innerShape in {q["id"]}'
            if 'linePattern' in spec:
                valid_lp = ['none','horizontal','vertical','cross','diagonal']
                assert spec['linePattern'] in valid_lp, f'Invalid linePattern in {q["id"]}'
    print('  All valid!')
print('All 3 levels verified OK')
