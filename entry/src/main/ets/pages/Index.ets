import { ZRouter } from '@hzw/zrouter';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Navigation(ZRouter.getNavStack()) {
      Column() {
        Image($r('app.media.splash'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      }
    }
    .mode(NavigationMode.Auto)
    .hideTitleBar(true)
    .height('100%')
    .width('100%')
  }
}