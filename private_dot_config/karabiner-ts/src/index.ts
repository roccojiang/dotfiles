import {
  hyperLayer,
  layer,
  map,
  NumberKeyValue,
  rule,
  withMapper,
  writeToProfile,
} from 'karabiner.ts'

import {
  raycastExtension,
} from './utils'

writeToProfile('Default', [

  rule('Tab → Hyper').manipulators([
    map('tab').toHyper({ lazy: true }).toIfAlone('tab'),
  ]),

  rule('Caps Lock → Control/Escape').manipulators([
    map('caps_lock', { optional: 'any'}).to('left_control', undefined, { lazy: true }).toIfAlone('escape'),
  ]),
])
