import { Route, TranslateAnimationOptions, ZRouter } from "@hzw/zrouter";
import { AppUtil, StrUtil } from "@pura/harmony-utils";
import { Constants } from "../constants/Constants";
import { RouterConstants } from "../constants/RouterConstants";
import { CityData } from "../db/model/CityData";
import { WeatherItemData } from "../entity/WeatherItemData";
import { AppRuntimeData } from "../utils/AppRuntimeData";
import { ColorUtils } from "../utils/ColorUtils";
import WeatherPreviewViewModel from "../viewmodel/WeatherPreviewViewModel";
import { MultipleStatusLayout } from "../widget/MultipleStatusLayout";
import { WeatherAirQualityPanel } from "../widget/WeatherAirQualityPanel";
import { WeatherAlarmsPanel } from "../widget/WeatherAlarmsPanel";
import { WeatherDailyPanel } from "../widget/WeatherDailyPanel";
import { WeatherHeaderWidget } from "../widget/WeatherHeaderWidget";
import { WeatherHourPanel } from "../widget/WeatherHourPanel";
import { WeatherLifeIndexPanel } from "../widget/WeatherLifeIndexPanel";
import { WeatherObservePanel } from "../widget/WeatherObservePanel";

@Route({ name: RouterConstants.WEATHER_PREVIEW_PAGE })
@ComponentV2
export struct WeatherPreviewPage {
  @Local previewCityData: CityData = ZRouter.getInstance().getParamByKey<CityData>(Constants.CITY_DATA)
  @Local weatherPreviewVM: WeatherPreviewViewModel = new WeatherPreviewViewModel()

  aboutToAppear(): void {
    const weatherData = AppRuntimeData.getInstance().currentCityData?.weatherData
    this.weatherPreviewVM.generateWeatherBg(undefined, weatherData?.weatherType, weatherData?.sunrise,
      weatherData?.sunset)
    this.weatherPreviewVM.obtainWeatherData(this.previewCityData.cityid ?? '')
  }

