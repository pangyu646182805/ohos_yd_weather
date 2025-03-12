import { ArrayUtil, DateUtil, DisplayUtil, ObjectUtil, StrUtil } from "@pura/harmony-utils";
import { Constants } from "../constants/Constants";

// 防抖 在一段时间内函数被多次触发，防抖让函数在一段时间后最终只执行一次
export function debounce(func: () => void, delay?: number) {
  let timer: number | undefined;
  clearTimeout(timer);
  timer = setTimeout(() => {
    func();
  }, delay ? delay : 1000);
}

// 节流 在规定的时间内，只执行一次
export function throttle(func: () => void, delay?: number) {
  let inThrottle = false;
  let timer: number | undefined;
  if (!inThrottle) {
    func();
    inThrottle = true;
    timer = setTimeout(() => {
      clearTimeout(timer)
      inThrottle = false
    }, delay ? delay : 1000);
  }
}

export function getTemp(temp: number | null | undefined): string {
  return ObjectUtil.isNull(temp) ? '' : temp + '°'
}

export function fixPercent(value: number | null | undefined, defValue: number = 0): number {
  if (ObjectUtil.isNull(value)) {
    return defValue
  }
  if (value! > 1) {
    return 1
  }
  if (value! < 0) {
    return 0
  }
  return value!
}

export function isNight(date?: Date, sunrise?: string, sunset?: string): boolean {
  if (ObjectUtil.isNull(date)) {
    return false
  }
  if (StrUtil.isNotEmpty(sunrise) && sunrise!.includes(':')
    && StrUtil.isNotEmpty(sunset) && sunset!.includes(':')) {
    return _isNight(date!, sunrise!, sunset!)
  }
  return date!.getHours() >= 18 || (date!.getHours() >= 0 && date!.getHours() < 6)
}

function _isNight(date: Date, sunrise: string, sunset: string): boolean {
  const sunriseSplit = sunrise.split(':')
  const sunsetSplit = sunset.split(':')
  const sunriseHour = parseInt(sunriseSplit[0])
  const sunriseMinute = parseInt(sunriseSplit[1])
  const sunsetHour = parseInt(sunsetSplit[0])
  const sunsetMinute = parseInt(sunsetSplit[1])
  const isNight =
    (date.getHours() > sunsetHour ? true : date.getHours() >= sunsetHour && date.getMinutes() > sunsetMinute) ||
      (date.getHours() < sunriseHour ? true : date.getHours() <= sunriseHour && date.getMinutes() < sunriseMinute)
  return isNight
}

export function buildPathCommands(panelHeight: number, offset: number = 0): string {
  const margin = vp2px(Constants.ITEM_PANEL_MARGIN)
  const height = vp2px(panelHeight)
  return `M 0 ${vp2px(offset)} H ${DisplayUtil.getWidth() - 2 * margin} V ${height} H 0 Z`
}

// 202407111400 => 2024/07/11 14:00
export function getHarmonyDateTimeFormattedString(time?: string): string {
  if (StrUtil.isEmpty(time)) {
    return ''
  }
  if (time!.length != 12) {
    return ''
  }
  return `${time!.substring(0, 4)}/${time!.substring(4, 6)}/${time!.substring(6, 8)} ${time!.substring(8,
    10)}:${time!.substring(10)}`
}

export function isHourNow(time?: string): boolean {
  if (StrUtil.isEmpty(time)) {
    return false
  }
  const nowTimeStr = DateUtil.getFormatDateStr(DateUtil.getToday(), Constants.YYYYMMDDHH)
  const dateTimeStr = DateUtil.getFormatDateStr(getHarmonyDateTimeFormattedString(time), Constants.YYYYMMDDHH)
  return nowTimeStr == dateTimeStr
}

export function getWeatherHourTime(time?: string, sunrise?: string, sunset?: string): string {
  const result = isHourNow(time)
  if (result) {
    const sunriseHourMinute = getSunriseOrSunsetHourMinute(sunrise)
    const sunsetHourMinute = getSunriseOrSunsetHourMinute(sunset)
    if (ArrayUtil.isNotEmpty(sunriseHourMinute) && ArrayUtil.isNotEmpty(sunsetHourMinute)) {
      const now = new Date()
      const sunriseDateTime = new Date()
      sunriseDateTime.setHours(sunriseHourMinute![0])
      sunriseDateTime.setMinutes(sunriseHourMinute![1])
      const sunsetDateTime = new Date()
      sunsetDateTime.setHours(sunsetHourMinute![0])
      sunsetDateTime.setMinutes(sunsetHourMinute![1])
      const isAfterSunrise = now.getTime() > sunriseDateTime.getTime()
      const isAfterSunset = now.getTime() > sunsetDateTime.getTime()
      if (sunriseHourMinute![0] == now.getHours() && isAfterSunrise) {
        return DateUtil.getFormatDateStr(getHarmonyDateTimeFormattedString(time), "HH时")
      } else if (sunsetHourMinute![0] == now.getHours() && isAfterSunset) {
        return DateUtil.getFormatDateStr(getHarmonyDateTimeFormattedString(time), "HH时")
      }
    }
    return '现在'
  }
  return DateUtil.getFormatDateStr(getHarmonyDateTimeFormattedString(time), 'HH时')
}

export function getSunriseOrSunsetHourMinute(sunriseOrSunset?: string): Array<number> | undefined {
  if (StrUtil.isEmpty(sunriseOrSunset)) {
    return undefined
  }
  const sunriseOrSunsetSplit = sunriseOrSunset!.split(':')
  const sunriseOrSunsetHour = parseInt(sunriseOrSunsetSplit[0])
  const sunriseOrSunsetMinute = parseInt(sunriseOrSunsetSplit[1])
  return [sunriseOrSunsetHour, sunriseOrSunsetMinute]
}
