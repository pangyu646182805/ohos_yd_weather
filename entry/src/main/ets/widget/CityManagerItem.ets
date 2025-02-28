import { StrUtil } from "@pura/harmony-utils";
import { CityData } from "../db/model/CityData";
import { ColorUtils } from "../utils/ColorUtils";
import { getTemp } from "../utils/CommonUtils";
import { WeatherBgUtils } from "../utils/WeatherBgUtils";
import { componentUtils, curves } from "@kit.ArkUI";

const ITEM_HEIGHT: number = 98

@ComponentV2
export struct CityManagerItem {
  @Param cityData?: CityData = undefined
  @Param index: number = 0
  @Param length: number = 0
  @Param isEditMode: boolean = false
  @Param isSelected: boolean = false
  @Event toEditMode?: (cityData?: CityData) => void = undefined
  @Event onItemClick?: (cityData?: CityData) => void = undefined
  @Event onRemoveItem?: (cityData?: CityData) => void = undefined
  private isLongPress: boolean = false
  private dragRefOffset: number = 0
  private taskId: number = -1
  @Local zIndexValue: number = 0
  @Local offsetY: number = 0
  @Event onReorderStart?: () => boolean = undefined
  @Event beforeChange?: (target: number) => boolean = undefined
  @Event onChangeItem?: (from: number, to: number) => void = undefined
  @Event onReorderDone?: () => void = undefined
  @Param listScroller?: ListScroller = undefined

