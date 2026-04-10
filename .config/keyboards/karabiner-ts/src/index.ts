import {
  ifApp,
  ifDevice,
  layer,
  map,
  rule,
  writeToProfile,
} from 'karabiner.ts'

import { anyOf } from './utils'

const HHKB_DEVICE = { vendor_id: 1278, product_id: 33 }
const QK75_DEVICE = [
  { vendor_id: 1452, product_id: 591 },   // BLE connection
  { vendor_id: 3141, product_id: 32791 }, // USB/native connection
]

writeToProfile('Default', [

  rule(
    'HHKB Control -> Control/Escape',
    ifDevice(HHKB_DEVICE)
  ).manipulators([
    map('left_control', { optional: 'any' }).to('left_control', undefined, { lazy: true }).toIfAlone('escape'),
  ]),

  rule('Caps Lock → Control/Escape').manipulators([
    map('caps_lock', { optional: 'any' }).to('left_control', undefined, { lazy: true }).toIfAlone('escape'),
  ]),

  rule(
    'Left Control → Hyper',
    ifDevice(anyOf(
      QK75_DEVICE,
      { is_built_in_keyboard: true }
    ))
  ).manipulators([
    map('left_control').toHyper()
      .condition(ifApp('Terraria').unless()), // ctrl-click in Terraria
  ]),

  // See: https://karabiner-elements.pqrs.org/docs/help/how-to/function-keys/
  layer('f20', 'QK75 Fn Keys') // right split-backspace key mapped to F20 in QK Config
    .condition(ifDevice(QK75_DEVICE, 'QK75 KB (BLE/USB)'))
    .configKey((key) => key.toIfAlone('vk_none'), true)
    .manipulators([
      map('f1').to('f1', 'fn'),
      map('f2').to('f2', 'fn'),
      map('f3').to('f3', 'fn'),
      map('f4').to('f4', 'fn'),
      map('f5').to('f5', 'fn'),
      map('f6').to('f6', 'fn'),
      map('f7').to('f7', 'fn'),
      map('f8').to('f8', 'fn'),
      map('f9').to('f9', 'fn'),
      map('f10').to('f10', 'fn'),
      map('f11').to('f11', 'fn'),
      map('f12').to('f12', 'fn'),
    ]),
])
