import { curves } from "@kit.ArkUI"
import { Constants } from "../constants/Constants"
import { ColorUtils } from "../utils/ColorUtils"

const ITEM_HEIGHT: number = 48

@ComponentV2
export struct WeatherCardSortListItem {
  @Param @Require weatherCardItemType: number
  @Param index: number = 0
  @Param length: number = 0
  @Event onReorderStart?: () => boolean = undefined
  @Event beforeChange?: (target: number) => boolean = undefined
  @Event onChangeItem?: (from: number, to: number) => void = undefined
  @Event onReorderDone?: () => void = undefined
  @Event onWeatherObserveSortTap?: () => void = undefined
  private isLongPress: boolean = false
  private isMenuPress: boolean = false
  private dragRefOffset: number = 0
  @Local zIndexValue: number = 0
  @Local offsetY: number = 0

  build() {
    ListItem() {
      Row() {
        Row() {
          Text(this.title)
            .fontSize(16)
            .fontColor($r('app.color.black'))
            .fontWeight(FontWeight.Bold)
          Image($r('app.media.ic_sort_icon'))
            .width(18)
            .height(18)
            .colorFilter(ColorUtils.translateColor($r('app.color.color_999999')))
            .margin({ left: 8 })
            .draggable(false)
            .visibility(this.weatherCardItemType == Constants.ITEM_TYPE_OBSERVE ? Visibility.Visible :
            Visibility.Hidden)
        }

        Image($r('app.media.ic_menu_icon'))
          .width(24)
          .height(24)
          .colorFilter(ColorUtils.translateColor($r('app.color.color_999999')))
          .draggable(false)
          .gesture(
            GestureGroup(GestureMode.Sequence,
              PanGesture()
                .onActionStart(() => {
                  this.onMenuPress()
                })
                .onActionUpdate((event: GestureEvent) => {
                  this.onItemMove(event.offsetY)
                })
                .onActionEnd(() => {
                  this.onItemDrop()
                })
            ).onCancel(() => {
              if (!this.isMenuPress) {
                return;
              }
              this.onItemDrop()
            })
          )
      }
      .width('100%')
      .height(ITEM_HEIGHT)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('app.color.card_color_06'))
      .borderRadius(6)
      .padding({ left: 16, right: 16 })
      .gesture(
        GestureGroup(GestureMode.Sequence,
          LongPressGesture()
            .onAction(() => {
              this.onLongPress()
            }),
          PanGesture()
            .onActionUpdate((event: GestureEvent) => {
              this.onItemMove(event.offsetY)
            })
            .onActionEnd(() => {
              this.onItemDrop()
            })
        ).onCancel(() => {
          if (!this.isLongPress) {
            return
          }
          this.onItemDrop()
        })
      )
      .onClick(this.weatherCardItemType == Constants.ITEM_TYPE_OBSERVE ? this.onWeatherObserveSortTap : undefined)
    }
    .padding({ left: 16, right: 16 })
    .zIndex(this.zIndexValue)
    .translate({ y: this.offsetY })
  }

  get title() {
    switch (this.weatherCardItemType) {
      case Constants.ITEM_TYPE_ALARMS:
        return "极端天气"
      case Constants.ITEM_TYPE_AIR_QUALITY:
        return "空气质量"
      case Constants.ITEM_TYPE_HOUR_WEATHER:
        return "每小时天气预报"
      case Constants.ITEM_TYPE_DAILY_WEATHER:
        return "15日天气预报"
      case Constants.ITEM_TYPE_OBSERVE:
        return "专业数据"
      case Constants.ITEM_TYPE_LIFE_INDEX:
        return "生活指数"
    }
    return ""
  }

  onLongPress() {
    const enable = this.onReorderStart ? this.onReorderStart() : true
    if (enable) {
      this.zIndexValue = 1
      this.isLongPress = true
      this.dragRefOffset = 0
    }
  }

  onMenuPress() {
    const enable = this.onReorderStart ? this.onReorderStart() : true
    if (enable) {
      this.zIndexValue = 1
      this.isMenuPress = true
      this.dragRefOffset = 0
    }
  }

  onItemMove(offsetY: number) {
    if (!this.isLongPress && !this.isMenuPress) {
      return
    }
    this.offsetY = offsetY - this.dragRefOffset
    const direction = this.offsetY > 0 ? 1 : -1
    if (Math.abs(this.offsetY) > ITEM_HEIGHT / 2) {
      if (this.index === 0 && direction === -1) {
        return
      }
      if (this.index === this.length - 1 && direction === 1) {
        return
      }
      // 目标位置索引
      const target = this.index + direction
      if (this.beforeChange) {
        if (this.beforeChange(target)) {
          return
        }
      }
      animateTo({ curve: Curve.Friction, duration: 300 }, () => {
        this.offsetY -= direction * ITEM_HEIGHT
        this.dragRefOffset += direction * ITEM_HEIGHT
        if (target !== -1 && target <= this.length) {
          console.log('changeItem index = ' + this.index + ' target = ' + target)
          if (this.onChangeItem) {
            this.onChangeItem(this.index, target)
          }
        }
      })
    }
  }

  onItemDrop() {
    if (this.isLongPress || this.isMenuPress) {
      this.isLongPress = false
      this.isMenuPress = false
      this.dragRefOffset = 0;
      if (this.onReorderDone) {
        this.onReorderDone()
      }
      animateTo({
        curve: curves.interpolatingSpring(14, 1, 170, 17), onFinish: () => {
          this.zIndexValue = 0
        }
      }, () => {
        this.offsetY = 0
      })
    }
  }
}