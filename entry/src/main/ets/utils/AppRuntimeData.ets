import { Logger } from "@hzw/logger";
import { ZRouter } from "@hzw/zrouter";
import { ArrayUtil, EmitterUtil, JSONUtil, ObjectUtil, PreferencesUtil, ToastUtil } from "@pura/harmony-utils";
import { Constants } from "../constants/Constants";
import { RouterConstants } from "../constants/RouterConstants";
import { appDatabase } from "../db/AppDatabase";
import { CityData, cityDataTable } from "../db/model/CityData";
import { emptySimpleWeatherData } from "../db/model/SimpleWeatherData";
import { equalsWeatherBgModel, WeatherBgModel } from "../entity/WeatherBgModel";
import { WeatherData } from "../entity/WeatherData";
import { ColorUtils } from "./ColorUtils";
import { EmitterManager } from "./EmitterManager";

export class AppRuntimeData {
  private static instance: AppRuntimeData
  private _currentCityData: CityData | null = null
  private _currentWeatherCardSort: Array<number> =
    PreferencesUtil.getSync(Constants.CURRENT_WEATHER_CARD_SORT, Constants.DEFAULT_WEATHER_CARD_SORT) as Array<number>
  private _currentWeatherObservesCardSort: Array<number> =
    PreferencesUtil.getSync(Constants.CURRENT_WEATHER_OBSERVES_CARD_SORT,
      Constants.DEFAULT_WEATHER_OBSERVES_CARD_SORT) as Array<number>
  private _weatherDataMap: Map<string, WeatherData | undefined> = new Map()
  private _weatherBgMap: Map<string, Array<WeatherBgModel>> = new Map()

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

  get currentWeatherObservesCardSort() {
    return this._currentWeatherObservesCardSort
  }

  setCurrentWeatherCardSort(currentWeatherCardSort: Array<number>) {
    this._currentWeatherCardSort = currentWeatherCardSort
    PreferencesUtil.put(Constants.CURRENT_WEATHER_CARD_SORT, currentWeatherCardSort)
      .then(() => {
        EmitterUtil.post(EmitterManager.WEATHER_CARD_SORT_CHANGED_EVENT, undefined)
      })
  }

  setCurrentWeatherObservesCardSort(currentWeatherObservesCardSort: Array<number>) {
    this._currentWeatherObservesCardSort = currentWeatherObservesCardSort
    PreferencesUtil.put(Constants.CURRENT_WEATHER_OBSERVES_CARD_SORT, currentWeatherObservesCardSort)
      .then(() => {
        EmitterUtil.post(EmitterManager.WEATHER_OBSERVES_CARD_SORT_CHANGED_EVENT, undefined)
      })
  }

  setCurrentCityData(cityData: CityData | null) {
    this._currentCityData = cityData
    if (cityData != null) {
      const isLocationCity = cityData.isLocationCity
      PreferencesUtil.put(Constants.CURRENT_CITY_ID, isLocationCity ? Constants.LOCATION_CITY_ID : cityData.cityid)
    }
  }

  saveWeatherData(cityId: string, weatherData: WeatherData | undefined) {
    if (weatherData) {
      this._weatherDataMap.set(cityId, weatherData)
      console.log('_weatherDataMap size = ' + this._weatherDataMap.size)
      PreferencesUtil.put(cityId, weatherData)
    } else {
      this._weatherDataMap.delete(cityId)
      PreferencesUtil.put(cityId, '')
    }
  }

  getWeatherData(cityId: string): WeatherData | undefined {
    const weatherData = this._weatherDataMap.get(cityId)
    if (weatherData) {
      return weatherData
    }
    return PreferencesUtil.getSync(cityId, undefined) as WeatherData | undefined
  }

  getWeatherBgMap(): Map<string, Array<WeatherBgModel>> {
    if (this._weatherBgMap.size <= 0) {
      const currentWeatherBgMapJson =
        PreferencesUtil.getSync(Constants.CURRENT_WEATHER_BG_MAP, '') as string
      const currentWeatherBgMap = JSONUtil.jsonToMap(currentWeatherBgMapJson) as Map<string, Array<WeatherBgModel>>

      if (currentWeatherBgMap.size <= 0) {
        PreferencesUtil.putSync(Constants.CURRENT_WEATHER_BG_MAP,
          JSONUtil.mapToJsonStr(Constants.DEFAULT_WEATHER_BG_MAP))
        this._weatherBgMap = new Map(Constants.DEFAULT_WEATHER_BG_MAP)
      } else {
        this._weatherBgMap = new Map(currentWeatherBgMap)
      }
    }
    return this._weatherBgMap
  }