  build() {
    ListItem() {
      Column() {
        Stack() {
          if (!this.isLocationCity) {
            this.editItem()
          }
          this.cityItem()
        }
        .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.9 })
        .borderRadius(16)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: WeatherBgUtils.generateWeatherBg(this.cityData?.weatherData?.weatherType, false)
        })
        .width('100%')
        .height(ITEM_HEIGHT)
        .gesture(
          GestureGroup(GestureMode.Sequence,
            LongPressGesture()
              .onAction(() => {
                if (this.toEditMode) {
                  this.toEditMode(this.cityData)
                }
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
              return;
            }
            this.onItemDrop()
          })
        )
        .onClick(() => {
          if (this.isEditMode && !this.isLongPress) {
            if (!this.isLocationCity && this.onItemClick) {
              this.onItemClick(this.cityData)
            }
          }
        })
      }
      .padding({ left: 16, right: 16 })
    }
    .id('index_' + this.index)
    .zIndex(this.zIndexValue)
    .translate({ y: this.offsetY })
    .swipeAction({
      end: !this.isLocationCity && !this.isEditMode ? () => {
        this.itemEnd()
      } : undefined,
    })
    .transition(TransitionEffect.SLIDE)
  }

  @Builder
  editItem() {
    Row() {
      Image($r('app.media.ic_menu_icon'))
        .width(24)
        .height(24)
        .colorFilter(ColorUtils.translateColor($r('app.color.special_white')))
      Image(this.isSelected ? $r('app.media.ic_checked_icon') : $r('app.media.ic_check_icon'))
        .width(22)
        .height(22)
        .colorFilter(ColorUtils.translateColor(this.isSelected ? $r('app.color.app_main') :
        $r('app.color.special_white')))
        .backgroundColor(this.isEditMode && this.isSelected ? $r('app.color.special_white') :
        $r('app.color.transparent'))
        .borderRadius(100)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .animatableEditItem(this.isEditMode ? 1 : 0)
    .animation({ duration: 200, curve: Curve.Linear })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  cityItem() {
    Row() {
      Column({ space: 4 }) {
        Row() {
          Text(this.title)
            .fontSize(20)
            .fontColor($r('app.color.special_white'))
            .fontWeight(FontWeight.Normal)
          Image($r('app.media.writing_icon_location1'))
            .width(22)
            .height(22)
            .colorFilter(ColorUtils.translateColor($r('app.color.special_white')))
            .visibility(this.isLocationCity ? Visibility.Visible : Visibility.Hidden)
        }

        Text(this.subTitle)
          .fontSize(14)
          .fontColor($r('app.color.special_white'))
          .fontWeight(FontWeight.Normal)
      }
      .alignItems(HorizontalAlign.Start)

      Text(getTemp(this.cityData?.weatherData?.temp))
        .fontSize(38)
        .fontColor($r('app.color.special_white'))
        .fontWeight(FontWeight.Lighter)
    }
    .width('100%')
    .animatableCityItemPadding(this.isEditMode && !this.isLocationCity ? 52 : 16)
    .animation({ duration: 200, curve: Curve.Linear })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  itemEnd() {
    Stack() {
      Image($r('app.media.ic_delete_icon'))
        .width(20)
        .height(20)
        .colorFilter(ColorUtils.translateColor($r('app.color.special_white')))
    }
    .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
    .width(48)
    .height(48)
    .backgroundColor($r('app.color.color_fe2c3c'))
    .borderRadius(100)
    .margin({ right: 16 })
    .onClick(() => {
      if (this.onRemoveItem) {
        this.onRemoveItem(this.cityData)
      }
    })
  }

  @Computed
  get isLocationCity() {
    return this.cityData?.isLocationCity ?? false
  }

  @Computed
  get title() {
    const isLocationCity = this.isLocationCity
    const city = this.cityData?.weatherData?.city ?? ''
    const street = this.cityData?.street ?? ''
    return !isLocationCity || StrUtil.isEmpty(street) ? city : city + ' ' + street
  }

  @Computed
  get subTitle() {
    const weatherData = this.cityData?.weatherData
    return weatherData?.weatherDesc + ' ' + getTemp(weatherData?.tempHigh) + ' / ' + getTemp(weatherData?.tempLow)
  }

  onLongPress() {
    const enable = this.onReorderStart ? this.onReorderStart() : true
    if (enable) {
      this.zIndexValue = 1
      this.isLongPress = true
      this.dragRefOffset = 0
    }
  }

  onItemMove(offsetY: number) {
    if (!this.isLongPress) {
      return
    }
    // this.checkScroll()
    console.log('offsetY = ' + offsetY)
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
    if (this.isLongPress) {
      this.stopScrollTask()
      this.isLongPress = false
      this.dragRefOffset = 0;
      animateTo({
        curve: curves.interpolatingSpring(14, 1, 170, 17), onFinish: () => {
          this.zIndexValue = 0
          if (this.onReorderDone) {
            this.onReorderDone()
          }
        }
      }, () => {
        this.offsetY = 0
      })
    }
  }

  checkScroll() {
    const listScroller = this.listScroller
    if (listScroller) {
      const listRectangle = componentUtils.getRectangleById('city_list')
      const itemRectangle = componentUtils.getRectangleById('index_' + this.index)
      if (itemRectangle.localOffset.y < 0 && listScroller.currentOffset().yOffset > 0) {
        this.startScrollTask()
      } else {
        // this.stopScrollTask()
      }
    }
  }

  startScrollTask() {
    const listScroller = this.listScroller
    if (listScroller && this.taskId == -1) {
      console.log('startScrollTask')
      this.taskId = setInterval(() => {
        if (listScroller.currentOffset().yOffset <= 0) {
          this.stopScrollTask()
        } else {
          listScroller?.scrollBy(0, -1)
          this.offsetY -= 1
        }
      }, 10)
      console.log('taskId = ' + this.taskId)
    }
  }

  stopScrollTask() {
    clearInterval(this.taskId)
    this.taskId = -1
  }
}

@AnimatableExtend(Row)
function animatableCityItemPadding(padding: number) {
  .padding({ left: padding, right: padding })
}

@AnimatableExtend(Row)
function animatableEditItem(visibility: number) {
  .opacity(visibility)
  .visibility(visibility <= 0 ? Visibility.Hidden : Visibility.Visible)
}