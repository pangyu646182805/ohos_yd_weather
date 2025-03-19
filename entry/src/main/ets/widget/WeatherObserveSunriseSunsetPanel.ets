import { AppUtil, DateUtil, StrUtil } from "@pura/harmony-utils"
import { Constants } from "../constants/Constants"
import { WeatherItemData } from "../entity/WeatherItemData"
import { ColorUtils } from "../utils/ColorUtils"
import { buildPathCommands, fixPercent, getHarmonyDateTimeFormattedString } from "../utils/CommonUtils"
import { PathShape } from "@kit.ArkUI"
import { WeatherDetailData } from "../entity/WeatherData"
import { WeatherObserveSunriseSunsetChart } from "./WeatherObserveSunriseSunsetChart"

@ComponentV2
export struct WeatherObserveSunriseSunsetPanel {
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
        Text('日出日落')
          .fontSize(12)
          .fontColor(ColorUtils.alpha($r('app.color.special_white'), 0.6))
          .width('100%')
          .height(Constants.ITEM_STICKY_HEIGHT)
          .padding({ left: Constants.ITEM_PANEL_MARGIN })
          .translate({ y: this.stickyTranslateY })

        Row() {
          Column() {
            Text(this.sunriseSunsetDesc)
              .fontSize(14)
              .fontColor($r('app.color.special_white'))
            Blank().height(8)
            Text(this.sunriseSunset)
              .fontSize(18)
              .fontColor($r('app.color.special_white'))
              .fontWeight(FontWeight.Bold)
          }
          .alignItems(HorizontalAlign.Start)

          Column() {
            WeatherObserveSunriseSunsetChart({
              panelWidth: 72,
              panelHeight: 42,
              date: this.currentWeatherDetailData?.date,
              sunrise: this.currentWeatherDetailData?.sunrise,
              sunset: this.currentWeatherDetailData?.sunset
            })
            Blank().height(4)
            Row() {
              Text(this.currentWeatherDetailData?.sunrise)
                .fontSize(10)
                .fontColor($r('app.color.special_white'))
              Text(this.currentWeatherDetailData?.sunset)
                .fontSize(10)
                .fontColor($r('app.color.special_white'))
            }
            .width(72)
            .justifyContent(FlexAlign.SpaceBetween)
          }
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

  get sunriseSunsetDesc() {
    const currentMill = DateUtil.getToday().getTime()
    const currentWeatherDetailData = this.currentWeatherDetailData
    const sunriseSunsetMill = this.sunriseSunsetMill(currentWeatherDetailData)
    const sunriseMill = sunriseSunsetMill[0]
    const sunsetMill = sunriseSunsetMill[1]
    if (currentMill < sunriseMill || currentMill > sunsetMill) {
      return '日出'
    } else {
      return '日落'
    }
  }

  sunriseSunsetMill(currentWeatherDetailData: WeatherDetailData | undefined) {
    const sunriseDateTime =
      getHarmonyDateTimeFormattedString(`${currentWeatherDetailData?.date}${currentWeatherDetailData?.sunrise}`.replaceAll(':',
        ''))
    const sunsetDateTime =
      getHarmonyDateTimeFormattedString(`${currentWeatherDetailData?.date}${currentWeatherDetailData?.sunset}`.replaceAll(':',
        ''))
    const sunriseMill = DateUtil.getFormatDate(sunriseDateTime).getTime()
    const sunsetMill = DateUtil.getFormatDate(sunsetDateTime).getTime()
    return [sunriseMill, sunsetMill]
  }

  get sunriseSunset() {
    const currentMill = DateUtil.getToday().getTime()
    const currentWeatherDetailData = this.currentWeatherDetailData
    const sunriseSunsetMill = this.sunriseSunsetMill(currentWeatherDetailData)
    const sunriseMill = sunriseSunsetMill[0]
    const sunsetMill = sunriseSunsetMill[1]
    if (currentMill < sunriseMill || currentMill > sunsetMill) {
      return currentWeatherDetailData?.sunrise ?? ''
    } else {
      return currentWeatherDetailData?.sunset ?? ''
    }
  }

  @Computed
  get currentWeatherDetailData() {
    return this.weatherItemData?.weatherData?.forecast15?.find(it => StrUtil.equal(it.date,
      DateUtil.getFormatDateStr(DateUtil.getToday(), Constants.YYYYMMDD)))
  }
}