import { AirQualityDetailPopupOptions } from "./AirQualityDetailPopupOptions"
import { componentUtils } from "@kit.ArkUI"
import { OpacityLayout } from "../widget/OpacityLayout"
import { ColorUtils } from "../utils/ColorUtils"
import { Constants } from "../constants/Constants"
import { AirQualityBar } from "../widget/AirQualityBar"
import { DialogHelper } from "@pura/harmony-dialog"
import { AirQualityQueryDialogBuilder } from "./AirQualityQueryDialog"
import { StrUtil } from "@pura/harmony-utils"

@Builder
export function AirQualityDetailPopupBuilder(options: AirQualityDetailPopupOptions) {
  AirQualityDetailPopup({ options: options })
}

@ComponentV2
export struct AirQualityDetailPopup {
  @Require @Param options: AirQualityDetailPopupOptions
  @Local panelOpacity: number = 0
  @Local contentOpacity: number = 0
  @Local marginTop: number = 0
  @Local alignment: FlexAlign = FlexAlign.Start

  aboutToAppear(): void {
    this.options.ref.exit = this.exit
    const airQualityPanelRectangle = componentUtils.getRectangleById('weather_air_quality_panel')
    this.marginTop = px2vp(airQualityPanelRectangle.windowOffset.y)
    setTimeout(() => {
      this.panelOpacity = 1
      this.marginTop = 0
      this.alignment = FlexAlign.Center
      setTimeout(() => {
        this.contentOpacity = 1
      }, 200)
    }, 16)
  }

  exit = () => {
    const airQualityPanelRectangle = componentUtils.getRectangleById('weather_air_quality_panel')
    this.alignment = FlexAlign.Start
    this.marginTop = px2vp(airQualityPanelRectangle.windowOffset.y)
    this.contentOpacity = 0
    setTimeout(() => {
      this.panelOpacity = 0
      setTimeout(() => {
        DialogHelper.closeDialog('air_quality_detail_popup')
      }, 200)
    }, 200)
  }

  build() {
    Column() {
      Column() {
        this.airQualityPanel()
        Blank().height(12)
        Grid() {
          this.airQualityItem('PM2.5', this.options.evn?.pm25 ?? 0)
          this.airQualityItem('PM10', this.options.evn?.pm10 ?? 0)
          this.airQualityItem('NO', this.options.evn?.no2 ?? 0, '2')
          this.airQualityItem('SO', this.options.evn?.so2 ?? 0, '2')
          this.airQualityItem('O', this.options.evn?.o3 ?? 0, '3')
          this.airQualityItem('CO', this.options.evn?.co ?? 0)
        }
        .width('100%')
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .maxCount(3)
        .layoutDirection(GridDirection.Row)
        .opacity(this.contentOpacity)
        .animation({ curve: Curve.Ease, duration: 200 })
      }
      .width(`calc(100% - ${2 * 16}vp)`)
      .opacity(this.panelOpacity)
      .margin({ top: this.marginTop })
      .animation({ curve: Curve.Ease, duration: 200 })
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
  airQualityPanel() {
    Column() {
      Blank().height(12)
      Row() {
        Text(this.title)
          .fontSize(16)
          .fontColor($r('app.color.special_white'))
          .fontWeight(FontWeight.Bold)
        OpacityLayout({
          child: () => {
            this.queryIcon()
          },
          onTap: () => {
            DialogHelper.showBindSheet(wrapBuilder(AirQualityQueryDialogBuilder), {
              dialogId: 'air_quality_query_dialog',
            })
          }
        })
      }

      Blank().height(12)
      AirQualityBar({ barWidth: '100%', barHeight: 4, aqi: this.options.evn?.aqi ?? 0 })
      Blank().height(10)
      Text(this.desc)
        .fontSize(13)
        .fontColor($r('app.color.special_white'))
    }
    .width('100%')
    .height(Constants.WEATHER_AIR_QUALITY_PANEL_HEIGHT)
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16 })
    .backgroundColor(ColorUtils.alpha(this.options.isDark ? $r('app.color.special_white') :
    $r('app.color.special_black'),
      this.options.panelOpacity))
    .borderRadius(Constants.ITEM_PANEL_RADIUS)
  }

  @Builder
  airQualityItem(title: string, value: number, subscript?: string) {
    GridItem() {
      Column() {
        Row() {
          Text(title)
            .fontSize(16)
            .fontColor($r('app.color.special_white'))
            .fontWeight(FontWeight.Bold)
          Text(subscript ?? '')
            .fontSize(10)
            .fontColor($r('app.color.special_white'))
            .fontWeight(FontWeight.Bold)
            .visibility(StrUtil.isEmpty(subscript) ? Visibility.Hidden : Visibility.Visible)
          Blank().width(2)
          Text('ug/m³')
            .fontSize(12)
            .fontColor(ColorUtils.alpha($r('app.color.special_white'), 0.6))
        }

        Blank().height(12)
        Text(value.toFixed(1))
          .fontSize(18)
          .fontColor($r('app.color.special_white'))
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height(72)
      .padding({ left: 12, right: 12 })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(ColorUtils.alpha(this.options.isDark ? $r('app.color.special_white') :
      $r('app.color.special_black'),
        this.options.panelOpacity))
      .borderRadius(Constants.ITEM_PANEL_RADIUS)
    }
  }

  @Builder
  queryIcon() {
    Stack() {
      Image($r('app.media.ic_query_icon'))
        .width(14)
        .height(14)
        .draggable(false)
        .colorFilter(ColorUtils.translateColor($r('app.color.special_white')))
    }
    .padding({
      left: 12,
      top: 4,
      right: 12,
      bottom: 4
    })
  }

  get title() {
    return `${this.options.evn?.aqi} - ${this.options.evn?.aqi_level_name}`
  }

  get desc() {
    return `当前AQI为${this.options.evn?.aqi}`
  }
}