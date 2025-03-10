export class Constants {
  public static readonly LOCATION_CITY_ID = '-66208439'
  public static readonly CURRENT_CITY_ID = 'CURRENT_CITY_ID'
  public static readonly CURRENT_CITY_ID_LIST = 'CURRENT_CITY_ID_LIST'
  public static readonly CITY_DATA = 'CITY_DATA'
  public static readonly MAX_CITY_LIST_LENGTH = 20
  public static readonly CURRENT_WEATHER_CARD_SORT = 'CURRENT_WEATHER_CARD_SORT'
  public static readonly CURRENT_WEATHER_OBSERVES_CARD_SORT = 'CURRENT_WEATHER_OBSERVES_CARD_SORT'
  public static readonly ITEM_TYPE_WEATHER_HEADER = 0
  public static readonly ITEM_TYPE_HOUR_WEATHER = 1
  public static readonly ITEM_TYPE_DAILY_WEATHER = 2
  public static readonly ITEM_TYPE_AIR_QUALITY = 3
  public static readonly ITEM_TYPE_LIFE_INDEX = 4
  public static readonly ITEM_TYPE_ALARMS = 5
  // 紫外线、湿度、体感、风向、日出日落、气压、可见度、未来40日天气
  public static readonly ITEM_TYPE_OBSERVE = 6
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
  public static readonly WEATHER_HEADER_MAX_HEIGHT = 294
  public static readonly WEATHER_HEADER_MIN_HEIGHT = 88
}