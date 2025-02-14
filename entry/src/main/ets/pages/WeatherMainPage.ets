import { Route } from '@hzw/zrouter'
import { RouterConstants } from '../constants/RouterConstants';
import { AppUtil } from '@pura/harmony-utils';
import WeatherMainViewModel from '../viewmodel/WeatherMainViewModel';

@Route({ name: RouterConstants.WEATHER_MAIN_PAGE })
@ComponentV2
export struct WeatherMainPage {
  @Local weatherMainVM: WeatherMainViewModel = new WeatherMainViewModel()

  aboutToAppear() {
    console.log('WeatherMainPage aboutToAppear')
    setTimeout(() => {
      this.weatherMainVM.obtainWeatherData()
    }, 2000)
  }

  build() {
    NavDestination() {
      Column() {
        Text(this.getText())
          .fontColor(Color.Black)
          .fontSize(14)
          .height('100%')
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .height('100%')
    .width('100%')
    .onBackPressed(() => {
      console.log('WeatherMainPage onBackPressed');
      AppUtil.getContext().terminateSelf()
      return true
    })
  }

  getText(): string {
    if (this.weatherMainVM.isLoading()) {
      return '天气数据加载中...'
    } else if (this.weatherMainVM.isError()) {
      return this.weatherMainVM.errorMessage
    } else {
      return this.weatherMainVM.weatherData
    }
  }
}