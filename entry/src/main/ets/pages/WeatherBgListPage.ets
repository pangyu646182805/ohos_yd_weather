import { Logger } from "@hzw/logger";
import { Route, TranslateAnimationOptions, ZRouter } from "@hzw/zrouter";
import { AppUtil, DisplayUtil, EmitterUtil } from "@pura/harmony-utils";
import { CommonTitleBar, TitleType } from "common_title_bar";
import { Constants } from "../constants/Constants";
import { RouterConstants } from "../constants/RouterConstants";
import { WeatherBgModel } from "../entity/WeatherBgModel";
import { AppRuntimeData } from "../utils/AppRuntimeData";
import { ColorUtils } from "../utils/ColorUtils";
import { isDark, refreshStatusBar } from "../utils/CommonUtils";
import { EmitterManager } from "../utils/EmitterManager";
import WeatherBgListViewModel from "../viewmodel/WeatherBgListViewModel";

@Route({ name: RouterConstants.WEATHER_BG_LIST_PAGE })
@ComponentV2
export struct WeatherBgListPage {
  @Local weatherBgListVM: WeatherBgListViewModel = new WeatherBgListViewModel()

  aboutToAppear(): void {
    this.weatherBgListVM.getWeatherBgMap()
    EmitterUtil.onSubscribe<undefined>(EmitterManager.WEATHER_BG_MAP_CHANGED_EVENT, () => {
      Logger.e('refresh getWeatherBgMap')
      this.weatherBgListVM.getWeatherBgMap()
    })
  }

  aboutToDisappear() {
    EmitterUtil.unSubscribe(EmitterManager.WEATHER_BG_MAP_CHANGED_EVENT)
  }

