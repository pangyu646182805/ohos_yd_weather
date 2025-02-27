import { StrUtil } from "@pura/harmony-utils";
import { CityData } from "../db/model/CityData";
import { ColorUtils } from "../utils/ColorUtils";
import { getTemp } from "../utils/CommonUtils";
import { WeatherBgUtils } from "../utils/WeatherBgUtils";

@ComponentV2
export struct CityManagerItem {
  @Param cityData?: CityData = undefined
  @Param isEditMode: boolean = false
  @Param isSelected: boolean = false
  @Event toEditMode?: (cityData?: CityData) => void = undefined
  @Event onItemClick?: (cityData?: CityData) => void = undefined

  build() {
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
      .height(98)
      .gesture(
        LongPressGesture()
          .onAction((event: GestureEvent | undefined) => {
            if (event) {
              if (this.toEditMode) {
                this.toEditMode(this.cityData)
              }
            }
          })
      )
      .onClick(() => {
        if (this.isEditMode) {
          if (!this.isLocationCity && this.onItemClick) {
            this.onItemClick(this.cityData)
          }
        }
      })
    }
    .padding({ left: 16, right: 16 })
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