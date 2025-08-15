import { DateUtil, StrUtil } from "@pura/harmony-utils";
import { CityData } from "../db/model/CityData";
import { ColorUtils } from "../utils/ColorUtils";
import { getTemp, isNight } from "../utils/CommonUtils";
import { WeatherBgUtils } from "../utils/WeatherBgUtils";
import { curves } from "@kit.ArkUI";
import { WeatherDataUtils } from "../utils/WeatherDataUtils";

const ITEM_HEIGHT: number = 98

@ComponentV2
export struct CityManagerItem {
  @Param cityData?: CityData = undefined
  @Param index: number = 0
  @Param startIndex: number = 0
  @Param endIndex: number = 0
  @Param itemOpacity: number = 0
  @Param length: number = 0
  @Param isEditMode: boolean = false
  @Param isSelected: boolean = false
  @Event toEditMode?: (cityData?: CityData) => void = undefined
  @Event onItemClick?: (index: number, cityData?: CityData) => void = undefined
  @Event onRemoveItem?: (cityData?: CityData) => void = undefined
  private isLongPress: boolean = false
  private isMenuPress: boolean = false
  private dragRefOffset: number = 0
  @Local zIndexValue: number = 0
  @Local offsetY: number = 0
  @Event onReorderStart?: () => boolean = undefined
  @Event beforeChange?: (target: number) => boolean = undefined
  @Event onChangeItem?: (from: number, to: number) => void = undefined
  @Event onReorderDone?: () => void = undefined

  build() {
    ListItem() {
      Column() {
        Stack() {
          this.cityItem()
          if (!this.isLocationCity) {
            this.editItem()
          }
        }
        .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.9 })
        .borderRadius(16)
        .borderColor($r('app.color.black'))
        .borderWidth(this.similarity1 > 0.95 && this.similarity2 > 0.95 ? 1 : 0)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: this.weatherBg
        })
        .width('100%')
        .height(ITEM_HEIGHT)
        .hitTestBehavior(HitTestMode.Transparent)
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
              return
            }
            this.onItemDrop()
          })
        )
        .onClick(() => {
          if (this.onItemClick) {
            if (this.isEditMode && !this.isLongPress) {
              if (!this.isLocationCity) {
                this.onItemClick(this.index, this.cityData)
              }
            } else {
              this.onItemClick(this.index, this.cityData)
            }
          }
        })
      }
      .padding({ left: 16, right: 16 })
    }
    .id(`city_item_${this.index}`)
    .zIndex(this.zIndexValue)
    .translate({ y: this.offsetY })
    .swipeAction({
      end: !this.isLocationCity && !this.isEditMode ? () => {
        this.itemEnd()
      } : undefined,
    })
    .transition(TransitionEffect.SLIDE)
    .opacity(this.itemOpacity)
    .scale({ x: this.itemOpacity <= 0 ? 0.8 : 1, y: this.itemOpacity <= 0 ? 0.8 : 1 })
    .animation({ duration: this.calDuration(), curve: Curve.Ease })
  }

  calDuration(): number {
    if (this.startIndex <= 0 && this.endIndex <= 0) {
      return 0
    }
    if (this.startIndex > this.endIndex) {
      if (this.index < this.endIndex || this.index > this.startIndex) {
        return 0
      }
      const fixedIndex = this.startIndex - this.index
      return fixedIndex * 60 + 10
    } else {
      if (this.index < this.startIndex || this.index > this.endIndex) {
        return 0
      }
      const fixedIndex = this.index - this.startIndex
      return fixedIndex * 60 + 10
    }
  }

  @Builder
  editItem() {
    Row() {
      Image($r('app.media.ic_menu_icon'))
        .width(24)
        .height(24)
        .colorFilter(ColorUtils.translateColor(this.isDark ? $r('app.color.special_white') :
        $r('app.color.special_black')))
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
      Image(this.isSelected ? $r('app.media.ic_checked_icon') : $r('app.media.ic_check_icon'))
        .width(22)
        .height(22)
        .colorFilter(ColorUtils.translateColor(this.isSelected ? $r('app.color.app_main') :
          this.isDark ? $r('app.color.special_white') : $r('app.color.special_black')))
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
            .fontColor(this.isDark ? $r('app.color.special_white') : $r('app.color.special_black'))
            .fontWeight(FontWeight.Normal)
          Image($r('app.media.writing_icon_location1'))
            .width(22)
            .height(22)
            .colorFilter(ColorUtils.translateColor(this.isDark ? $r('app.color.special_white') :
            $r('app.color.special_black')))
            .visibility(this.isLocationCity ? Visibility.Visible : Visibility.Hidden)
        }

        Text(this.subTitle)
          .fontSize(14)
          .fontColor(this.isDark ? $r('app.color.special_white') : $r('app.color.special_black'))
          .fontWeight(FontWeight.Normal)
      }
      .alignItems(HorizontalAlign.Start)

      Text(getTemp(this.cityData?.weatherData?.temp))
        .fontSize(38)
        .fontColor(this.isDark ? $r('app.color.special_white') : $r('app.color.special_black'))
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

  get weatherBg() {
    return WeatherBgUtils.generateWeatherBg(this.cityData?.weatherData?.weatherType ?? '',
      isNight(DateUtil.getToday(), this.cityData?.weatherData?.sunrise, this.cityData?.weatherData?.sunset), true)
  }

  get isDark() {
    return WeatherDataUtils.isDark(this.weatherBg)
  }

  get similarity1() {
    return ColorUtils.calSimilarity($r('app.color.bg_color'), this.weatherBg[0][0] as Resource)
  }

  get similarity2() {
    return ColorUtils.calSimilarity($r('app.color.bg_color'), this.weatherBg[1][0] as Resource)
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