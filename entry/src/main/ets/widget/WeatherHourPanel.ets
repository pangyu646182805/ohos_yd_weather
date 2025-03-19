import { AppUtil, DateUtil, StrUtil } from "@pura/harmony-utils"
import { Constants } from "../constants/Constants"
import { WeatherItemData } from "../entity/WeatherItemData"
import { ColorUtils } from "../utils/ColorUtils"
import {
  buildPathCommands,
  fixPercent,
  getHarmonyDateTimeFormattedString,
  getTemp,
  getWeatherHourTime,
  isNight
} from "../utils/CommonUtils"
import { PathShape } from "@kit.ArkUI"
import { WeatherHourData } from "../entity/WeatherData"
import { WeatherIconUtils } from "../utils/WeatherIconUtils"

@ComponentV2
export struct WeatherHourPanel {
  @Param weatherItemData?: WeatherItemData = undefined
  @Param isDark: boolean = false
  @Param panelOpacity: number = 0.1
  @Local contentOpacity: number = 1
  @Local stickyTranslateY: number = 0
  @Local panelPathCommands: string = ''

  aboutToAppear(): void {
    this.panelPathCommands = buildPathCommands(Constants.WEATHER_HOUR_PANEL_HEIGHT)
  }

  build() {
    ListItem() {
      Stack({ alignContent: Alignment.TopStart }) {
        Text('每小时天气预报')
          .fontSize(12)
          .fontColor(ColorUtils.alpha($r('app.color.special_white'), 0.6))
          .width('100%')
          .height(Constants.ITEM_STICKY_HEIGHT)
          .padding({ left: Constants.ITEM_PANEL_MARGIN })
          .translate({ y: this.stickyTranslateY })

        Column() {
          Divider()
            .strokeWidth(0.5)
            .color(ColorUtils.alpha($r('app.color.special_white'), 0.2))

          List() {
            ForEach(this.weatherItemData?.weatherData?.hourfc, (item: WeatherHourData) => {
              this.hourItem(item)
            }, (item: WeatherHourData) => item.time)
          }
          .width('100%')
          .height('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.None)
          .listDirection(Axis.Horizontal)
          .contentStartOffset(16)
          .contentEndOffset(16)
          .divider({ strokeWidth: 28, color: $r('app.color.transparent') })
        }
        .padding({ top: Constants.ITEM_STICKY_HEIGHT })
        .clipShape(new PathShape({ commands: this.panelPathCommands }))
      }
      .width('100%')
      .height(Constants.WEATHER_HOUR_PANEL_HEIGHT)
      .backgroundColor(ColorUtils.alpha(this.isDark ? $r('app.color.special_white') : $r('app.color.special_black'),
        this.panelOpacity))
      .borderRadius(Constants.ITEM_PANEL_RADIUS)
      .opacity(this.contentOpacity)
      .onAreaChange((_, newValue) => {
        const y = newValue.globalPosition.y
        if (y) {
          const yValue = y as number
          const offset = px2vp(AppUtil.getStatusBarHeight()) + Constants.WEATHER_HEADER_MIN_HEIGHT - yValue
          const percent = fixPercent((offset - (Constants.WEATHER_HOUR_PANEL_HEIGHT - Constants.ITEM_STICKY_HEIGHT)) /
          Constants.ITEM_STICKY_HEIGHT)
          const stickyTranslateY =
            offset < 0 ? 0 : offset > Constants.WEATHER_HOUR_PANEL_HEIGHT - Constants.ITEM_STICKY_HEIGHT ?
              Constants.WEATHER_HOUR_PANEL_HEIGHT - Constants.ITEM_STICKY_HEIGHT : offset
          this.stickyTranslateY = stickyTranslateY + percent * Constants.ITEM_STICKY_HEIGHT * 0.5
          this.panelPathCommands =
            buildPathCommands(Constants.WEATHER_HOUR_PANEL_HEIGHT, offset + Constants.ITEM_STICKY_HEIGHT)
          this.contentOpacity = 1 - percent
        }
      })
    }
  }

  @Builder
  hourItem(item: WeatherHourData) {
    ListItem() {
      Column() {
        Blank().height(12)
        Text(this.isSunrise(item) ? item.sunriseAndSunset?.sunrise :
          this.isSunset(item) ? item.sunriseAndSunset?.sunset :
          getWeatherHourTime(item?.time, this.currentWeatherDetailData?.sunrise, this.currentWeatherDetailData?.sunset))
          .fontSize(14)
          .fontColor($r('app.color.special_white'))
        Blank().height(12)
        Image(this.isSunrise(item) ? $r('app.media.ic_sunrise_icon') :
          this.isSunset(item) ? $r('app.media.ic_sunset_icon') :
          WeatherIconUtils.getWeatherIconByType(item.type ?? -1, item.third_type ?? '',
            isNight(DateUtil.getFormatDate(getHarmonyDateTimeFormattedString(item?.time)),
              this.currentWeatherDetailData?.sunrise, this.currentWeatherDetailData?.sunset)))
          .width(24)
          .height(24)
          .draggable(false)
        Blank().height(12)
        Text(this.isSunrise(item) ? '日出' : this.isSunset(item) ? '日落' : getTemp(item.wthr))
          .fontSize(14)
          .fontColor($r('app.color.special_white'))
      }
    }
  }

  get currentWeatherDetailData() {
    return this.weatherItemData?.weatherData?.forecast15?.find(it => StrUtil.equal(it.date,
      DateUtil.getFormatDateStr(DateUtil.getToday(), Constants.YYYYMMDD)))
  }

  isSunrise(item: WeatherHourData): boolean {
    const sunriseAndSunset = item.sunriseAndSunset
    if (sunriseAndSunset) {
      return StrUtil.isNotEmpty(sunriseAndSunset.sunrise)
    }
    return false
  }

  isSunset(item: WeatherHourData): boolean {
    const sunriseAndSunset = item.sunriseAndSunset
    if (sunriseAndSunset) {
      return StrUtil.isNotEmpty(sunriseAndSunset.sunset)
    }
    return false
  }
}