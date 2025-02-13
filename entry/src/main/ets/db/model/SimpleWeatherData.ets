import { Column, Table } from '@zxhhyj/storm';

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
  readonly tableName = 't_simple_weather_data'
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

export const TableSimpleWeatherData = new SimpleWeatherDataTable()