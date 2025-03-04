import { Logger } from "@hzw/logger";
import BaseViewModel from "../base/BaseViewModel";
import { Constants } from "../constants/Constants";
import { ViewState } from "../constants/ViewState";
import { appDatabase } from "../db/AppDatabase";
import { CityData, cityDataTable } from "../db/model/CityData";
import { fromWeatherData, simpleWeatherDataTable } from "../db/model/SimpleWeatherData";
import { WeatherData } from "../entity/WeatherData";
import WeatherMainModel from "../model/WeatherMainModel";
import { AppRuntimeData } from "../utils/AppRuntimeData";
import { JSON } from "@kit.ArkTS";
import { ObjectUtil, PreferencesUtil } from "@pura/harmony-utils";

@ObservedV2
export default class WeatherMainViewModel extends BaseViewModel {
  @Trace addedCityData?: Array<CityData>
  private model = new WeatherMainModel()

  async obtainWeatherData(): Promise<void> {
    const isLocationCity = AppRuntimeData.getInstance().currentCityData?.isLocationCity ?? false
    const currentCityId = AppRuntimeData.getInstance().currentCityData?.cityid ?? ''
    const key = isLocationCity ? Constants.LOCATION_CITY_ID : currentCityId
    this.setViewState(ViewState.VIEW_STATE_LOADING)
    this.model.obtainWeatherData()
      .then((weatherData: WeatherData) => {
        this.setWeatherData(weatherData)
        this.setViewState(ViewState.VIEW_STATE_SUCCESS)
      })
      .catch((e: Error) => {
        this.setErrorMessage(e.message)
        this.setViewState(ViewState.VIEW_STATE_ERROR)
      })
  }

  private async setWeatherData(weatherData?: WeatherData) {
    const currentCityData = AppRuntimeData.getInstance().currentCityData
    if (currentCityData != null) {
      const isLocationCity = AppRuntimeData.getInstance().currentCityData?.isLocationCity ?? false
      const currentCityId = AppRuntimeData.getInstance().currentCityData?.cityid ?? ''
      const key = isLocationCity ? Constants.LOCATION_CITY_ID : currentCityId
      currentCityData.weatherData = fromWeatherData(weatherData)
      const find = await appDatabase.cityDataDao.queryOne(it => it.equalTo(cityDataTable.key, key))
      await appDatabase.simpleWeatherDataDao.updateIf(it => it.equalTo(simpleWeatherDataTable.id, find.id),
        currentCityData.weatherData)
      const updates = await appDatabase.cityDataDao.updateIf(it => it.equalTo(cityDataTable.key, key), currentCityData)
      Logger.e('SimpleWeatherData updates = ' + updates)
    }
    this.obtainAddedCityData()
  }

  obtainAddedCityData() {
    this.model.obtainAddedCityData()
      .then(async addedCityData => {
        Logger.e('addedCityData = ' + JSON.stringify(addedCityData))
        const currentCityIdList = await PreferencesUtil.get(Constants.CURRENT_CITY_ID_LIST, []) as Array<string>
        Logger.e('currentCityIdList = ' + JSON.stringify(currentCityIdList))
        const list: Array<CityData> = []
        currentCityIdList.forEach((cityId) => {
          const find = addedCityData.find(it => it.key == cityId)
          if (!ObjectUtil.isNull(find)) {
            if (cityId == Constants.LOCATION_CITY_ID) {
              list.splice(0, 0, find!)
            } else {
              list.push(find!)
            }
          }
        })
        Logger.e('addedCityData = ' + JSON.stringify(list))
        this.addedCityData = list
      })
  }

  hasData(): boolean {
    return false
  }
}