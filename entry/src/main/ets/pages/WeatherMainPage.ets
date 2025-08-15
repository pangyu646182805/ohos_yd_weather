import { Route } from '@hzw/zrouter'
import { RouterConstants } from '../constants/RouterConstants';
import { AppUtil, EmitterUtil } from '@pura/harmony-utils';
import WeatherMainViewModel from '../viewmodel/WeatherMainViewModel';
import { CityManagerPage } from './CityManagerPage';
import { EmitterManager } from '../utils/EmitterManager';
import CityManagerViewModel from '../viewmodel/CityManagerViewModel';
import { WeatherPage } from '../widget/WeatherPage';
import { AppRuntimeData } from '../utils/AppRuntimeData';

@Route({ name: RouterConstants.WEATHER_MAIN_PAGE })
@ComponentV2
export struct WeatherMainPage {
  @Provider('weatherMainVM') weatherMainVM: WeatherMainViewModel = new WeatherMainViewModel()
  @Provider('cityManagerVm') cityManagerVm: CityManagerViewModel = new CityManagerViewModel()

  aboutToAppear() {
    EmitterUtil.onSubscribe<boolean>(EmitterManager.REFRESH_WEATHER_DATA_EVENT, (isAdd) => {
      this.weatherMainVM.obtainWeatherData(isAdd ? () => {
        console.log('scrollToBottom')
        this.cityManagerVm.scrollToBottom()
      } : undefined)
    })
    EmitterUtil.onSubscribe<undefined>(EmitterManager.WEATHER_CARD_SORT_CHANGED_EVENT, () => {
      this.weatherMainVM.reorder(AppRuntimeData.getInstance().currentWeatherCardSort)
    })
    EmitterUtil.onSubscribe<undefined>(EmitterManager.WEATHER_OBSERVES_CARD_SORT_CHANGED_EVENT, () => {
      this.weatherMainVM.reorderObserves()
    })
    EmitterUtil.onSubscribe<undefined>(EmitterManager.WEATHER_BG_CHANGED_EVENT, () => {
      this.weatherMainVM.onWeatherBgChanged()
    })
    // this.weatherMainVM.obtainAddedCityData()
    const weatherData = AppRuntimeData.getInstance().currentCityData?.weatherData
    this.weatherMainVM.generateWeatherBg(undefined, weatherData?.weatherType, weatherData?.sunrise, weatherData?.sunset)
    this.weatherMainVM.obtainWeatherData()
  }

  aboutToDisappear() {
    EmitterUtil.unSubscribe(EmitterManager.REFRESH_WEATHER_DATA_EVENT)
    EmitterUtil.unSubscribe(EmitterManager.WEATHER_CARD_SORT_CHANGED_EVENT)
    EmitterUtil.unSubscribe(EmitterManager.WEATHER_OBSERVES_CARD_SORT_CHANGED_EVENT)
    EmitterUtil.unSubscribe(EmitterManager.WEATHER_BG_CHANGED_EVENT)
  }

  build() {
    NavDestination() {
      Stack() {
        CityManagerPage({
          addedCityData: this.weatherMainVM.addedCityData,
          showWeatherPage: (itemRectangle) => {
            this.weatherMainVM.showWeatherPage(itemRectangle)
          }
        })
        WeatherPage({
          showCityManagerPage: () => {
            return this.cityManagerVm.checkItemBorder(this.weatherMainVM.addedCityData)
          },
          showCityList: () => {
            this.cityManagerVm.showCityList(this.weatherMainVM.addedCityData)
          },
          hideCityList: () => {
            this.cityManagerVm.hideCityList()
          }
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .height('100%')
    .width('100%')
    .onShown(() => {
      this.weatherMainVM.isWeatherMainPageShown = true
      if (this.weatherMainVM.isShowCityManagerPage) {
        this.weatherMainVM.refreshCityManagerPageStatusBar()
      } else {
        this.weatherMainVM.refreshStatusBar()
      }
    })
    .onHidden(() => {
      this.weatherMainVM.isWeatherMainPageShown = false
    })
    .onBackPressed(() => {
      const isEditMode = this.cityManagerVm.isEditMode
      if (isEditMode) {
        this.cityManagerVm.closeEditMode()
      } else if (this.weatherMainVM.isShowCityManagerPage) {
        this.weatherMainVM.showWeatherPage(undefined)
      } else {
        AppUtil.getContext().terminateSelf()
      }
      return true
    })
  }
}