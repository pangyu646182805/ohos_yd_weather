import { ZRouter } from '@hzw/zrouter'
import { RouterConstants } from '../constants/RouterConstants'
import { Route } from '@hzw/zrouter'

@Route({ name: RouterConstants.SPLASH_PAGE })
@ComponentV2
export struct SplashPage {
  build() {
    NavDestination() {
      Column() {
        Image($r('app.media.splash'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      }
    }
    .hideTitleBar(true)
    .height('100%')
    .width('100%')
    .onAppear(() => {
      console.log('SplashPage aboutToAppear');
      setTimeout(() => {
        console.log("push")
        ZRouter.getInstance().replace(RouterConstants.WEATHER_MAIN_PAGE)
      }, 2000)
    })
    .onBackPressed(() => {
      console.log('onBackPressed');
      return true
    })
  }
}