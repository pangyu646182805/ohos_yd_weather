import { ArrayUtil, DateUtil, ObjectUtil, StrUtil } from "@pura/harmony-utils";
import { Constants } from "../constants/Constants";
import { WeatherData, WeatherHourData } from "../entity/WeatherData";
import { WeatherItemData } from "../entity/WeatherItemData";
import { ColorUtils } from "./ColorUtils";
import { isNight, isSunriseOrSunset } from "./CommonUtils";
import { WeatherBgUtils } from "./WeatherBgUtils";

export class WeatherDataUtils {
  static generateWeatherBg(weatherData?: WeatherData, cacheWeatherType?: string, cacheSunrise?: string,
    cacheSunset?: string): Array<[ResourceColor, number]> {
    let weatherType = cacheWeatherType ?? (weatherData?.observe?.third_type ?? '')
    const currentWeatherDetailData = weatherData?.forecast15?.find(it => StrUtil.equal(it.date,
      DateUtil.getFormatDateStr(DateUtil.getToday(), Constants.YYYYMMDD)))
    if (StrUtil.isEmpty(weatherType)) {
      weatherType = currentWeatherDetailData?.third_type ?? ''
    }
    return WeatherBgUtils.generateWeatherBg(weatherType,
      isNight(DateUtil.getToday(), currentWeatherDetailData?.sunrise ?? cacheSunrise,
        currentWeatherDetailData?.sunset ?? cacheSunset))
  }

  static isWeatherHeaderDark(weatherBg?: Array<[ResourceColor, number]>): boolean {
    if (ArrayUtil.isEmpty(weatherBg)) {
      return false
    }
    const color = weatherBg![0][0]
    return ColorUtils.estimateBrightnessForColor(color as Resource) == ColorMode.DARK
  }

  static isDark(weatherBg?: Array<[ResourceColor, number]>): boolean {
    if (ArrayUtil.isEmpty(weatherBg)) {
      return false
    }
    const color = weatherBg![1][0]
    return ColorUtils.estimateBrightnessForColor(color as Resource) == ColorMode.DARK
  }

  static calPanelOpacity(weatherBg?: Array<[ResourceColor, number]>): number {
    if (ArrayUtil.isEmpty(weatherBg)) {
      return 0.1
    }
    const color = weatherBg![1][0]
    const darkness = ColorUtils.getDarkness(color as Resource)
    let panelOpacity = parseFloat(Math.abs(0.3 - darkness).toFixed(1))
    if (panelOpacity < 0.1) {
      panelOpacity = 0.1
    } else if (panelOpacity > 0.3) {
      panelOpacity = 0.3
    }
    console.log(`darkness = ${darkness} panelOpacity = ${panelOpacity}`)
    return panelOpacity
  }

  static generateWeatherItems(
    weatherSort: Array<number>,
    weatherObservesCardSort: Array<number>,
    weatherData?: WeatherData): Array<WeatherItemData> {
    WeatherDataUtils.generateWeatherHourFc(weatherData)
    const weatherItems = weatherSort.map(itemType => {
      const itemTypeObserves = WeatherDataUtils.getItemTypeObserves(weatherObservesCardSort, itemType, weatherData)
      return {
        itemType: itemType,
        weatherData: weatherData,
        itemTypeObserves: itemTypeObserves
      } as WeatherItemData
    })
    return weatherItems.filter(weatherItem => {
      const itemType = weatherItem.itemType
      const removeAlarmsPanel = itemType == Constants.ITEM_TYPE_ALARMS && ArrayUtil.isEmpty(weatherData?.alarms)
      const removeAirQualityPanel = itemType == Constants.ITEM_TYPE_AIR_QUALITY && ObjectUtil.isNull(weatherData?.evn)
      const removeHourPanel = itemType == Constants.ITEM_TYPE_HOUR_WEATHER && ArrayUtil.isEmpty(weatherData?.hourfc)
      const removeDailyPanel =
        itemType == Constants.ITEM_TYPE_DAILY_WEATHER && ArrayUtil.isEmpty(weatherData?.forecast15)
      const removeObservePanel =
        itemType == Constants.ITEM_TYPE_OBSERVE && ArrayUtil.isEmpty(weatherItem.itemTypeObserves)
      const removeLifeIndexPanel = itemType == Constants.ITEM_TYPE_LIFE_INDEX && ArrayUtil.isEmpty(weatherData?.indexes)
      return !removeAlarmsPanel &&
        !removeAirQualityPanel &&
        !removeHourPanel &&
        !removeDailyPanel &&
        !removeObservePanel &&
        !removeLifeIndexPanel
    })
  }

  private static generateWeatherHourFc(weatherData?: WeatherData) {
    const hourFc = weatherData?.hourfc
    if (ArrayUtil.isEmpty(hourFc)) {
      return
    }
    const hourFcFilter = hourFc!.filter(it => StrUtil.isEmpty(it.sunriseAndSunset?.sunrise) &&
    StrUtil.isEmpty(it.sunriseAndSunset?.sunset))
    const currentWeatherDetailData = weatherData?.forecast15?.find(it => StrUtil.equal(it.date,
      DateUtil.getFormatDateStr(DateUtil.getToday(), Constants.YYYYMMDD)))
    const sunriseIndex = hourFcFilter.findIndex(it => isSunriseOrSunset(currentWeatherDetailData?.sunrise, it.time))
    if (sunriseIndex >= 0) {
      hourFcFilter.splice(sunriseIndex + 1, 0,
        {
          time: currentWeatherDetailData?.sunrise,
          sunriseAndSunset: { sunrise: currentWeatherDetailData?.sunrise }
        } as WeatherHourData)
    }
    const sunsetIndex = hourFcFilter.findIndex(it => isSunriseOrSunset(currentWeatherDetailData?.sunset, it.time))
    if (sunsetIndex >= 0) {
      hourFcFilter.splice(sunsetIndex + 1, 0,
        {
          time: currentWeatherDetailData?.sunset,
          sunriseAndSunset: { sunset: currentWeatherDetailData?.sunset }
        } as WeatherHourData)
    }
    weatherData!.hourfc = hourFcFilter
  }

  private static getItemTypeObserves(
    currentWeatherObservesCardSort: Array<number>, itemType: number,
    weatherData?: WeatherData): Array<number> | undefined {
    if (!ObjectUtil.isNull(weatherData) && itemType == Constants.ITEM_TYPE_OBSERVE) {
      const itemTypeObserves = [...currentWeatherObservesCardSort]
      return itemTypeObserves.filter(itemType => {
        return true
      })
    }
    return undefined
  }
}