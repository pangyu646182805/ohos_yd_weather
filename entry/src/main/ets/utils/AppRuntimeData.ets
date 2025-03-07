import { Logger } from "@hzw/logger";
import { ZRouter } from "@hzw/zrouter";
import { EmitterUtil, PreferencesUtil, ToastUtil } from "@pura/harmony-utils";
import { Constants } from "../constants/Constants";
import { RouterConstants } from "../constants/RouterConstants";
import { appDatabase } from "../db/AppDatabase";
import { CityData, cityDataTable } from "../db/model/CityData";
import { emptySimpleWeatherData, simpleWeatherDataTable } from "../db/model/SimpleWeatherData";
import { EmitterManager } from "./EmitterManager";

export class AppRuntimeData {
  private static instance: AppRuntimeData
  private _currentCityData: CityData | null = null
  private _currentWeatherCardSort: Array<number> =
    PreferencesUtil.getSync(Constants.CURRENT_WEATHER_CARD_SORT, Constants.DEFAULT_WEATHER_CARD_SORT) as Array<number>

  private constructor() {
    Logger.e("invoke AppRuntimeData constructor")
  }

  static getInstance(): AppRuntimeData {
    if (!AppRuntimeData.instance) {
      AppRuntimeData.instance = new AppRuntimeData()
    }
    return AppRuntimeData.instance
  }

  get currentCityData() {
    return this._currentCityData
  }

  get currentWeatherCardSort() {
    return this._currentWeatherCardSort
  }

  setCurrentCityData(cityData: CityData | null) {
    this._currentCityData = cityData
    if (cityData != null) {
      const isLocationCity = cityData.isLocationCity
      PreferencesUtil.put(Constants.CURRENT_CITY_ID, isLocationCity ? Constants.LOCATION_CITY_ID : cityData.cityid)
    }
  }

  async addCity(cityData: CityData | null) {
    if (cityData == null) {
      ToastUtil.showToast('数据异常，请稍后再试')
      return
    }
    const list = await appDatabase.cityDataDao.query()
    const find = list.find(it => it.cityid == cityData.cityid)
    if (find) {
      ToastUtil.showToast('该城市已经添加过了哦')
      return
    }
    if (list.length > Constants.MAX_CITY_LIST_LENGTH) {
      ToastUtil.showToast('城市数量已达上限，如果想要添加新的城市，请先删除已有的城市。')
      return
    }
    const isLocationCity = cityData.isLocationCity
    if (isLocationCity) {
      await appDatabase.cityDataDao.updateIf(it => it.equalTo(cityDataTable.key, Constants.LOCATION_CITY_ID), cityData)
    } else {
      cityData.key = cityData.cityid ?? ''
      cityData.weatherData = emptySimpleWeatherData()
      await appDatabase.simpleWeatherDataDao.insert(cityData.weatherData)
      await appDatabase.cityDataDao.insert(cityData)
    }
    this.setCurrentCityData(cityData)
    const cityId = isLocationCity ? Constants.LOCATION_CITY_ID : cityData.cityid
    if (cityId) {
      const currentCityIdList = await PreferencesUtil.get(Constants.CURRENT_CITY_ID_LIST, []) as Array<string>
      currentCityIdList.push(cityId)
      await PreferencesUtil.put(Constants.CURRENT_CITY_ID_LIST, currentCityIdList)
    }
    EmitterUtil.post(EmitterManager.REFRESH_WEATHER_DATA_EVENT, true)
    if (ZRouter.getInstance().getAllPathName().length <= 1) {
      ZRouter.getInstance().replace(RouterConstants.WEATHER_MAIN_PAGE)
    } else {
      ZRouter.getInstance().popToName(RouterConstants.WEATHER_MAIN_PAGE)
    }
  }
}