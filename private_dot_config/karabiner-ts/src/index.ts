import {
  ifDevice, map, rule, writeToProfile
} from 'karabiner.ts'

writeToProfile('Default', [

  rule('Caps Lock → Control/Escape').manipulators([
    map('caps_lock', { optional: 'any' }).to('left_control', undefined, { lazy: true }).toIfAlone('escape'),
  ]),

  rule('HHKB Control -> Control/Escape', ifDevice({ vendor_id: 1278, product_id: 33 }, 'HHKB-Hybrid_1')).manipulators([
    map('left_control', { optional: 'any' }).to('left_control', undefined, { lazy: true }).toIfAlone('escape'),
  ]),

  rule('Left Control → Hyper').manipulators([
    map('left_control').toHyper(),
  ]),

  rule('Space Cadet shift').manipulators([
    map('left_shift', { optional: 'any' }).to('left_shift').toIfAlone('9', 'shift'),
    map('right_shift', { optional: 'any' }).to('right_shift').toIfAlone('0', 'shift')
  ]),
])
