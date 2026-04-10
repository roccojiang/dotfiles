import {
  DeviceIdentifier,
  to$,
} from 'karabiner.ts';

export const anyOf = (
  ...ids: (DeviceIdentifier | DeviceIdentifier[])[]
) => ids.flat()


export function raycastExtension(link: string) {
  return to$(`open raycast://extensions/${link}`)
}

export function raycastWindow(window: string) {
  return to$(`open -g raycast://extensions/raycast/window-management/${window}`)
}
