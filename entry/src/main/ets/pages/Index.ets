import {
  OpacityAnimateOptions,
  RotateAnimateOptions,
  ScaleAnimateOptions,
  TranslateAnimationOptions,
  ZRouter
} from '@hzw/zrouter'
import { RouterConstants } from '../constants/RouterConstants'

@Entry
@Component
struct Index {
  @Provide('appPathStack') appPathStack: NavPathStack = ZRouter.getNavStack()

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
      .customNavContentTransition(ZRouter.animateMgr()// 创建默认动画管理器
        .defaultAnimateBuilder()// 设置进场动画参数
        .setEnterAnimate({ duration: 500 })// 设置退场动画参数
        .setExitAnimate({ duration: 700 })// 平移
        .addAnimateOptions(new TranslateAnimationOptions({ x: '50%', y: '50%' }))// 渐变
        .addAnimateOptions(new OpacityAnimateOptions(0.01))// 缩放
        .addAnimateOptions(new ScaleAnimateOptions({ x: 0, y: 0 }))// 旋转
        .addAnimateOptions(new RotateAnimateOptions({ angle: 90 }))// 自定义转场动画回调
        .getAnimCustomNavContentTransition())
  }
}