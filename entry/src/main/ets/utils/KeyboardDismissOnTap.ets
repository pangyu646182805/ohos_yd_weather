import { KeyboardUtil } from '@pura/harmony-utils'

export class KeyboardDismissOnTap implements AttributeModifier<CommonAttribute> {
  applyNormalAttribute(instance: CommonAttribute): void {
    instance.onTouch(e => {
      if (e.type == TouchType.Up) {
        KeyboardUtil.hide()
      }
    })
  }
}