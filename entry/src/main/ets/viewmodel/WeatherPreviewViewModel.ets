import BaseViewModel from "../base/BaseViewModel";
import { Constants } from "../constants/Constants";
import { ViewState } from "../constants/ViewState";
import { WeatherData } from "../entity/WeatherData";
import { WeatherItemData } from "../entity/WeatherItemData";
import WeatherMainModel from "../model/WeatherMainModel";
import { AppRuntimeData } from "../utils/AppRuntimeData";
import { refreshStatusBar } from "../utils/CommonUtils";
import { WeatherDataUtils } from "../utils/WeatherDataUtils";

@ObservedV2
export default class WeatherPreviewViewModel extends BaseViewModel {
  @Trace weatherItems?: Array<WeatherItemData>
  @Trace itemTypeObserves?: Array<number>
  @Trace weatherBg: Array<[ResourceColor, number]> = []
  @Trace isWeatherHeaderDark: boolean = false
  @Trace isDark: boolean = false
  @Trace panelOpacity: number = 0.1
  @Trace listOffset: number = 0
  @Trace contentOpacity: number = 1
  private model = new WeatherMainModel()
  listScroller: ListScroller = new ListScroller()

  async obtainWeatherData(cityId: string): Promise<void> {
    this.setViewState(ViewState.VIEW_STATE_LOADING)
    this.model.obtainWeatherData(cityId)
      .then((weatherData: WeatherData) => {
        this.generateWeatherItems(weatherData)
        this.setViewState(ViewState.VIEW_STATE_SUCCESS)
        this.refreshStatusBar()
      })
      .catch((e: Error) => {
        this.setErrorMessage(e.message)
        this.setViewState(ViewState.VIEW_STATE_ERROR)
        this.refreshStatusBar()
      })
  }

  refreshStatusBar() {
    refreshStatusBar({
      isStatusBarLightIcon: this.isWeatherHeaderDark
    })
  }

  private generateWeatherItems(weatherData?: WeatherData) {
    // 生成天气背景
    this.weatherBg = WeatherDataUtils.generateWeatherBg(weatherData)
    // 根据天气背景计算天气头部是否是dark模式
    this.isWeatherHeaderDark = WeatherDataUtils.isWeatherHeaderDark(this.weatherBg)
    // 根据天气背景计算天气内容是否是dark模式
    this.isDark = WeatherDataUtils.isDark(this.weatherBg)
    // 根据天气背景计算天气面板的透明度
    this.panelOpacity = WeatherDataUtils.calPanelOpacity(this.weatherBg)
    this.itemTypeObserves =
      WeatherDataUtils.getItemTypeObserves(AppRuntimeData.getInstance().currentWeatherObservesCardSort,
        Constants.ITEM_TYPE_OBSERVE, weatherData)
    // 生成天气items数据
    this.weatherItems = WeatherDataUtils.generateWeatherItems(AppRuntimeData.getInstance().currentWeatherCardSort,
      this.itemTypeObserves, weatherData)
  }

  generateWeatherBg(weatherData?: WeatherData, cacheWeatherType?: string, cacheSunrise?: string,
    cacheSunset?: string) {
    this.weatherBg = WeatherDataUtils.generateWeatherBg(weatherData, cacheWeatherType, cacheSunrise, cacheSunset)
    this.isWeatherHeaderDark = WeatherDataUtils.isWeatherHeaderDark(this.weatherBg)
    this.isDark = WeatherDataUtils.isDark(this.weatherBg)
    this.panelOpacity = WeatherDataUtils.calPanelOpacity(this.weatherBg)
  }

  get weatherItemsFilter() {
    return this.weatherItems?.filter(it => it.itemType != Constants.ITEM_TYPE_WEATHER_HEADER)
  }

  get weatherHeaderItemData() {
    return this.weatherItems?.find(it => it.itemType == Constants.ITEM_TYPE_WEATHER_HEADER)
  }

  setListOffset(listOffset: number) {
    this.listOffset = listOffset
  }

  showHideWeatherContent(show: boolean) {
    this.contentOpacity = show ? 1 : 0
  }
}