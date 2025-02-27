export class WeatherBgUtils {
  static generateWeatherBg(type: string, isDark: boolean): Array<[
    ResourceColor,
    number
  ]> {
    let color1 = isDark ? $r('app.color.color_1a1b30') : $r('app.color.color_f47359')
    let color2 = isDark ? $r('app.color.color_2e3c54') : $r('app.color.color_f1ab80')
    switch (type) {
      case 'CLEAR':
      case 'CLEAR_DAY':
      case 'CLEAR_NIGHT':
        // 晴天
        color1 = isDark ? $r('app.color.color_1a1b30') : $r('app.color.color_f47359')
        color2 = isDark ? $r('app.color.color_2e3c54') : $r('app.color.color_f1ab80')
        return [[color1, 0.0], [color2, 1.0]]
      case 'PARTLY_CLOUDY':
      case 'PARTLY_CLOUDY_DAY':
      case 'PARTLY_CLOUDY_NIGHT':
        // 多云
        color1 = isDark ? $r('app.color.color_2e336c') : $r('app.color.color_abb7c4')
        color2 = isDark ? $r('app.color.color_64648d') : $r('app.color.color_b6c7cd')
        return [[color1, 0.0], [color2, 1.0]]
      case 'CLOUDY':
        // 阴
        color1 = isDark ? $r('app.color.color_1e2232') : $r('app.color.color_58677f')
        color2 = isDark ? $r('app.color.color_354359') : $r('app.color.color_828d9e')
        return [[color1, 0.0], [color2, 1.0]]
      case 'LIGHT_HAZE':
      case 'MODERATE_HAZE':
        // 轻度雾霾 中度雾霾
        color1 = $r('app.color.color_bc8e3e')
        color2 = $r('app.color.color_e5bb62')
        return [[color1, 0.0], [color2, 1.0]]
      case 'HEAVY_HAZE':
        // 重度雾霾
        color1 = $r('app.color.color_b77b32')
        color2 = $r('app.color.color_f7ba66')
        return [[color1, 0.0], [color2, 1.0]]
      case 'LIGHT_RAIN':
        // 小雨
        color1 = isDark ? $r('app.color.color_171a2a') : $r('app.color.color_5e738d')
        color2 = isDark ? $r('app.color.color_3c4354') : $r('app.color.color_8f9aad')
        return [[color1, 0.0], [color2, 1.0]]
      case 'MODERATE_RAIN':
      case 'HEAVY_RAIN':
      case 'STORM_RAIN':
        // 中雨 大雨 暴雨
        color1 = $r('app.color.color_171a2a')
        color2 = $r('app.color.color_3c4354')
        return [[color1, 0.0], [color2, 1.0]]
      case 'FOG':
      case 'LIGHT_SNOW':
      case 'MODERATE_SNOW':
      case 'HEAVY_SNOW':
      case 'STORM_SNOW':
        // 雾 小雪 中雪 大雪 暴雪
        color1 = $r('app.color.color_abb7c4')
        color2 = $r('app.color.color_b6c7cd')
        return [[color1, 0.0], [color2, 1.0]]
      case 'DUST':
      case 'SAND':
        // 浮尘 沙尘
        color1 = $r('app.color.color_f7cb6a')
        color2 = $r('app.color.color_fda085')
        return [[color1, 0.0], [color2, 1.0]]
      case 'WIND':
        // 大风
        color1 = $r('app.color.color_4776b0')
        color2 = $r('app.color.color_e9a4b4')
        return [[color1, 0.0], [color2, 1.0]]
    }
    return [[color1, 0.0], [color2, 1.0]]
  }
}