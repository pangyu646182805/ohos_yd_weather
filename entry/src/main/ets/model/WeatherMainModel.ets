import { Constants } from "../constants/Constants";
import { appDatabase } from "../db/AppDatabase";
import { CityData } from "../db/model/CityData";
import { WeatherData } from "../entity/WeatherData";
import { Api } from "../net/Api";
import { netUtils } from "../net/NetUtils";
import { AppRuntimeData } from "../utils/AppRuntimeData";

export default class WeatherMainModel {
  async obtainWeatherData(): Promise<WeatherData> {
    const isLocationCity = AppRuntimeData.getInstance().currentCityData?.isLocationCity ?? false
    const currentCityId = AppRuntimeData.getInstance().currentCityData?.cityid ?? ''
    const key = isLocationCity ? Constants.LOCATION_CITY_ID : currentCityId
    return netUtils.netGetT<WeatherData>(Api.WEATHER_API, new Map([
      ['citykey', currentCityId],
    ]))
  }

  obtainAddedCityData(): Promise<Array<CityData>> {
    return appDatabase.cityDataDao.query()
  }
}