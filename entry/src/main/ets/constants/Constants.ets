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
    this.ITEM_TYPE_WEATHER_HEADER.toString(),
    this.ITEM_TYPE_ALARMS.toString(),
    this.ITEM_TYPE_AIR_QUALITY.toString(),
    this.ITEM_TYPE_HOUR_WEATHER.toString(),
    this.ITEM_TYPE_DAILY_WEATHER.toString(),
    this.ITEM_TYPE_OBSERVE.toString(),
    this.ITEM_TYPE_LIFE_INDEX.toString(),
  ]

  public static readonly YYYYMMDD = 'yyyyMMdd'
}