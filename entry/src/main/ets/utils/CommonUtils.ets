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
// 20250314 => 2025/03/14
export function getHarmonyDateTimeFormattedString(time?: string): string {
  if (StrUtil.isEmpty(time)) {
    return ''
  }
  if (time!.length == 12) {
    return `${time!.substring(0, 4)}/${time!.substring(4, 6)}/${time!.substring(6, 8)} ${time!.substring(8,
      10)}:${time!.substring(10)}`
  }
  if (time!.length == 8) {
    return `${time!.substring(0, 4)}/${time!.substring(4, 6)}/${time!.substring(6, 8)}`
  }
  return ''
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

export function isSunriseOrSunset(sunriseOrSunset?: string, time?: string): boolean {
  if (StrUtil.isEmpty(sunriseOrSunset) || StrUtil.isEmpty(time)) {
    return false
  }
  return sunriseOrSunset!.startsWith(DateUtil.getFormatDateStr(getHarmonyDateTimeFormattedString(time), 'HH'))
}

export function isYesterday(date1: number | string | Date, date2: number | string | Date): boolean {
  const dateStr = DateUtil.getFormatDateStr(date1, 'yyyy-MM-dd')
  const beforeDayStr = DateUtil.getBeforeDayStr(date2, 'yyyy-MM-dd')
  return dateStr == beforeDayStr
}

export function isTomorrow(date1: number | string | Date, date2: number | string | Date): boolean {
  const dateStr = DateUtil.getFormatDateStr(date1, 'yyyy-MM-dd')
  const afterDayStr = DateUtil.getAfterDayStr(date2, 'yyyy-MM-dd')
  return dateStr == afterDayStr
}

export function isBefore(date?: string): boolean {
  if (StrUtil.isEmpty(date)) {
    return false
  }
  date = getHarmonyDateTimeFormattedString(date)
  const dateTime = DateUtil.getFormatDate(date)
  const today = DateUtil.getToday()
  today.setHours(0)
  today.setMinutes(0)
  today.setSeconds(0)
  today.setMilliseconds(0)
  return dateTime.getTime() < today.getTime()
}

export function getWeatherDateTime(date?: string) {
  if (StrUtil.isEmpty(date)) {
    return ''
  }
  date = getHarmonyDateTimeFormattedString(date)
  const dateTime = DateUtil.getFormatDate(date)
  if (isYesterday(dateTime, DateUtil.getToday())) {
    return '昨天'
  }
  if (DateUtil.isToday(dateTime)) {
    return '今天'
  }
  if (isTomorrow(dateTime, DateUtil.getToday())) {
    return '明天'
  }
  const weekDay = DateUtil.getWeekDay(dateTime)
  switch (weekDay) {
    case 0:
      return '周日'
    case 1:
      return '周一'
    case 2:
      return '周二'
    case 3:
      return '周三'
    case 4:
      return '周四'
    case 5:
      return '周无'
    case 6:
      return '周六'
  }
  return ''
}

export function getAqiColor(aqi?: number): Resource {
  aqi = aqi ?? 0
  if (aqi <= 50) {
    return $r('app.color.color_00e301')
  } else if (aqi > 50 && aqi <= 100) {
    return $r('app.color.color_fdfd01')
  } else if (aqi > 100 && aqi <= 150) {
    return $r('app.color.color_fd7e01')
  } else if (aqi > 150 && aqi <= 200) {
    return $r('app.color.color_f70001')
  } else if (aqi > 200 && aqi <= 300) {
    return $r('app.color.color_98004c')
  } else {
    return $r('app.color.color_7d0023')
  }
}
