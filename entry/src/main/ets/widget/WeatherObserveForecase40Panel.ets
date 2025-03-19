import { AppUtil } from "@pura/harmony-utils"
import { Constants } from "../constants/Constants"
import { WeatherItemData } from "../entity/WeatherItemData"
import { ColorUtils } from "../utils/ColorUtils"
import { buildPathCommands, fixPercent } from "../utils/CommonUtils"
import { PathShape } from "@kit.ArkUI"

@ComponentV2
export struct WeatherObserveForecase40Panel {
  @Param weatherItemData?: WeatherItemData = undefined
  @Param isDark: boolean = false
  @Param panelOpacity: number = 0.1
  @Local contentOpacity: number = 1
  @Local stickyTranslateY: number = 0
  @Local panelPathCommands: string = ''

  aboutToAppear(): void {
    this.panelPathCommands = buildPathCommands(Constants.ITEM_OBSERVE_PANEL_HEIGHT)
  }

  build() {
    GridItem() {
      Stack({ alignContent: Alignment.TopStart }) {
        Text('未来40日天气')
          .fontSize(12)
          .fontColor(ColorUtils.alpha($r('app.color.special_white'), 0.6))
          .width('100%')
          .height(Constants.ITEM_STICKY_HEIGHT)
          .padding({ left: Constants.ITEM_PANEL_MARGIN })
          .translate({ y: this.stickyTranslateY })

        Column() {
          Text('温度趋势')
            .fontSize(12)
            .fontColor(ColorUtils.alpha($r('app.color.special_white'), 0.6))
          Blank().height(5)
          Text(this.upDaysDesc)
            .fontSize(14)
            .fontColor($r('app.color.special_white'))
          Blank().height(16)
          Text('降水趋势')
            .fontSize(12)
            .fontColor(ColorUtils.alpha($r('app.color.special_white'), 0.6))
          Blank().height(5)
          Text(this.rainDaysDesc)
            .fontSize(14)
            .fontColor($r('app.color.special_white'))
        }
        .width('100%')
        .padding({ left: 16, top: Constants.ITEM_STICKY_HEIGHT, right: 16 })
        .alignItems(HorizontalAlign.Start)
        .clipShape(new PathShape({ commands: this.panelPathCommands }))
      }
      .width('100%')
      .height(Constants.ITEM_OBSERVE_PANEL_HEIGHT)
      .backgroundColor(ColorUtils.alpha(this.isDark ? $r('app.color.special_white') : $r('app.color.special_black'),
        this.panelOpacity))
      .borderRadius(Constants.ITEM_PANEL_RADIUS)
      .opacity(this.contentOpacity)
      .onAreaChange((_, newValue) => {
        const y = newValue.globalPosition.y
        if (y) {
          const yValue = y as number
          const offset = px2vp(AppUtil.getStatusBarHeight()) + Constants.WEATHER_HEADER_MIN_HEIGHT - yValue
          const percent = fixPercent((offset - (Constants.ITEM_OBSERVE_PANEL_HEIGHT - Constants.ITEM_STICKY_HEIGHT)) /
          Constants.ITEM_STICKY_HEIGHT)
          const stickyTranslateY =
            offset < 0 ? 0 : offset > Constants.ITEM_OBSERVE_PANEL_HEIGHT - Constants.ITEM_STICKY_HEIGHT ?
              Constants.ITEM_OBSERVE_PANEL_HEIGHT - Constants.ITEM_STICKY_HEIGHT : offset
          this.stickyTranslateY = stickyTranslateY + percent * Constants.ITEM_STICKY_HEIGHT * 0.5
          this.panelPathCommands =
            buildPathCommands(Constants.ITEM_OBSERVE_PANEL_HEIGHT, offset + Constants.ITEM_STICKY_HEIGHT)
          this.contentOpacity = 1 - percent
        }
      })
    }
  }

  get upDaysDesc() {
    const upDays = this.weatherItemData?.weatherData?.forecast40_v2?.up_days ?? 0
    return upDays > 0 ? `${upDays}天升温` : '预计近期气温平稳'
  }

  get rainDaysDesc() {
    const rainDays = this.weatherItemData?.weatherData?.forecast40_v2?.rain_days ?? 0
    return rainDays > 0 ? `${rainDays}天有雨` : '预计近期无降雨'
  }
}