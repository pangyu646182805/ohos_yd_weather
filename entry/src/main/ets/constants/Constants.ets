import { WeatherBgModel } from "../entity/WeatherBgModel"
import { WeatherBgUtils } from "../utils/WeatherBgUtils"

export class Constants {
  public static readonly LOCATION_CITY_ID = '-66208439'
  public static readonly CURRENT_CITY_ID = 'CURRENT_CITY_ID'
  public static readonly CURRENT_CITY_ID_LIST = 'CURRENT_CITY_ID_LIST'
  public static readonly CITY_DATA = 'CITY_DATA'
  public static readonly WEATHER_TYPE = 'WEATHER_TYPE'
  public static readonly WEATHER_BG_MODEL = 'WEATHER_BG_MODEL'
  public static readonly IS_EDIT = 'IS_EDIT'
  public static readonly IS_PREVIEW_MODE = 'IS_PREVIEW_MODE'
  public static readonly MAX_CITY_LIST_LENGTH = 20
  public static readonly CURRENT_WEATHER_CARD_SORT = 'CURRENT_WEATHER_CARD_SORT'
  public static readonly CURRENT_WEATHER_OBSERVES_CARD_SORT = 'CURRENT_WEATHER_OBSERVES_CARD_SORT'
  public static readonly CURRENT_DAILY_WEATHER_TYPE = 'CURRENT_DAILY_WEATHER_TYPE'
  public static readonly CURRENT_WEATHER_BG_MAP = 'CURRENT_WEATHER_BG_MAP'
  public static readonly LINE_CHART_DAILY_WEATHER = 'LINE_CHART_DAILY_WEATHER'
  public static readonly LIST_DAILY_WEATHER = 'LIST_DAILY_WEATHER'
  public static readonly ITEM_TYPE_WEATHER_HEADER = 0
  public static readonly ITEM_TYPE_HOUR_WEATHER = 1
  public static readonly ITEM_TYPE_DAILY_WEATHER = 2
  public static readonly ITEM_TYPE_AIR_QUALITY = 3
  public static readonly ITEM_TYPE_LIFE_INDEX = 4
  public static readonly ITEM_TYPE_ALARMS = 5
  // 紫外线、湿度、体感、风向、日出日落、气压、可见度、未来40日天气
  public static readonly ITEM_TYPE_OBSERVE = 6
  public static readonly MAX_WEATHER_BG_COUNT = 6
  public static readonly DEFAULT_WEATHER_CARD_SORT = [
    this.ITEM_TYPE_WEATHER_HEADER,
    this.ITEM_TYPE_ALARMS,
    this.ITEM_TYPE_AIR_QUALITY,
    this.ITEM_TYPE_HOUR_WEATHER,
    this.ITEM_TYPE_DAILY_WEATHER,
    this.ITEM_TYPE_OBSERVE,
    this.ITEM_TYPE_LIFE_INDEX
  ]
  public static readonly ITEM_TYPE_OBSERVE_UV = 0
  public static readonly ITEM_TYPE_OBSERVE_SHI_DU = 1
  public static readonly ITEM_TYPE_OBSERVE_TI_GAN = 2
  public static readonly ITEM_TYPE_OBSERVE_WD = 3
  public static readonly ITEM_TYPE_OBSERVE_SUNRISE_SUNSET = 4
  public static readonly ITEM_TYPE_OBSERVE_PRESSURE = 5
  public static readonly ITEM_TYPE_OBSERVE_VISIBILITY = 6
  public static readonly ITEM_TYPE_OBSERVE_FORECAST40 = 7
  public static readonly DEFAULT_WEATHER_OBSERVES_CARD_SORT = [
    this.ITEM_TYPE_OBSERVE_UV,
    this.ITEM_TYPE_OBSERVE_SHI_DU,
    this.ITEM_TYPE_OBSERVE_TI_GAN,
    this.ITEM_TYPE_OBSERVE_WD,
    this.ITEM_TYPE_OBSERVE_SUNRISE_SUNSET,
    this.ITEM_TYPE_OBSERVE_PRESSURE,
    this.ITEM_TYPE_OBSERVE_VISIBILITY,
    this.ITEM_TYPE_OBSERVE_FORECAST40
  ]
  public static readonly YYYYMMDD = 'yyyyMMdd'
  public static readonly YYYYMMDDHH = 'yyyyMMddHH'
  public static readonly WEATHER_HEADER_MAX_HEIGHT = 294
  public static readonly WEATHER_HEADER_MIN_HEIGHT = 94
  public static readonly ITEM_STICKY_HEIGHT = 32
  public static readonly ITEM_PANEL_MARGIN = 16
  public static readonly ITEM_PANEL_RADIUS = 12
  public static readonly WEATHER_ALARM_PANEL_HEIGHT = 124
  public static readonly WEATHER_AIR_QUALITY_PANEL_HEIGHT = 88
  public static readonly WEATHER_HOUR_PANEL_HEIGHT = 132
  public static readonly ITEM_OBSERVE_PANEL_HEIGHT = 128
  public static readonly DAILY_WEATHER_ITEM_HEIGHT = 48
  public static readonly DAILY_WEATHER_ITEM_COUNT = 10
  public static readonly DAILY_WEATHER_BOTTOM_HEIGHT = 32
  public static readonly DEFAULT_WEATHER_BG_MAP: Map<string, Array<WeatherBgModel>> = new Map(
    [
      ['CLEAR', [{
        isSelected: true,
        supportEdit: false,
        colors: WeatherBgUtils.generateWeatherBg('CLEAR', false),
        nightColors: WeatherBgUtils.generateWeatherBg('CLEAR', true)
      } as WeatherBgModel]],
      ['PARTLY_CLOUDY', [{
        isSelected: true,
        supportEdit: false,
        colors: WeatherBgUtils.generateWeatherBg('PARTLY_CLOUDY', false),
        nightColors: WeatherBgUtils.generateWeatherBg('PARTLY_CLOUDY', true)
      } as WeatherBgModel]],
      ['CLOUDY', [{
        isSelected: true,
        supportEdit: false,
        colors: WeatherBgUtils.generateWeatherBg('CLOUDY', false),
        nightColors: WeatherBgUtils.generateWeatherBg('CLOUDY', true)
      } as WeatherBgModel]],
      ['LIGHT_HAZE', [{
        isSelected: true,
        supportEdit: false,
        colors: WeatherBgUtils.generateWeatherBg('LIGHT_HAZE', false),
        nightColors: WeatherBgUtils.generateWeatherBg('LIGHT_HAZE', true)
      } as WeatherBgModel]],
      ['HEAVY_HAZE', [{
        isSelected: true,
        supportEdit: false,
        colors: WeatherBgUtils.generateWeatherBg('HEAVY_HAZE', false),
        nightColors: WeatherBgUtils.generateWeatherBg('HEAVY_HAZE', true)
      } as WeatherBgModel]],
      ['LIGHT_RAIN', [{
        isSelected: true,
        supportEdit: false,
        colors: WeatherBgUtils.generateWeatherBg('LIGHT_RAIN', false),
        nightColors: WeatherBgUtils.generateWeatherBg('LIGHT_RAIN', true)
      } as WeatherBgModel]],
      ['MODERATE_RAIN', [{
        isSelected: true,
        supportEdit: false,
        colors: WeatherBgUtils.generateWeatherBg('MODERATE_RAIN', false),
        nightColors: WeatherBgUtils.generateWeatherBg('MODERATE_RAIN', true)
      } as WeatherBgModel]],
      ['FOG', [{
        isSelected: true,
        supportEdit: false,
        colors: WeatherBgUtils.generateWeatherBg('FOG', false),
        nightColors: WeatherBgUtils.generateWeatherBg('FOG', true)
      } as WeatherBgModel]],
      ['LIGHT_SNOW', [{
        isSelected: true,
        supportEdit: false,
        colors: WeatherBgUtils.generateWeatherBg('LIGHT_SNOW', false),
        nightColors: WeatherBgUtils.generateWeatherBg('LIGHT_SNOW', true)
      } as WeatherBgModel]],
      ['DUST', [{
        isSelected: true,
        supportEdit: false,
        colors: WeatherBgUtils.generateWeatherBg('DUST', false),
        nightColors: WeatherBgUtils.generateWeatherBg('DUST', true)
      } as WeatherBgModel]],
      ['WIND', [{
        isSelected: true,
        supportEdit: false,
        colors: WeatherBgUtils.generateWeatherBg('WIND', false),
        nightColors: WeatherBgUtils.generateWeatherBg('WIND', true)
      } as WeatherBgModel]]
    ]
  )
}