import { Constants } from "../constants/Constants"
import { WeatherItemData } from "../entity/WeatherItemData"
import { WeatherObserveForecase40Panel } from "./WeatherObserveForecase40Panel"
import { WeatherObservePressurePanel } from "./WeatherObservePressurePanel"
import { WeatherObserveShiDuPanel } from "./WeatherObserveShiDuPanel"
import { WeatherObserveSunriseSunsetPanel } from "./WeatherObserveSunriseSunsetPanel"
import { WeatherObserveTiGanPanel } from "./WeatherObserveTiGanPanel"
import { WeatherObserveUvPanel } from "./WeatherObserveUvPanel"
import { WeatherObserveVisibilityPanel } from "./WeatherObserveVisibilityPanel"
import { WeatherObserveWdPanel } from "./WeatherObserveWdPanel"

@ComponentV2
export struct WeatherObservePanel {
  @Param enable: boolean = true
  @Param weatherItemData?: WeatherItemData = undefined
  @Param itemTypeObserves?: Array<number> = undefined
  @Param isDark: boolean = false
  @Param isWeatherHeaderDark: boolean = false
  @Param panelOpacity: number = 0.1
  @Event showHideWeatherContent?: (show: boolean) => void

  build() {
    ListItem() {
      Grid() {
        ForEach(this.itemTypeObserves, (item: number) => {
          if (item == Constants.ITEM_TYPE_OBSERVE_UV) {
            WeatherObserveUvPanel({
              weatherItemData: this.weatherItemData,
              isDark: this.isDark,
              panelOpacity: this.panelOpacity
            })
          } else if (item == Constants.ITEM_TYPE_OBSERVE_SHI_DU) {
            WeatherObserveShiDuPanel({
              weatherItemData: this.weatherItemData,
              isDark: this.isDark,
              panelOpacity: this.panelOpacity
            })
          } else if (item == Constants.ITEM_TYPE_OBSERVE_TI_GAN) {
            WeatherObserveTiGanPanel({
              weatherItemData: this.weatherItemData,
              isDark: this.isDark,
              panelOpacity: this.panelOpacity
            })
          } else if (item == Constants.ITEM_TYPE_OBSERVE_WD) {
            WeatherObserveWdPanel({
              weatherItemData: this.weatherItemData,
              isDark: this.isDark,
              panelOpacity: this.panelOpacity
            })
          } else if (item == Constants.ITEM_TYPE_OBSERVE_SUNRISE_SUNSET) {
            WeatherObserveSunriseSunsetPanel({
              weatherItemData: this.weatherItemData,
              isDark: this.isDark,
              panelOpacity: this.panelOpacity
            })
          } else if (item == Constants.ITEM_TYPE_OBSERVE_PRESSURE) {
            WeatherObservePressurePanel({
              weatherItemData: this.weatherItemData,
              isDark: this.isDark,
              panelOpacity: this.panelOpacity
            })
          } else if (item == Constants.ITEM_TYPE_OBSERVE_VISIBILITY) {
            WeatherObserveVisibilityPanel({
              weatherItemData: this.weatherItemData,
              isDark: this.isDark,
              panelOpacity: this.panelOpacity
            })
          } else if (item == Constants.ITEM_TYPE_OBSERVE_FORECAST40) {
            WeatherObserveForecase40Panel({
              enable: this.enable,
              weatherItemData: this.weatherItemData,
              isDark: this.isDark,
              isWeatherHeaderDark: this.isWeatherHeaderDark,
              panelOpacity: this.panelOpacity,
              showHideWeatherContent: this.showHideWeatherContent
            })
          }
        }, (item: number) => item.toString())
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .maxCount(2)
      .layoutDirection(GridDirection.Row)
    }
  }
}