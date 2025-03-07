import { ObjectUtil, StrUtil } from "@pura/harmony-utils";

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