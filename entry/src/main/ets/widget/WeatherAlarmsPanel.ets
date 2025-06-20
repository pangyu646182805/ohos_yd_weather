import { AppUtil, DateUtil } from "@pura/harmony-utils"
import { Constants } from "../constants/Constants"
import { WeatherAlarmsData } from "../entity/WeatherData"
import { WeatherItemData } from "../entity/WeatherItemData"
import { ColorUtils } from "../utils/ColorUtils"
import { buildPathCommands, fixPercent } from "../utils/CommonUtils"
import { PathShape } from "@kit.ArkUI"
import { AnimationHelper, DialogHelper } from "@pura/harmony-dialog"
import { WeatherAlarmsDetailPopupBuilder } from "../dialog/WeatherAlarmsDetailPopup"
import { WeatherAlarmsDetailPopupOptions } from "../dialog/WeatherAlarmsDetailOptions"
import { PopupExitController } from "../dialog/PopupExitController"

@ComponentV2
export struct WeatherAlarmsPanel {
  @Param enable: boolean = true
  @Param weatherItemData?: WeatherItemData = undefined
  @Param isDark: boolean = false
  @Param panelOpacity: number = 0.1
  @Event showHideWeatherContent?: (show: boolean) => void
  @Local contentOpacity: number = 1
  @Local stickyTranslateY: number = 0
  @Local titleOpacity: number = 1
  @Local timeOpacity: number = 1
  @Local panelPathCommands: string = ''
  private alarmsDetailPopupRef = new PopupExitController()

  aboutToAppear(): void {
    if (this.enable) {
      this.panelPathCommands = buildPathCommands(Constants.WEATHER_ALARM_PANEL_HEIGHT)
    }
  }

  build() {
    ListItem() {
      Stack({ alignContent: Alignment.TopStart }) {
        Text('极端天气')
          .fontSize(12)
          .fontColor(ColorUtils.alpha($r('app.color.special_white'), 0.6))
          .width('100%')
          .height(Constants.ITEM_STICKY_HEIGHT)
          .padding({ left: Constants.ITEM_PANEL_MARGIN })
          .opacity(1 - this.timeOpacity)
          .translate({ y: this.stickyTranslateY })

        Swiper() {
          ForEach(this.weatherItemData?.weatherData?.alarms, (item: WeatherAlarmsData) => {
            this.alarmItem(item)
          }, (item: WeatherAlarmsData) => item.short_title)
        }
        .width('100%')
        .height(Constants.WEATHER_ALARM_PANEL_HEIGHT)
        .loop(false)
        .indicator(
          (this.weatherItemData?.weatherData?.alarms?.length ?? 0) <= 1 ? false :
          Indicator.dot()
            .itemWidth(3)
            .itemHeight(2)
            .selectedItemWidth(6)
            .selectedItemHeight(2)
            .color(ColorUtils.alpha($r('app.color.special_white'), 0.5))
            .selectedColor($r('app.color.special_white'))
        )
        .clipShape(this.enable ? new PathShape({ commands: this.panelPathCommands }) : undefined)
        .enabled(this.enable)
      }
      .id('weather_alarms_panel')
      .width('100%')
      .height(Constants.WEATHER_ALARM_PANEL_HEIGHT)
      .backgroundColor(ColorUtils.alpha(this.isDark ? $r('app.color.special_white') : $r('app.color.special_black'),
        this.panelOpacity))
      .borderRadius(Constants.ITEM_PANEL_RADIUS)
      .opacity(this.contentOpacity)
      .onAreaChange(this.enable ? (_, newValue) => {
        const y = newValue.globalPosition.y
        if (y) {
          const yValue = y as number
          const offset = px2vp(AppUtil.getStatusBarHeight()) + Constants.WEATHER_HEADER_MIN_HEIGHT - yValue
          const percent = fixPercent((offset - (Constants.WEATHER_ALARM_PANEL_HEIGHT - Constants.ITEM_STICKY_HEIGHT)) /
          Constants.ITEM_STICKY_HEIGHT)
          const stickyTranslateY =
            offset < 0 ? 0 : offset > Constants.WEATHER_ALARM_PANEL_HEIGHT - Constants.ITEM_STICKY_HEIGHT ?
              Constants.WEATHER_ALARM_PANEL_HEIGHT - Constants.ITEM_STICKY_HEIGHT : offset
          this.stickyTranslateY = stickyTranslateY + percent * Constants.ITEM_STICKY_HEIGHT * 0.5
          this.titleOpacity = fixPercent(1 - offset / 12)
          this.timeOpacity = fixPercent(1 - offset / 28)
          this.panelPathCommands = buildPathCommands(Constants.WEATHER_ALARM_PANEL_HEIGHT,
            offset + Constants.ITEM_STICKY_HEIGHT * fixPercent(offset / Constants.ITEM_STICKY_HEIGHT))
          // console.log('yValue = ' + offset + ' percent = ' + percent)
          this.contentOpacity = 1 - percent
        }
      } : undefined)
      .onClick(this.enable ? () => {
        if (this.showHideWeatherContent) {
          this.showHideWeatherContent(false)
        }
        DialogHelper.showCustomDialog(wrapBuilder(WeatherAlarmsDetailPopupBuilder), {
          dialogId: 'weather_alarms_detail_popup',
          alarms: this.weatherItemData?.weatherData?.alarms,
          isDark: this.isDark,
          panelOpacity: this.panelOpacity,
          ref: this.alarmsDetailPopupRef,
          backCancel: false,
          maskColor: $r('app.color.transparent'),
          transition: AnimationHelper.transitionInDown(0),
          onWillDismiss: () => {
            this.alarmsDetailPopupRef.exit()
          },
          onDidDisappear: () => {
            if (this.showHideWeatherContent) {
              this.showHideWeatherContent(true)
            }
          }
        } as WeatherAlarmsDetailPopupOptions)
      } : undefined)
    }
  }

  @Builder
  alarmItem(item: WeatherAlarmsData) {
    Column() {
      Blank().height(12)
      Text(item.short_title)
        .fontSize(16)
        .fontColor($r('app.color.special_white'))
        .fontWeight(FontWeight.Bold)
        .opacity(this.titleOpacity)
      Blank().height(6)
      Text(this.pubTimeDesc(item))
        .fontSize(13)
        .fontColor($r('app.color.special_white'))
        .opacity(this.timeOpacity)
      Blank().height(8)
      Text(item.desc)
        .fontSize(14)
        .fontColor($r('app.color.special_white'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16 })
  }

  pubTimeDesc(item: WeatherAlarmsData): string {
    let pubTimeDesc = ''
    const date = DateUtil.getFormatDate(item.pub_time)
    const diff = DateUtil.getToday().getTime() - date.getTime()
    const fewHours = Math.floor(diff / 1000 / 60 / 60)
    pubTimeDesc = `${fewHours}小时前更新`
    if (fewHours <= 0) {
      const fewMinutes = Math.floor(diff / 1000 / 60)
      pubTimeDesc = `${fewMinutes}分钟前更新`
      if (fewMinutes <= 0) {
        const fewMills = Math.floor(diff / 1000)
        pubTimeDesc = `${fewMills}秒前更新`
      }
    }
    return pubTimeDesc
  }
}