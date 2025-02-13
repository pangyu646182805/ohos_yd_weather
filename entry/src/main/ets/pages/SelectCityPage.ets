import { Route, ZRouter } from "@hzw/zrouter";
import { AppUtil } from "@pura/harmony-utils";
import { RouterConstants } from "../constants/RouterConstants";

@Route({ name: RouterConstants.SELECT_CITY_PAGE })
@ComponentV2
export struct SelectCityPage {
  @Computed
  get exitApp() {
    return ZRouter.getInstance().getAllPathName().length <= 1;
  }

  @Builder
  SearchContent() {
    Search({
      placeholder: '搜索城市（中文/拼音）',
      icon: '/resources/base/media/ic_search_home.webp',
    })
      .backgroundColor($r('app.color.card_color_02'))
      .placeholderFont({ size: 16 })
      .placeholderColor($r('app.color.color_999999'))
      .searchIcon({ color: $r('app.color.color_999999') })
      .padding({ left: 8, right: 8 })
      .layoutWeight(1)
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          this.SearchContent()
          if (!this.exitApp) {
            Text('取消')
              .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
              .fontColor($r('app.color.color_999999'))
              .fontSize(16)
              .padding(8)
              .onClick(() => {
                ZRouter.getInstance().pop()
              })
          }
        }
        .padding({
          left: 16,
          top: 8,
          right: 8,
          bottom: 8,
        })

        Text('城市选择页面')
          .fontColor(Color.Black)
          .fontSize(16)
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .padding({ top: px2vp(AppUtil.getStatusBarHeight()) })
    .height('100%')
    .width('100%')
    .onBackPressed(() => {
      if (this.exitApp) {
        AppUtil.getContext().terminateSelf()
        return true
      }
      return false
    })
  }
}