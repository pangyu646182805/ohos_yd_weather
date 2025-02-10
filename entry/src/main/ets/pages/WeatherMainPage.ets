import { Route } from '@hzw/zrouter'
import { RouterConstants } from '../constants/RouterConstants';
import { common } from '@kit.AbilityKit';
import axios, { AxiosResponse, AxiosInstance, AxiosError } from '@ohos/axios';
import { Api } from '../net/Api';
import { Logger } from '@hzw/logger';

const axiosInstance: AxiosInstance = axios.create({
  // 设置超时时间
  timeout: 100000,
  headers: {
    'Content-Type': 'application/json;charset=utf-8',
    'Content-Language': 'zh_CN'
  },
});

@Route({ name: RouterConstants.WEATHER_MAIN_PAGE })
@ComponentV2
export struct WeatherMainPage {
  @Local data: string = '主页面'

  aboutToAppear(): void {
    console.log('WeatherMainPage aboutToAppear')
    axiosInstance.get<string, AxiosResponse<string>, null>(Api.WEATHER_API, {
      params: {
        'citykey': 101210113
      }
    }).then((response: AxiosResponse<string>) => {
      this.data = JSON.stringify(response)
      Logger.e('data = ' + this.data)
    }).catch((error: AxiosError) => {
      this.data = JSON.stringify(error)
      Logger.e('error = ' + this.data)
    }).then(() => {
      // 总是会执行
      Logger.e('finished')
    });
  }

  build() {
    NavDestination() {
      Column() {
        Text(this.data)
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
      let context = getContext(this) as common.UIAbilityContext
      context.terminateSelf()
      return true
    })
  }
}