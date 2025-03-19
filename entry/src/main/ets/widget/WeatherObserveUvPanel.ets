import { AppUtil, DateUtil, StrUtil } from "@pura/harmony-utils"
import { Constants } from "../constants/Constants"
import { WeatherItemData } from "../entity/WeatherItemData"
import { ColorUtils } from "../utils/ColorUtils"
import { buildPathCommands, fixPercent } from "../utils/CommonUtils"
import { PathShape, RectShape } from "@kit.ArkUI"
import { WeatherDetailData } from "../entity/WeatherData"
import { WeatherObserveUvChart } from "./WeatherObserveUvChart"

@ComponentV2
export struct WeatherObserveUvPanel {
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
        Text('紫外线指数')
          .fontSize(12)
          .fontColor(ColorUtils.alpha($r('app.color.special_white'), 0.6))
          .width('100%')
          .height(Constants.ITEM_STICKY_HEIGHT)
          .padding({ left: Constants.ITEM_PANEL_MARGIN })
          .translate({ y: this.stickyTranslateY })

        Row() {
          Text(this.uvLevel())
            .fontSize(18)
            .fontColor($r('app.color.special_white'))
            .fontWeight(FontWeight.Bold)
          WeatherObserveUvChart({
            panelWidth: 72,
            panelHeight: 72,
            uvIndex: this.uvIndex(),
            uvIndexMax: this.uvIndexMax()
          })
        }
        .width('100%')
        .height('100%')
        .padding({ left: 16, top: Constants.ITEM_STICKY_HEIGHT, right: 16 })
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
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

  uvIndex(): number {
    let uvIndex = this.weatherItemData?.weatherData?.observe?.uv_index ?? 0
    if (uvIndex <= 0) {
      uvIndex = this.currentWeatherDetailData()?.uv_index ?? 0
    }
    return uvIndex
  }

  uvIndexMax(): number {
    let uvIndexMax = this.weatherItemData?.weatherData?.observe?.uv_index_max ?? 0
    if (uvIndexMax <= 0) {
      uvIndexMax = this.currentWeatherDetailData()?.uv_index_max ?? 0
    }
    return uvIndexMax
  }

  uvLevel(): string {
    let uvLevel = this.weatherItemData?.weatherData?.observe?.uv_level ?? ''
    if (StrUtil.isEmpty(uvLevel)) {
      uvLevel = this.currentWeatherDetailData()?.uv_level ?? ''
    }
    return uvLevel
  }

  currentWeatherDetailData(): WeatherDetailData | undefined {
    return this.weatherItemData?.weatherData?.forecast15?.find(it => StrUtil.equal(it.date,
      DateUtil.getFormatDateStr(DateUtil.getToday(), Constants.YYYYMMDD)))
  }
}