export interface WeatherData {
  future_remind?: string
  forecast15?: Array<WeatherDetailData>
  hourfc?: Array<WeatherHourData>
  meta?: WeatherMetaData
  source?: WeatherSourceData
  forecast40_v2?: WeatherForecast40Data
  forecast40?: Array<WeatherDetailData>
  evn?: WeatherEnvData
  indexes?: Array<WeatherIndexData>
  alarms?: Array<WeatherAlarmsData>
  observe?: WeatherObserveData
}

export interface WeatherDetailData {
  date?: string
  sunrise?: string
  sunset?: string
  type?: number
  third_type?: string
  high?: number
  low?: number
  wthr?: string
  wd?: string
  wp?: string
  aqi_level_name?: string
  aqi?: number
  uv_index?: number
  uv_index_max?: number
  uv_level?: string
  visibility?: string
  day?: WeatherInfoData
  night?: WeatherInfoData
}

export interface WeatherInfoData {
  bgPic?: string
  smPic?: string
  wthr?: string
  wd?: string
  wp?: string
  third_type?: string
  type?: number
}

export interface WeatherHourData {
  time?: string
  shidu?: string
  type?: number
  third_type?: string
  type_desc?: string
  wd?: string
  wp?: string
  wthr?: number
  sunriseAndSunset?: SunriseAndSunset
}

export interface SunriseAndSunset {
  sunrise?: string
  sunset?: string
}

export interface WeatherMetaData {
  citykey?: string
  city?: string
  html_url?: string
  upper?: string
}

export interface WeatherSourceData {
  title?: string
}

export interface WeatherForecast40Data {
  average_temp?: number
  up_days?: number
  down_days?: number
  rain_days?: number
}

export interface WeatherEnvData {
  aqi_level_name?: string
  mp?: string
  quality?: string
  aqi?: number
  aqi_level?: number
  co?: number
  no2?: number
  o3?: number
  pm10?: number
  pm25?: number
  so2?: number
}

export interface WeatherIndexData {
  name?: string
  value?: string
  desc?: string
  ext?: WeatherIndexExtData
}

export interface WeatherIndexExtData {
  icon?: string
}

export interface WeatherAlarmsData {
  short_title?: string
  desc?: string
  pub_time?: string
}

export interface WeatherObserveData {
  day?: WeatherInfoData
  night?: WeatherInfoData
  type?: number
  third_type?: string
  tigan?: string
  wthr?: string
  wd?: string
  wp?: string
  shidu?: string
  uv_level?: string
  pressure?: string
  visibility?: string
  temp?: number
  uv_index?: number
  uv_index_max?: number
}