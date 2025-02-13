import { Column, Table } from '@zxhhyj/storm';
import { SimpleWeatherData, TableSimpleWeatherData } from './SimpleWeatherData';

export interface CityData {
  id?: number
  key: string
  city_level_name?: string
  name?: string
  street?: string
  country?: string
  upper?: string
  prov?: string
  prov_en?: string
  cityid?: string
  city_level_id?: string
  isLocationCity: boolean
  weatherData?: SimpleWeatherData
}

export class CityDataTable extends Table<CityData> {
  readonly tableName = 't_city_data'
  readonly id = Column.integer('id').primaryKey(true).bindTo(this, 'id')
  readonly key = Column.text('key').default('').bindTo(this, 'key')
  readonly city_level_name = Column.text('city_level_name').default('').bindTo(this, 'city_level_name')
  readonly name = Column.text('name').default('').bindTo(this, 'name')
  readonly street = Column.text('street').default('').bindTo(this, 'street')
  readonly country = Column.text('country').default('').bindTo(this, 'country')
  readonly upper = Column.text('upper').default('').bindTo(this, 'upper')
  readonly prov = Column.text('prov').default('').bindTo(this, 'prov')
  readonly prov_en = Column.text('prov_en').default('').bindTo(this, 'prov_en')
  readonly cityid = Column.text('cityid').default('').bindTo(this, 'cityid')
  readonly city_level_id = Column.text('city_level_id').default('').bindTo(this, 'city_level_id')
  readonly isLocationCity = Column.boolean('isLocationCity').default(0).bindTo(this, 'isLocationCity')
  readonly weatherData =
    Column.references('simple_weather_data_id', TableSimpleWeatherData).default(null).bindTo(this, 'weatherData')
}

export const TableCityData = new CityDataTable()