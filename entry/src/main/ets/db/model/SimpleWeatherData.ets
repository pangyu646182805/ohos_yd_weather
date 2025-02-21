import { DateUtil, StrUtil } from '@pura/harmony-utils';
import { Column, Table } from '@zxhhyj/storm';
import { Constants } from '../../constants/Constants';
import { WeatherData } from '../../entity/WeatherData';

export interface SimpleWeatherData {
  id?: number
  city: string
  temp: number
  tempHigh: number
  tempLow: number
  weatherType: string
  weatherDesc: string
  sunrise: string
  sunset: string
}

export class SimpleWeatherDataTable extends Table<SimpleWeatherData> {
  override readonly tableName = 't_simple_weather_data'
  readonly id = Column.integer('id').primaryKey(true).bindTo(this, 'id')
  readonly city = Column.text('city').default('').bindTo(this, 'city')
  readonly temp = Column.integer('temp').default(0).bindTo(this, 'temp')
  readonly tempHigh = Column.integer('tempHigh').default(0).bindTo(this, 'tempHigh')
  readonly tempLow = Column.integer('tempLow').default(0).bindTo(this, 'tempLow')
  readonly weatherType = Column.text('weatherType').default('').bindTo(this, 'weatherType')
  readonly weatherDesc = Column.text('weatherDesc').default('').bindTo(this, 'weatherDesc')
  readonly sunrise = Column.text('sunrise').default('').bindTo(this, 'sunrise')
  readonly sunset = Column.text('sunset').default('').bindTo(this, 'sunset')
}

export function emptySimpleWeatherData(): SimpleWeatherData {
  return fromWeatherData()
}

export function fromWeatherData(weatherData?: WeatherData): SimpleWeatherData {
  const currentWeatherDetailData = weatherData?.forecast15?.find(it => StrUtil.equal(it.date,
    DateUtil.getFormatDateStr(DateUtil.getToday(), Constants.YYYYMMDD)))
  return {
    city: weatherData?.meta?.city ?? '',
    temp: weatherData?.observe?.temp ?? 0,
    tempHigh: currentWeatherDetailData?.high ?? 0,
    tempLow: currentWeatherDetailData?.low ?? 0,
    weatherType: weatherData?.observe?.third_type ?? currentWeatherDetailData?.third_type ?? '',
    weatherDesc: weatherData?.observe?.wthr ?? currentWeatherDetailData?.wthr ?? '',
    sunrise: currentWeatherDetailData?.sunrise ?? '',
    sunset: currentWeatherDetailData?.sunset ?? ''
  } as SimpleWeatherData
}

export const simpleWeatherDataTable = new SimpleWeatherDataTable()