  @Builder
  functionButton(action: string, block: () => void) {
    Text(action)
      .textAlign(TextAlign.Center)
      .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
      .fontColor($r('app.color.special_white'))
      .fontSize(14)
      .padding({ left: 16, right: 16 })
      .backgroundColor(ColorUtils.alpha(this.weatherPreviewVM.isDark ? $r('app.color.special_white') :
      $r('app.color.special_black'), this.weatherPreviewVM.panelOpacity))
      .borderRadius(100)
      .height(32)
      .onClick(block)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Stack({ alignContent: Alignment.Top }) {
          MultipleStatusLayout({
            message: this.weatherPreviewVM.errorMessage,
            viewState: this.weatherPreviewVM.viewState,
            loadingProgressColor: $r('app.color.special_white'),
            contentView: () => {
              this.weatherContentList()
            }
          })
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
        .width('100%')
        .height('100%')
        .opacity(this.weatherPreviewVM.contentOpacity)
        .animation({ duration: 200, curve: Curve.Linear })
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: this.weatherPreviewVM.weatherBg
      })
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
    .backgroundColor($r('app.color.bg_color'))
  }

  @Builder
  weatherContentList() {
    Stack({ alignContent: Alignment.Top }) {
      List({ scroller: this.weatherPreviewVM.listScroller }) {
        ForEach(this.weatherPreviewVM.weatherItemsFilter, (item: WeatherItemData) => {
          if (item.itemType == Constants.ITEM_TYPE_ALARMS) {
            WeatherAlarmsPanel({
              weatherItemData: item,
              isDark: this.weatherPreviewVM.isDark,
              panelOpacity: this.weatherPreviewVM.panelOpacity,
              showHideWeatherContent: (show) => {
                this.weatherPreviewVM.showHideWeatherContent(show)
              }
            })
          } else if (item.itemType == Constants.ITEM_TYPE_AIR_QUALITY) {
            WeatherAirQualityPanel({
              weatherItemData: item,
              isDark: this.weatherPreviewVM.isDark,
              panelOpacity: this.weatherPreviewVM.panelOpacity,
              showHideWeatherContent: (show) => {
                this.weatherPreviewVM.showHideWeatherContent(show)
              }
            })
          } else if (item.itemType == Constants.ITEM_TYPE_HOUR_WEATHER) {
            WeatherHourPanel({
              weatherItemData: item,
              isDark: this.weatherPreviewVM.isDark,
              panelOpacity: this.weatherPreviewVM.panelOpacity
            })
          } else if (item.itemType == Constants.ITEM_TYPE_DAILY_WEATHER) {
            WeatherDailyPanel({
              weatherItemData: item,
              isDark: this.weatherPreviewVM.isDark,
              panelOpacity: this.weatherPreviewVM.panelOpacity
            })
          } else if (item.itemType == Constants.ITEM_TYPE_OBSERVE) {
            WeatherObservePanel({
              weatherItemData: item,
              itemTypeObserves: this.weatherPreviewVM.itemTypeObserves,
              isDark: this.weatherPreviewVM.isDark,
              isWeatherHeaderDark: this.weatherPreviewVM.isWeatherHeaderDark,
              panelOpacity: this.weatherPreviewVM.panelOpacity,
              showHideWeatherContent: (show) => {
                this.weatherPreviewVM.showHideWeatherContent(show)
              }
            })
          } else if (item.itemType == Constants.ITEM_TYPE_LIFE_INDEX) {
            WeatherLifeIndexPanel({
              weatherItemData: item,
              isDark: this.weatherPreviewVM.isDark,
              panelOpacity: this.weatherPreviewVM.panelOpacity
            })
          }
        }, (item: WeatherItemData) => item.itemType.toString())
        if (StrUtil.isNotEmpty(this.source)) {
          this.footer()
        }
      }
      .width('100%')
      .height(`calc(100% - ${px2vp(AppUtil.getStatusBarHeight()) + Constants.WEATHER_HEADER_MIN_HEIGHT}vp)`)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .divider({ strokeWidth: 12, color: $r('app.color.transparent') })
      .margin({ top: px2vp(AppUtil.getStatusBarHeight()) + Constants.WEATHER_HEADER_MIN_HEIGHT })
      .contentStartOffset(Constants.WEATHER_HEADER_MAX_HEIGHT - Constants.WEATHER_HEADER_MIN_HEIGHT)
      .borderRadius({ topLeft: Constants.ITEM_PANEL_RADIUS, topRight: Constants.ITEM_PANEL_RADIUS })
      .clip(true)
      .onDidScroll(() => {
        const yOffset = this.weatherPreviewVM.listScroller.currentOffset().yOffset
        this.weatherPreviewVM.setListOffset(yOffset +
          (Constants.WEATHER_HEADER_MAX_HEIGHT - Constants.WEATHER_HEADER_MIN_HEIGHT))
      })

      WeatherHeaderWidget({
        isWeatherHeaderDark: this.weatherPreviewVM.isWeatherHeaderDark,
        weatherItemData: this.weatherPreviewVM.weatherHeaderItemData,
        weatherHeaderOffset: this.weatherPreviewVM.listOffset
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: Constants.ITEM_PANEL_MARGIN, right: Constants.ITEM_PANEL_MARGIN })
  }

  get source() {
    return this.weatherPreviewVM.weatherItemsFilter?.[0].weatherData?.source?.title
  }

  @Builder
  footer() {
    ListItem() {
      Column() {
        Text(`天气信息来自${this.source}`)
          .fontSize(12)
          .fontColor(ColorUtils.alpha(this.weatherPreviewVM.isDark ? $r('app.color.special_white') :
          $r('app.color.special_black'), 0.4))
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: px2vp(AppUtil.getNavigationIndicatorHeight()) + 8 })
    }
  }
}