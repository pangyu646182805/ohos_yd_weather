export class WeatherIconUtils {
  static getWeatherIconByType(type: number, weatherType: string, isNight: boolean): Resource {
    let result: Resource | undefined = undefined
    switch (weatherType) {
      case 'CLEAR':
      case 'CLEAR_DAY':
      case 'CLEAR_NIGHT':
        result = isNight ? $r('app.media.fifteen_weather_sunny_n') : $r('app.media.fifteen_weather_sunny')
        break
      case 'PARTLY_CLOUDY':
      case 'PARTLY_CLOUDY_DAY':
      case 'PARTLY_CLOUDY_NIGHT':
        result = isNight ? $r('app.media.fifteen_weather_mostlycloudy_n') : $r('app.media.fifteen_weather_mostlycloudy')
        break
      case 'CLOUDY':
        result = $r('app.media.fifteen_weather_cloudy')
        break
      case 'LIGHT_HAZE':
      case 'MODERATE_HAZE':
      case 'HEAVY_HAZE':
        result = $r('app.media.weather_icon_53')
        break
      case 'LIGHT_RAIN':
      case 'MODERATE_RAIN':
        result = $r('app.media.fifteen_weather_lightrain')
        break
      case 'HEAVY_RAIN':
      case 'STORM_RAIN':
        result = $r('app.media.fifteen_weather_rain')
        break
      case 'FOG':
        result = $r('app.media.weather_icon_18')
        break
      case 'LIGHT_SNOW':
        result = $r('app.media.weather_icon_14')
        break
      case 'MODERATE_SNOW':
        result = $r('app.media.weather_icon_15')
        break
      case 'HEAVY_SNOW':
        result = $r('app.media.weather_icon_16')
        break
      case 'STORM_SNOW':
        result = $r('app.media.weather_icon_17')
        break
      case 'DUST':
        result = $r('app.media.weather_icon_29')
        break
      case 'SAND':
        result = $r('app.media.weather_icon_30')
        break
      case 'WIND':
        result = $r('app.media.weather_icon_wind')
        break
    }
    if (!result) {
      if (!isNight) {
        switch (type) {
          case 1:
            // 晴天
            result = $r('app.media.fifteen_weather_sunny')
            break
          case 2:
            // 多云
            result = $r('app.media.fifteen_weather_mostlycloudy')
            break
          case 3:
            // 阵雨
            result = $r('app.media.fifteen_weather_chancerain')
            break
          case 4:
            // 雷阵雨
            result = $r('app.media.fifteen_weather_chancestorm')
            break
        }
      } else {
        switch (type) {
          case 1:
            // 晴天
            result = $r('app.media.fifteen_weather_sunny_n')
            break
          case 2:
            // 多云
            result = $r('app.media.fifteen_weather_mostlycloudy_n')
            break
          case 3:
            // 阵雨
            result = $r('app.media.fifteen_weather_chancerain_n')
            break
          case 4:
            // 雷阵雨
            result = $r('app.media.fifteen_weather_chancestorm_n')
            break
        }
      }
      if (!result) {
        switch (type) {
          case 8: // 小雨
          case 9: // 小到中雨
            result = $r('app.media.fifteen_weather_lightrain')
            break
          case 10: // 中雨
          case 11: // 大雨
          case 13: // 大暴雨
            result = $r('app.media.fifteen_weather_rain')
            break
          case 34: // 阴
            result = $r('app.media.fifteen_weather_cloudy')
            break
        }
      }
    }
    if (!result) {
      result = $r('app.media.fifteen_weather_no')
    }
    return result
  }
}