import { DateUtil } from "@pura/harmony-utils"
import { Constants } from "../constants/Constants"
import { WeatherAlarmsData } from "../entity/WeatherData"
import { ColorUtils } from "../utils/ColorUtils"
import { WeatherAlarmsDetailPopupOptions } from "./WeatherAlarmsDetailOptions"
import { componentUtils } from "@kit.ArkUI"
import { DialogHelper } from "@pura/harmony-dialog"

@Builder
export function WeatherAlarmsDetailPopupBuilder(options: WeatherAlarmsDetailPopupOptions) {
  WeatherAlarmsDetailPopup({ options: options })
}

@ComponentV2
export struct WeatherAlarmsDetailPopup {
  @Require @Param options: WeatherAlarmsDetailPopupOptions
  @Local animHeight: number = Constants.WEATHER_ALARM_PANEL_HEIGHT
  @Local contentOpacity: number = 0
  @Local marginTop: number = 0
  @Local alignment: FlexAlign = FlexAlign.Start
  private heights: Array<number> = []

  aboutToAppear(): void {
    this.options.ref.exit = this.exit
    const weatherAlarmsPanelRectangle = componentUtils.getRectangleById('weather_alarms_panel')
    this.marginTop = px2vp(weatherAlarmsPanelRectangle.windowOffset.y)
    setTimeout(() => {
      this.contentOpacity = 1
      this.marginTop = 0
      this.alignment = FlexAlign.Center
    }, 16)
  }

  exit = () => {
    const weatherAlarmsPanelRectangle = componentUtils.getRectangleById('weather_alarms_panel')
    this.alignment = FlexAlign.Start
    this.marginTop = px2vp(weatherAlarmsPanelRectangle.windowOffset.y)
    this.contentOpacity = 0
    setTimeout(() => {
      DialogHelper.closeDialog('weather_alarms_detail_popup')
    }, 200)
  }

  build() {
    Column() {
      Stack() {
        Swiper() {
          ForEach(this.options.alarms, (item: WeatherAlarmsData, index: number) => {
            this.alarmItem(item, index)
          }, (item: WeatherAlarmsData) => item.short_title)
        }
        .width('100%')
        .height(this.animHeight)
        .animation({ duration: 200, curve: Curve.Linear })
        .loop(false)
        .indicator(
          (this.options.alarms?.length ?? 0) <= 1 ? false :
          Indicator.dot()
            .itemWidth(3)
            .itemHeight(2)
            .selectedItemWidth(6)
            .selectedItemHeight(2)
            .color(ColorUtils.alpha($r('app.color.special_white'), 0.5))
            .selectedColor($r('app.color.special_white'))
        )
        .onChange((index) => {
          this.animHeight = this.heights[index]
        })
      }
      .width(`calc(100% - ${2 * 16}vp)`)
      .opacity(this.contentOpacity)
      .margin({ top: this.marginTop })
      .animation({ curve: Curve.Ease, duration: 200 })
      .backgroundColor(ColorUtils.alpha(this.options.isDark ? $r('app.color.special_white') :
      $r('app.color.special_black'),
        this.options.panelOpacity))
      .borderRadius(Constants.ITEM_PANEL_RADIUS)
    }
    .width('100%')
    .height('100%')
    .justifyContent(this.alignment)
    .animation({ curve: Curve.Ease, duration: 200 })
    .onClick(() => {
      this.exit()
    })
  }

  @Builder
  alarmItem(item: WeatherAlarmsData, index: number) {
    Column() {
      Blank().height(12)
      Text(item.short_title)
        .fontSize(16)
        .fontColor($r('app.color.special_white'))
        .fontWeight(FontWeight.Bold)
      Blank().height(6)
      Text(this.pubTimeDesc(item))
        .fontSize(13)
        .fontColor($r('app.color.special_white'))
      Blank().height(8)
      Text(item.desc)
        .fontSize(14)
        .fontColor($r('app.color.special_white'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .onSizeChange((_, newValue) => {
          const height = newValue.height
          if (height) {
            const heightValue = height as number
            if (!this.heights[index]) {
              this.heights.splice(index, 0, heightValue + 53 + 42)
              if (this.animHeight == Constants.WEATHER_ALARM_PANEL_HEIGHT) {
                this.animHeight = this.heights[0]
              }
            }
          }
        })
      Blank().height(28)
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