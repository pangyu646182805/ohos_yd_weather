import { ZRouter } from '@hzw/zrouter'
import { RouterConstants } from '../constants/RouterConstants'

@Entry
@Component
struct Index {
  build() {
    Navigation(ZRouter.getNavStack())
      .mode(NavigationMode.Auto)
      .hideTitleBar(true)
      .height('100%')
      .width('100%')
      .onAppear(() => {
        ZRouter.getInstance()
          .setAnimate(false)
          .push(RouterConstants.SPLASH_PAGE)
      })
  }
}