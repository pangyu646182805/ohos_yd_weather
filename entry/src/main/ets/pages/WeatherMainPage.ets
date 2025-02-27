import { Route } from '@hzw/zrouter'
import { RouterConstants } from '../constants/RouterConstants';
import { AppUtil, EmitterUtil } from '@pura/harmony-utils';
import WeatherMainViewModel from '../viewmodel/WeatherMainViewModel';
import { CityManagerPage } from './CityManagerPage';
import { EmitterManager } from '../utils/EmitterManager';
import { Logger } from '@hzw/logger';
import CityManagerViewModel from '../viewmodel/CityManagerViewModel';

@Route({ name: RouterConstants.WEATHER_MAIN_PAGE })
@ComponentV2
export struct WeatherMainPage {
  @Local weatherMainVM: WeatherMainViewModel = new WeatherMainViewModel()
  @Provider('cityManagerVm') cityManagerVm: CityManagerViewModel = new CityManagerViewModel()

  aboutToAppear() {
    EmitterUtil.onSubscribe<undefined>(EmitterManager.REFRESH_WEATHER_DATA_EVENT, () => {
      Logger.e('REFRESH_WEATHER_DATA_EVENT')
      this.weatherMainVM.obtainWeatherData()
    })
    this.weatherMainVM.obtainAddedCityData()
    this.weatherMainVM.obtainWeatherData()
  }

  aboutToDisappear() {
    EmitterUtil.unSubscribe(EmitterManager.REFRESH_WEATHER_DATA_EVENT)
  }

  build() {
    NavDestination() {
      Stack() {
        CityManagerPage({ addedCityData: this.weatherMainVM.addedCityData })
        Column() {
          Text(this.getText())
            .fontColor(Color.Black)
            .fontSize(14)
            .height('100%')
        }
        .width('100%')
        .height('100%')
        .visibility(Visibility.Hidden)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .height('100%')
    .width('100%')
    .onBackPressed(() => {
      const isEditMode = this.cityManagerVm.isEditMode
      if (isEditMode) {
        this.cityManagerVm.closeEditMode()
      } else {
        AppUtil.getContext().terminateSelf()
      }
      return true
    })
  }

  getText(): string {
    if (this.weatherMainVM.isLoading()) {
      return '天气数据加载中...'
    } else if (this.weatherMainVM.isError()) {
      return this.weatherMainVM.errorMessage
    } else {
      return 'this.weatherMainVM.weatherData'
    }
  }
}