  build() {
    NavDestination() {
      Column() {
        CommonTitleBar({
          statusBarColor: $r('app.color.transparent'),
          titleBarColor: $r('app.color.transparent'),
          showBottomLine: false,
          leftType: TitleType.CUSTOM,
          leftCustomView: () => {
            this.leftIcon()
          },
          centerText: '天气背景',
          centerTextColor: $r('app.color.black'),
          rightType: TitleType.TEXT,
          rightText: this.weatherBgListVM.isShowMenu ? '全部删除' : (this.weatherBgListVM.isNight ? '夜间' : '日间'),
          rightTextColor: $r('app.color.black'),
          rightOnClick: () => {
            if (this.weatherBgListVM.isShowMenu) {
              AppRuntimeData.getInstance().removeAllWeatherBg(() => {
                this.weatherBgListVM.isShowMenu = false
              })
            } else {
              this.weatherBgListVM.isNight = !this.weatherBgListVM.isNight
            }
          }
        })
        List() {
          ForEach(Array.from(this.weatherBgListVM.weatherBgMap?.keys() ?? []), (item: string) => {
            this.item(item)
          }, (item: string) => item)
          ListItem() {
            Divider()
              .strokeWidth(px2vp(AppUtil.getNavigationIndicatorHeight()))
              .color($r('app.color.transparent'))
          }
        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .onTouch(e => {
          if (e.type == TouchType.Down) {
            if (this.weatherBgListVM.isShowMenu) {
              this.weatherBgListVM.isShowMenu = false
            }
          }
        })
      }
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
    .onShown(() => {
      refreshStatusBar({
        isStatusBarLightIcon: isDark()
      })
    })
    .attributeModifier(ZRouter.animateMgr().modifier(this))
    .backgroundColor($r('app.color.bg_color'))
  }

  @Builder
  leftIcon() {
    Image($r('app.media.ic_close_icon1'))
      .width(20)
      .height(20)
      .colorFilter(ColorUtils.translateColor($r('app.color.black')))
      .onClick(() => {
        ZRouter.getInstance().pop()
      })
  }

  @Builder
  item(weatherType: string) {
    Column() {
      Text(this.title(weatherType))
        .width('100%')
        .height(42)
        .textAlign(TextAlign.Start)
        .fontSize(18)
        .fontColor($r('app.color.text_color_01'))
        .fontWeight(FontWeight.Bold)
      Grid() {
        ForEach(Array.from(this.weatherBgListVM.weatherBgMap?.get(weatherType) ?? []), (item: WeatherBgModel) => {
          this.gridItem(weatherType, item)
        }, (item: WeatherBgModel) => (item.colors?.toString() ?? '') + (item.isSelected ?? false))
        if (Array.from(this.weatherBgListVM.weatherBgMap?.get(weatherType) ?? []).length <
        Constants.MAX_WEATHER_BG_COUNT) {
          this.gridAddItem(weatherType,
            Array.from(this.weatherBgListVM.weatherBgMap?.get(weatherType) ?? []).find(e => e.isSelected ?? false))
        }
      }
      .width('100%')
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .maxCount(3)
      .layoutDirection(GridDirection.Row)
    }
    .width('100%')
    .padding({ left: 20, right: 20 })
  }

  @Builder
  gridItem(weatherType: string, item: WeatherBgModel) {
    GridItem() {
      Stack() {
        if (!this.weatherBgListVM.isShowMenu && (item.isSelected ?? false)) {
          Image($r('app.media.ic_xuanzhong'))
            .width(30)
            .height(30)
            .colorFilter(ColorUtils.translateColor(this.isSelectedIconDark(item) ? $r('app.color.special_white') :
            $r('app.color.special_black')))
            .draggable(false)
            .transition(TransitionEffect.opacity(0).animation({ curve: Curve.Ease, duration: 200 }))
        }
        if (this.weatherBgListVM.isShowMenu) {
          Column({ space: 12 }) {
            if (item.supportEdit ?? false) {
              Text('编辑')
                .width(48)
                .height(48)
                .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
                .borderRadius(100)
                .backgroundColor($r('app.color.special_white'))
                .textAlign(TextAlign.Center)
                .fontSize(15)
                .fontColor($r('app.color.special_black'))
                .hitTestBehavior(HitTestMode.Block)
                .onClick(() => {
                  this.weatherBgListVM.isShowMenu = false
                  ZRouter.getInstance()
                    .withParam(Constants.WEATHER_TYPE, weatherType)
                    .withParam(Constants.WEATHER_BG_MODEL, item)
                    .withParam(Constants.IS_EDIT, true)
                    .push(RouterConstants.WEATHER_BG_EDIT_PAGE)
                })
            }
            Text('预览')
              .width(48)
              .height(48)
              .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
              .borderRadius(100)
              .backgroundColor($r('app.color.special_white'))
              .textAlign(TextAlign.Center)
              .fontSize(15)
              .fontColor($r('app.color.special_black'))
              .hitTestBehavior(HitTestMode.Block)
              .onClick(() => {
                this.weatherBgListVM.isShowMenu = false
                ZRouter.getInstance()
                  .withParam(Constants.WEATHER_TYPE, weatherType)
                  .withParam(Constants.WEATHER_BG_MODEL, item)
                  .withParam(Constants.IS_PREVIEW_MODE, true)
                  .push(RouterConstants.WEATHER_BG_EDIT_PAGE)
              })
            if (item.supportEdit ?? false) {
              Text('删除')
                .width(48)
                .height(48)
                .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
                .borderRadius(100)
                .backgroundColor($r('app.color.special_white'))
                .textAlign(TextAlign.Center)
                .fontSize(15)
                .fontColor($r('app.color.special_black'))
                .hitTestBehavior(HitTestMode.Block)
                .onClick(() => {
                  this.weatherBgListVM.isShowMenu = false
                  AppRuntimeData.getInstance().removeWeatherBg(weatherType, item)
                })
            }
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .transition(TransitionEffect.opacity(0).animation({ curve: Curve.Ease, duration: 200 }))
        }
      }
      .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
      .width('100%')
      .aspectRatio(DisplayUtil.getWidth() / DisplayUtil.getHeight())
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: this.weatherBgListVM.isNight ? item.nightColors : item.colors
      })
      .borderRadius(16)
      .borderColor($r('app.color.black'))
      .borderWidth(this.similarity1(item) > 0.95 && this.similarity2(item) > 0.95 ? 1 : 0)
      .animation({ duration: 400, curve: Curve.Linear })
      .gesture(
        LongPressGesture()
          .onAction(() => {
            this.weatherBgListVM.isShowMenu = !this.weatherBgListVM.isShowMenu
          })
      )
      .onClick(() => {
        if (this.weatherBgListVM.isShowMenu) {
          this.weatherBgListVM.isShowMenu = false
        } else {
          if (!(item.isSelected ?? false)) {
            AppRuntimeData.getInstance().setCurrentWeatherBg(weatherType, item)
          }
        }
      })
    }
  }

  @Builder
  gridAddItem(weatherType: string, weatherBgModel?: WeatherBgModel) {
    GridItem() {
      Stack() {
        Stack()
          .width(2)
          .height(32)
          .borderRadius(16)
          .backgroundColor(ColorUtils.alpha($r('app.color.black'), 0.2))
        Stack()
          .width(32)
          .height(2)
          .borderRadius(16)
          .backgroundColor(ColorUtils.alpha($r('app.color.black'), 0.2))
      }
      .width('100%')
      .aspectRatio(DisplayUtil.getWidth() / DisplayUtil.getHeight())
      .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
      .borderRadius(16)
      .borderWidth(2)
      .borderColor(ColorUtils.alpha($r('app.color.black'), 0.2))
      .onClick(() => {
        this.weatherBgListVM.isShowMenu = false
        ZRouter.getInstance()
          .withParam(Constants.WEATHER_TYPE, weatherType)
          .withParam(Constants.WEATHER_BG_MODEL, weatherBgModel)
          .push(RouterConstants.WEATHER_BG_EDIT_PAGE)
      })
    }
  }

  title(weatherType: string) {
    switch (weatherType) {
      case "CLEAR":
        return "晴天"
      case "PARTLY_CLOUDY":
        return "多云"
      case "CLOUDY":
        return "阴"
      case "LIGHT_HAZE":
        return "轻度雾霾、中度雾霾"
      case "HEAVY_HAZE":
        return "重度雾霾"
      case "LIGHT_RAIN":
        return "小雨"
      case "MODERATE_RAIN":
        return "中雨、大雨、暴雨"
      case "FOG":
        return "雾"
      case "LIGHT_SNOW":
        return "小雪、中雪、大雪、暴雪"
      case "DUST":
        return "浮尘、沙尘"
      case "WIND":
        return "大风"
    }
    return ""
  }

  data() {
    return Array.from(this.weatherBgListVM.weatherBgMap?.values() ?? [])
  }

  itemData(index: number) {
    return this.data()[index]
  }

  isSelectedIconDark(item: WeatherBgModel) {
    const colors = this.weatherBg(item)
    const color = colors![0][0]
    return ColorUtils.estimateBrightnessForColor(color as Resource) == ColorMode.DARK
  }

  weatherBg(item: WeatherBgModel) {
    return this.weatherBgListVM.isNight ? item.nightColors : item.colors
  }

  similarity1(item: WeatherBgModel) {
    return ColorUtils.calSimilarity($r('app.color.bg_color'), this.weatherBg(item)?.[0][0] as Resource)
  }

  similarity2(item: WeatherBgModel) {
    return ColorUtils.calSimilarity($r('app.color.bg_color'), this.weatherBg(item)?.[1][0] as Resource)
  }
}