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
import { AnimatorResult, componentUtils } from "@kit.ArkUI";
import { WeatherDataUtils } from "../utils/WeatherDataUtils";

@ObservedV2
export default class WeatherMainViewModel extends BaseViewModel {
  @Trace addedCityData?: Array<CityData>
  @Trace pathCommands: string = ''
  @Trace contentVisibility: Visibility = Visibility.Visible
  @Trace animValue: number = 0
  @Trace contentOpacity: number = 1
  @Trace weatherBg: Array<[ResourceColor, number]> = []
  @Trace isWeatherHeaderDark: boolean = false
  @Trace isDark: boolean = false
  @Trace panelOpacity: number = 0.1
  private model = new WeatherMainModel()
  animatorOptions: AnimatorResult | undefined = undefined
  isShowCityManagerPage: boolean = false
  offsetY: number = 0

  async obtainWeatherData(scrollCityList?: () => void): Promise<void> {
    const isLocationCity = AppRuntimeData.getInstance().currentCityData?.isLocationCity ?? false
    const currentCityId = AppRuntimeData.getInstance().currentCityData?.cityid ?? ''
    const key = isLocationCity ? Constants.LOCATION_CITY_ID : currentCityId
    this.setViewState(ViewState.VIEW_STATE_LOADING)
    this.model.obtainWeatherData()
      .then((weatherData: WeatherData) => {
        this.setWeatherData(weatherData, scrollCityList)
        this.setViewState(ViewState.VIEW_STATE_SUCCESS)
      })
      .catch((e: Error) => {
        this.setErrorMessage(e.message)
        this.setViewState(ViewState.VIEW_STATE_ERROR)
      })
  }

  private async setWeatherData(weatherData?: WeatherData, scrollCityList?: () => void) {
    this.weatherBg = WeatherDataUtils.generateWeatherBg(weatherData)
    this.isWeatherHeaderDark = WeatherDataUtils.isWeatherHeaderDark(this.weatherBg)
    this.isDark = WeatherDataUtils.isDark(this.weatherBg)
    this.panelOpacity = WeatherDataUtils.calPanelOpacity(this.weatherBg)
    // WeatherDataUtils.generateWeatherItems()

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
    this.obtainAddedCityData(scrollCityList)
  }

  private obtainAddedCityData(scrollCityList?: () => void) {
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
        if (scrollCityList) {
          scrollCityList()
        }
      })
  }

  showCityManagerPage(itemRectangle: componentUtils.ComponentInfo | undefined) {
    if (itemRectangle) {
      this.isShowCityManagerPage = true
      this.offsetY = itemRectangle.windowOffset.y
      this.animatorOptions?.reset({
        duration: 400,
        delay: 0,
        easing: 'ease',
        iterations: 1,
        fill: "forwards",
        direction: 'normal',
        begin: 0,
        end: 1
      })
      this.animatorOptions?.play()
    }
  }

  showWeatherPage(itemRectangle: componentUtils.ComponentInfo | undefined) {
    if (!itemRectangle) {
      const currentCityData = AppRuntimeData.getInstance().currentCityData
      if (!ObjectUtil.isNull(currentCityData)) {
        const findIndex =
          this.addedCityData?.findIndex(it => it.cityid == currentCityData!.cityid) ?? -1
        if (findIndex >= 0) {
          itemRectangle = componentUtils.getRectangleById(`city_item_${findIndex}`)
        }
      }
    }
    if (itemRectangle) {
      this.isShowCityManagerPage = false
      this.offsetY = itemRectangle.windowOffset.y
      this.animatorOptions?.reverse()
    }
  }

  generateWeatherBg(weatherData?: WeatherData, cacheWeatherType?: string, cacheSunrise?: string,
    cacheSunset?: string) {
    this.weatherBg = WeatherDataUtils.generateWeatherBg(weatherData, cacheWeatherType, cacheSunrise, cacheSunset)
  }

  hasData(): boolean {
    return false
  }
}