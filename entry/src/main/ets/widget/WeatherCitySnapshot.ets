import { AppUtil, DisplayUtil } from "@pura/harmony-utils"
import { Constants } from "../constants/Constants"
import { CityData } from "../db/model/CityData"
import { WeatherItemData } from "../entity/WeatherItemData"
import { AppRuntimeData } from "../utils/AppRuntimeData"
import { WeatherDataUtils } from "../utils/WeatherDataUtils"
import { WeatherAirQualityPanel } from "./WeatherAirQualityPanel"
import { WeatherAlarmsPanel } from "./WeatherAlarmsPanel"
import { WeatherDailyPanel } from "./WeatherDailyPanel"
import { WeatherHeaderWidget } from "./WeatherHeaderWidget"
import { WeatherHourPanel } from "./WeatherHourPanel"
import { WeatherLifeIndexPanel } from "./WeatherLifeIndexPanel"
import { WeatherObservePanel } from "./WeatherObservePanel"

@ComponentV2
export struct WeatherCitySnapshot {
  @Param cityData?: CityData = undefined
  @Param data?: Array<WeatherItemData> = undefined
  @Param scaleParams: ScaleOptions = { x: 1, y: 1 }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      List() {
        ForEach(this.data, (item: WeatherItemData) => {
          if (item.itemType == Constants.ITEM_TYPE_ALARMS) {
            WeatherAlarmsPanel({
              enable: false,
              weatherItemData: item,
              isDark: this.isDark,
              panelOpacity: this.panelOpacity
            })
          } else if (item.itemType == Constants.ITEM_TYPE_AIR_QUALITY) {
            WeatherAirQualityPanel({
              enable: false,
              weatherItemData: item,
              isDark: this.isDark,
              panelOpacity: this.panelOpacity
            })
          } else if (item.itemType == Constants.ITEM_TYPE_HOUR_WEATHER) {
            WeatherHourPanel({
              enable: false,
              weatherItemData: item,
              isDark: this.isDark,
              panelOpacity: this.panelOpacity
            })
          } else if (item.itemType == Constants.ITEM_TYPE_DAILY_WEATHER) {
            WeatherDailyPanel({
              enable: false,
              weatherItemData: item,
              isDark: this.isDark,
              panelOpacity: this.panelOpacity
            })
          } else if (item.itemType == Constants.ITEM_TYPE_OBSERVE) {
            WeatherObservePanel({
              enable: false,
              weatherItemData: item,
              itemTypeObserves: this.itemTypeObserves,
              isDark: this.isDark,
              isWeatherHeaderDark: this.isWeatherHeaderDark,
              panelOpacity: this.panelOpacity
            })
          } else if (item.itemType == Constants.ITEM_TYPE_LIFE_INDEX) {
            WeatherLifeIndexPanel({
              weatherItemData: item,
              isDark: this.isDark,
              panelOpacity: this.panelOpacity
            })
          }
        }, (item: WeatherItemData) => item.itemType.toString())
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .divider({ strokeWidth: 12, color: $r('app.color.transparent') })
      .margin({ top: px2vp(AppUtil.getStatusBarHeight()) + Constants.WEATHER_HEADER_MIN_HEIGHT })
      .padding({ left: Constants.ITEM_PANEL_MARGIN, right: Constants.ITEM_PANEL_MARGIN })
      .contentStartOffset(Constants.WEATHER_HEADER_MAX_HEIGHT - Constants.WEATHER_HEADER_MIN_HEIGHT)
      .borderRadius({ topLeft: Constants.ITEM_PANEL_RADIUS, topRight: Constants.ITEM_PANEL_RADIUS })
      .clip(true)
      .enableScrollInteraction(false)

      WeatherHeaderWidget({
        isWeatherHeaderDark: this.isWeatherHeaderDark,
        weatherItemData: this.data?.[0]
      })
    }
    .width(px2vp(DisplayUtil.getWidth()))
    .height(px2vp(DisplayUtil.getHeight()))
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: this.weatherBg
    })
    .scale(this.scaleParams)
    .clip(true)
    .borderRadius(16)
    .animation({ curve: Curve.Linear, duration: 400 })
  }

  get weatherBg() {
    return WeatherDataUtils.generateWeatherBg(this.data?.[0].weatherData)
  }

  get isDark() {
    return WeatherDataUtils.isDark(this.weatherBg)
  }

  get isWeatherHeaderDark() {
    return WeatherDataUtils.isWeatherHeaderDark(this.weatherBg)
  }

  get panelOpacity() {
    return WeatherDataUtils.calPanelOpacity(this.weatherBg)
  }

  get itemTypeObserves() {
    return WeatherDataUtils.getItemTypeObserves(AppRuntimeData.getInstance().currentWeatherObservesCardSort,
      Constants.ITEM_TYPE_OBSERVE, this.data?.[0].weatherData)
  }
}