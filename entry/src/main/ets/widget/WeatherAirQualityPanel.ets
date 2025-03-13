import { AppUtil } from "@pura/harmony-utils"
import { Constants } from "../constants/Constants"
import { WeatherItemData } from "../entity/WeatherItemData"
import { ColorUtils } from "../utils/ColorUtils"
import { buildPathCommands, fixPercent } from "../utils/CommonUtils"
import { AirQualityBar } from "./AirQualityBar"
import { PathShape } from "@kit.ArkUI"

@ComponentV2
export struct WeatherAirQualityPanel {
  @Param weatherItemData?: WeatherItemData = undefined
  @Param isDark: boolean = false
  @Param panelOpacity: number = 0.1
  @Local stickyTranslateY: number = 0
  @Local contentOpacity: number = 1
  @Local titleOpacity: number = 1
  @Local panelPathCommands: string = ''

  aboutToAppear(): void {
    this.panelPathCommands = buildPathCommands(Constants.WEATHER_AIR_QUALITY_PANEL_HEIGHT)
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
          .opacity(1 - this.titleOpacity)
          .translate({ y: this.stickyTranslateY })

        Column() {
          Blank().height(12)
          Row() {
            Text(this.title)
              .fontSize(16)
              .fontColor($r('app.color.special_white'))
              .fontWeight(FontWeight.Bold)
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
            .onClick(() => {

            })
          }
          .opacity(this.titleOpacity)

          Blank().height(12)
          AirQualityBar({ barWidth: '100%', barHeight: 4, aqi: this.weatherItemData?.weatherData?.evn?.aqi ?? 0 })
          Blank().height(10)
          Text(this.desc)
            .fontSize(13)
            .fontColor($r('app.color.special_white'))
        }
        .width('100%')
        .height(Constants.WEATHER_AIR_QUALITY_PANEL_HEIGHT)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 16, right: 16 })
        .clipShape(new PathShape({ commands: this.panelPathCommands }))
      }
      .width('100%')
      .height(Constants.WEATHER_AIR_QUALITY_PANEL_HEIGHT)
      .backgroundColor(ColorUtils.alpha(this.isDark ? $r('app.color.special_white') : $r('app.color.special_black'),
        this.panelOpacity))
      .borderRadius(Constants.ITEM_PANEL_RADIUS)
      .opacity(this.contentOpacity)
      .onAreaChange((_, newValue) => {
        const y = newValue.globalPosition.y
        if (y) {
          const yValue = y as number
          const offset = px2vp(AppUtil.getStatusBarHeight()) + Constants.WEATHER_HEADER_MIN_HEIGHT - yValue
          const percent =
            fixPercent((offset - (Constants.WEATHER_AIR_QUALITY_PANEL_HEIGHT - Constants.ITEM_STICKY_HEIGHT)) /
            Constants.ITEM_STICKY_HEIGHT)
          const stickyTranslateY =
            offset < 0 ? 0 : offset > Constants.WEATHER_AIR_QUALITY_PANEL_HEIGHT - Constants.ITEM_STICKY_HEIGHT ?
              Constants.WEATHER_AIR_QUALITY_PANEL_HEIGHT - Constants.ITEM_STICKY_HEIGHT : offset
          this.stickyTranslateY = stickyTranslateY + percent * Constants.ITEM_STICKY_HEIGHT * 0.5
          this.titleOpacity = fixPercent(1 - offset / 12)
          this.panelPathCommands = buildPathCommands(Constants.WEATHER_AIR_QUALITY_PANEL_HEIGHT,
            offset + Constants.ITEM_STICKY_HEIGHT * fixPercent(offset / Constants.ITEM_STICKY_HEIGHT))
          // console.log('yValue = ' + offset + ' percent = ' + percent)
          this.contentOpacity = 1 - percent
        }
      })
    }
  }

  get title() {
    return `${this.weatherItemData?.weatherData?.evn?.aqi} - ${this.weatherItemData?.weatherData?.evn?.aqi_level_name}`
  }

  get desc() {
    return `当前AQI为${this.weatherItemData?.weatherData?.evn?.aqi}`
  }
}