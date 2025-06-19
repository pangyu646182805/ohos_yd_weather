import { appDatabase } from "../db/AppDatabase";
import { CityData } from "../db/model/CityData";
import { WeatherData } from "../entity/WeatherData";
import { Api } from "../net/Api";
import { netUtils } from "../net/NetUtils";
import { AppRuntimeData } from "../utils/AppRuntimeData";

export default class WeatherMainModel {
  async obtainWeatherData(cityId?: string): Promise<WeatherData> {
    const currentCityId = cityId ?? AppRuntimeData.getInstance().currentCityData?.cityid ?? ''
    return netUtils.netGetT<WeatherData>(Api.WEATHER_API, new Map([
      ['citykey', currentCityId],
    ]))
  }

  obtainAddedCityData(): Promise<Array<CityData>> {
    return appDatabase.cityDataDao.query()
  }
}