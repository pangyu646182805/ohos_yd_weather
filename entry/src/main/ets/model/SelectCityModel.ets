import { appDatabase } from "../db/AppDatabase";
import { CityData } from "../db/model/CityData";
import { SelectCityData } from "../entity/SelectCityData";
import { Api } from "../net/Api";
import { netUtils } from "../net/NetUtils";
import { ResultData } from "../net/ResultData";
import { geoLocationManager } from "@kit.LocationKit";
import { LocationData } from "../entity/LocationData";

export default class SelectCityModel {
  obtainHotCityData(): Promise<ResultData<SelectCityData>> {
    return netUtils.netGet<SelectCityData>(Api.SELECT_CITY_API)
  }

  searchCity(searchKey: string): Promise<ResultData<Array<CityData>>> {
    return netUtils.netGet<Array<CityData>>(Api.SEARCH_CITY_API, new Map([
      ['keyword', searchKey],
    ]))
  }

  obtainLocationDataByLocation(location: geoLocationManager.Location): Promise<ResultData<LocationData>> {
    return netUtils.netGet<LocationData>(Api.LOCATION_API, new Map([
      ['location', location.latitude + ',' + location.longitude],
    ]))
  }

  obtainAddedCityData(): Promise<Array<CityData>> {
    return appDatabase.cityDataDao.query()
  }
}