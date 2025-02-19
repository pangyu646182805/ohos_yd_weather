import { Route, TranslateAnimationOptions, ZRouter } from "@hzw/zrouter";
import { AppUtil } from "@pura/harmony-utils";
import { Constants } from "../constants/Constants";
import { RouterConstants } from "../constants/RouterConstants";
import { CityData } from "../db/model/CityData";
import { ColorUtils } from "../utils/ColorUtils";

@Route({ name: RouterConstants.WEATHER_PREVIEW_PAGE })
@ComponentV2
export struct WeatherPreviewPage {
  @Computed
  get previewCityData() {
    return ZRouter.getInstance().getParamByKey<CityData>(Constants.CITY_DATA)
  }

  @Builder
  functionButton(action: string, block: () => void) {
    Text(action)
      .textAlign(TextAlign.Center)
      .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
      .fontColor($r('app.color.special_white'))
      .fontSize(14)
      .padding({ left: 16, right: 16 })
      .backgroundColor(ColorUtils.alpha($r('app.color.special_black'), 0.5))
      .borderRadius(100)
      .height(32)
      .onClick(block)
  }

  build() {
    NavDestination() {
      Stack() {
        Text(this.previewCityData.name)
          .fontSize(22)
          .height('100%')
        Row() {
          this.functionButton('取消', () => {
            ZRouter.getInstance().pop()
          })
          this.functionButton('添加', () => {
            ZRouter.getInstance().popWithResult(this.previewCityData)
          })
        }
        .width('100%')
        .padding({ left: 12, top: px2vp(AppUtil.getStatusBarHeight()) + 12, right: 12 })
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .alignContent(Alignment.Top)
    }
    .hideTitleBar(true)
    .height('100%')
    .width('100%')
    .onReady((context) => {
      ZRouter.animateMgr()
        .registerAnimParam(this, context)
        .setEnterAnimate({ duration: 500, curve: Curve.LinearOutSlowIn })
        .setExitAnimate({ duration: 500, curve: Curve.LinearOutSlowIn })
        .addAnimateOptions(new TranslateAnimationOptions({ y: '100%' }))
    })
    .onDisAppear(() => {
      ZRouter.animateMgr().unregisterAnim(this)
    })
    .attributeModifier(ZRouter.animateMgr().modifier(this))
    .backgroundColor(Color.Black)
    .backgroundColor($r('app.color.bg_color'))
  }
}