  addWeatherBg(weatherType: string, weatherBgModel: WeatherBgModel, block: () => void,
    editWeatherBgModel?: WeatherBgModel) {
    const currentWeatherBgMap = this.getWeatherBgMap()
    const result = currentWeatherBgMap.get(weatherType)?.filter(e => {
      const addColor1 = weatherBgModel.colors?.[0][0]
      const addColor2 = weatherBgModel.colors?.[1][0]
      const addNightColor1 = (weatherBgModel.nightColors ?? weatherBgModel.colors)?.[0][0]
      const addNightColor2 = (weatherBgModel.nightColors ?? weatherBgModel.colors)?.[1][0]
      const color1 = e.colors?.[0][0]
      const color2 = e.colors?.[1][0]
      const nightColor1 = (e.nightColors ?? e.colors)?.[0][0]
      const nightColor2 = (e.nightColors ?? e.colors)?.[1][0]
      const similarity1 = ColorUtils.calSimilarity(addColor1 as Resource, color1 as Resource)
      const similarity2 = ColorUtils.calSimilarity(addColor2 as Resource, color2 as Resource)
      const nightSimilarity1 = ColorUtils.calSimilarity(addNightColor1 as Resource, nightColor1 as Resource)
      const nightSimilarity2 = ColorUtils.calSimilarity(addNightColor2 as Resource, nightColor2 as Resource)
      Logger.e(`similarity1 = ${similarity1} similarity2 = ${similarity2} nightSimilarity1 = ${nightSimilarity1} nightSimilarity2 = ${nightSimilarity2}`)
      return (similarity1 > 0.95 && similarity2 > 0.95) &&
        (nightSimilarity1 > 0.95 && nightSimilarity2 > 0.95)
    })
    if (ArrayUtil.isNotEmpty(result)) {
      ToastUtil.showToast('天气背景相似度过高，请重新编辑！')
      return
    }
    const list = currentWeatherBgMap.get(weatherType) ?? []
    const index =
      ObjectUtil.isNull(editWeatherBgModel) ? -1 : list.findIndex(e => equalsWeatherBgModel(e, editWeatherBgModel))
    Logger.e('editWeatherBgModel findIndex = ' + index)
    if (index >= 0) {
      list[index] = weatherBgModel
    } else {
      list.push(weatherBgModel)
    }
    currentWeatherBgMap.set(weatherType, list)
    PreferencesUtil.put(Constants.CURRENT_WEATHER_BG_MAP, JSONUtil.mapToJsonStr(currentWeatherBgMap)).then(() => {
      Logger.e('addWeatherBg success')
      EmitterUtil.post(EmitterManager.WEATHER_BG_MAP_CHANGED_EVENT, undefined)
      if (editWeatherBgModel) {
        EmitterUtil.post(EmitterManager.WEATHER_BG_CHANGED_EVENT, undefined)
      }
      block()
    })
  }

  setCurrentWeatherBg(weatherType: string, weatherBgModel: WeatherBgModel) {
    const currentWeatherBgMap = this.getWeatherBgMap()
    currentWeatherBgMap.get(weatherType)?.forEach(e => e.isSelected = equalsWeatherBgModel(e, weatherBgModel))
    PreferencesUtil.put(Constants.CURRENT_WEATHER_BG_MAP, JSONUtil.mapToJsonStr(currentWeatherBgMap)).then(() => {
      Logger.e('setCurrentWeatherBg success')
      EmitterUtil.post(EmitterManager.WEATHER_BG_MAP_CHANGED_EVENT, undefined)
      EmitterUtil.post(EmitterManager.WEATHER_BG_CHANGED_EVENT, undefined)
    })
  }

  removeWeatherBg(weatherType: string, weatherBgModel: WeatherBgModel) {
    const currentWeatherBgMap = this.getWeatherBgMap()
    const index = currentWeatherBgMap.get(weatherType)?.findIndex(e => equalsWeatherBgModel(e, weatherBgModel)) ?? -1
    if (index >= 0) {
      currentWeatherBgMap.get(weatherType)?.splice(index, 1)
    }
    if (weatherBgModel.isSelected ?? false) {
      const first = currentWeatherBgMap.get(weatherType)?.[0]
      if (first) {
        first.isSelected = true
      }
    }
    PreferencesUtil.put(Constants.CURRENT_WEATHER_BG_MAP, JSONUtil.mapToJsonStr(currentWeatherBgMap)).then(() => {
      Logger.e('removeWeatherBg success')
      EmitterUtil.post(EmitterManager.WEATHER_BG_MAP_CHANGED_EVENT, undefined)
      if (weatherBgModel.isSelected ?? false) {
        EmitterUtil.post(EmitterManager.WEATHER_BG_CHANGED_EVENT, undefined)
      }
    })
  }

  removeAllWeatherBg(block: () => void) {
    PreferencesUtil.put(Constants.CURRENT_WEATHER_BG_MAP, JSONUtil.mapToJsonStr(Constants.DEFAULT_WEATHER_BG_MAP))
      .then(() => {
        Logger.e('removeAllWeatherBg success')
        this._weatherBgMap.clear()
        EmitterUtil.post(EmitterManager.WEATHER_BG_MAP_CHANGED_EVENT, undefined)
        EmitterUtil.post(EmitterManager.WEATHER_BG_CHANGED_EVENT, undefined)
        block()
      })
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