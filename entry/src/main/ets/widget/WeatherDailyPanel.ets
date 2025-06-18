import { AppUtil, DateUtil, PreferencesUtil, StrUtil } from "@pura/harmony-utils"
import { Constants } from "../constants/Constants"
import { WeatherItemData } from "../entity/WeatherItemData"
import { ColorUtils } from "../utils/ColorUtils"
import {
  buildPathCommands,
  fixPercent,
  getAqiColor,
  getHarmonyDateTimeFormattedString,
  getTemp,
  getWeatherDateTime,
  isBefore
} from "../utils/CommonUtils"
import { PathShape } from "@kit.ArkUI"
import { WeatherDetailData } from "../entity/WeatherData"
import { WeatherIconUtils } from "../utils/WeatherIconUtils"
import { WeatherTempLineBar } from "./WeatherTempLineBar"
import { OpacityLayout } from "./OpacityLayout"
import { WeatherDailyTempPanel } from "./WeatherDailyTempPanel"

@ComponentV2
export struct WeatherDailyPanel {
  @Param weatherItemData?: WeatherItemData = undefined
  @Param isDark: boolean = false
  @Param panelOpacity: number = 0.1
  @Local contentOpacity: number = 1
  @Local stickyTranslateY: number = 0
  @Local panelPathCommands: string = ''
  @Local currentDailyWeatherType: string =
    PreferencesUtil.getStringSync(Constants.CURRENT_DAILY_WEATHER_TYPE, Constants.LIST_DAILY_WEATHER)
  @Local isExpand: boolean = false

  aboutToAppear(): void {
    this.panelPathCommands = buildPathCommands(this.panelHeight)
  }

  build() {
    ListItem() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          Divider()
            .strokeWidth(0.5)
            .color(ColorUtils.alpha($r('app.color.special_white'), 0.2))

          if (this.currentDailyWeatherType == Constants.LINE_CHART_DAILY_WEATHER) {
            // 曲线
            this.lineChartDailyWeather()
          } else if (this.currentDailyWeatherType == Constants.LIST_DAILY_WEATHER) {
            // 列表
            this.listDailyWeather()
          }
        }
        .padding({ top: Constants.ITEM_STICKY_HEIGHT })
        .clipShape(new PathShape({ commands: this.panelPathCommands }))

        Row() {
          Text('15日天气预报')
            .fontSize(12)
            .fontColor(ColorUtils.alpha($r('app.color.special_white'), 0.6))
            .height(Constants.ITEM_STICKY_HEIGHT)
            .padding({ left: Constants.ITEM_PANEL_MARGIN })

          Row() {
            OpacityLayout({
              child: () => {
                this.lineChartButton()
              },
              onTap: () => {
                this.changeLineChartDailyWeather()
              }
            })
            Divider()
              .vertical(true)
              .strokeWidth(0.5)
              .height(12)
              .color(ColorUtils.alpha($r('app.color.special_white'), 0.6))
            OpacityLayout({
              child: () => {
                this.listButton()
              },
              onTap: () => {
                this.changeListDailyWeather()
              }
            })
          }
        }
        .width('100%')
        .translate({ y: this.stickyTranslateY })
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .height(this.panelHeight)
      .backgroundColor(ColorUtils.alpha(this.isDark ? $r('app.color.special_white') : $r('app.color.special_black'),
        this.panelOpacity))
      .borderRadius(Constants.ITEM_PANEL_RADIUS)
      .opacity(this.contentOpacity)
      .animation({ curve: Curve.Ease, duration: 300 })
      .onAreaChange((_, newValue) => {
        const y = newValue.globalPosition.y
        if (y) {
          const panelHeight = this.panelHeight
          const yValue = y as number
          const offset = px2vp(AppUtil.getStatusBarHeight()) + Constants.WEATHER_HEADER_MIN_HEIGHT - yValue
          const percent = fixPercent((offset - (panelHeight - Constants.ITEM_STICKY_HEIGHT)) /
          Constants.ITEM_STICKY_HEIGHT)
          const stickyTranslateY =
            offset < 0 ? 0 : offset > panelHeight - Constants.ITEM_STICKY_HEIGHT ?
              panelHeight - Constants.ITEM_STICKY_HEIGHT : offset
          this.stickyTranslateY = stickyTranslateY + percent * Constants.ITEM_STICKY_HEIGHT * 0.5
          this.panelPathCommands =
            buildPathCommands(panelHeight, offset + Constants.ITEM_STICKY_HEIGHT)
          this.contentOpacity = 1 - percent
        }
      })
    }
  }

  get panelHeight() {
    if (this.currentDailyWeatherType == Constants.LINE_CHART_DAILY_WEATHER) {
      const find = this.weatherItemData?.weatherData?.forecast15?.find(it => StrUtil.isNotEmpty(it.aqi_level_name))
      return find != null ? 420 : 394
    }
    const value = this.isExpand ? Math.max(Constants.DAILY_WEATHER_ITEM_COUNT,
      this.weatherItemData?.weatherData?.forecast15?.length ?? Constants.DAILY_WEATHER_ITEM_COUNT) :
    Math.min(Constants.DAILY_WEATHER_ITEM_COUNT,
      this.weatherItemData?.weatherData?.forecast15?.length ?? Constants.DAILY_WEATHER_ITEM_COUNT)
    return Constants.ITEM_STICKY_HEIGHT + Constants.DAILY_WEATHER_ITEM_HEIGHT * value +
    Constants.DAILY_WEATHER_BOTTOM_HEIGHT
  }

  @Builder
  lineChartButton() {
    Text('曲线')
      .fontSize(11)
      .fontColor(ColorUtils.alpha($r('app.color.special_white'),
        this.currentDailyWeatherType == Constants.LINE_CHART_DAILY_WEATHER ? 1 : 0.6))
      .height(Constants.ITEM_STICKY_HEIGHT)
      .padding({ left: 12, right: 12 })
  }

  @Builder
  listButton() {
    Text('列表')
      .fontSize(11)
      .fontColor(ColorUtils.alpha($r('app.color.special_white'),
        this.currentDailyWeatherType == Constants.LIST_DAILY_WEATHER ? 1 : 0.6))
      .height(Constants.ITEM_STICKY_HEIGHT)
      .padding({ left: 12, right: 12 })
      .margin({ right: 4 })
  }

  @Builder
  expandLayout() {
    Row() {
      Text(this.isExpand ? '收起' : '展开')
        .fontSize(11)
        .fontColor(ColorUtils.alpha($r('app.color.special_white'), 0.6))
      Blank().width(8)
      Image($r('app.media.ic_expand_icon'))
        .width(10)
        .height(10)
        .colorFilter(ColorUtils.translateColor($r('app.color.special_white')))
        .opacity(0.6)
        .rotate({ angle: this.isExpand ? -180 : 0 })
        .animation({ curve: Curve.Ease, duration: 300 })
    }
    .width(88)
    .height(Constants.DAILY_WEATHER_BOTTOM_HEIGHT - 0.5)
    .justifyContent(FlexAlign.Center)
  }

  changeLineChartDailyWeather() {
    if (this.currentDailyWeatherType == Constants.LINE_CHART_DAILY_WEATHER) {
      return
    }
    PreferencesUtil.put(Constants.CURRENT_DAILY_WEATHER_TYPE, Constants.LINE_CHART_DAILY_WEATHER)
      .then(() => {
        this.currentDailyWeatherType = Constants.LINE_CHART_DAILY_WEATHER
      })
  }

  changeListDailyWeather() {
    if (this.currentDailyWeatherType == Constants.LIST_DAILY_WEATHER) {
      return
    }
    PreferencesUtil.put(Constants.CURRENT_DAILY_WEATHER_TYPE, Constants.LIST_DAILY_WEATHER)
      .then(() => {
        this.currentDailyWeatherType = Constants.LIST_DAILY_WEATHER
      })
  }

  lookMore() {
    this.isExpand = !this.isExpand
  }

  @Builder
  lineChartDailyWeather() {
    Column() {
      List() {
        ForEach(this.weatherItemData?.weatherData?.forecast15, (item: WeatherDetailData, index: number) => {
          this.lineChartDailyWeatherItem(item, index)
        }, (item: WeatherDetailData) => item.date)
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .listDirection(Axis.Horizontal)
    }
    .width('100%')
    .layoutWeight(1)
    .transition(TransitionEffect.opacity(0).animation({ curve: Curve.Ease, duration: 300 }))
  }

  @Builder
  listDailyWeather() {
    Column() {
      List() {
        ForEach(this.weatherItemData?.weatherData?.forecast15, (item: WeatherDetailData) => {
          this.listDailyWeatherItem(item)
        }, (item: WeatherDetailData) => item.date)
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .enableScrollInteraction(false)

      OpacityLayout({
        child: () => {
          this.expandLayout()
        },
        onTap: () => {
          this.lookMore()
        }
      })
    }
    .width('100%')
    .layoutWeight(1)
    .transition(TransitionEffect.opacity(0).animation({ curve: Curve.Ease, duration: 400 }))
  }

  @Builder
  listDailyWeatherItem(item: WeatherDetailData) {
    ListItem() {
      Column() {
        Row() {
          Column() {
            Text(this.weatherDateTime(item))
              .fontSize(17)
              .fontColor($r('app.color.special_white'))
              .fontWeight(FontWeight.Medium)
            Blank().height(2)
            Text(this.weatherDate(item))
              .fontSize(12)
              .fontColor($r('app.color.special_white'))
          }

          Blank().width(38)
          Image(WeatherIconUtils.getWeatherIconByType(item.day?.type ?? -1, item?.day?.third_type ?? '', false))
            .width(24)
            .height(24)
            .draggable(false)
          Blank().width(38)
          Text(getTemp(item?.low))
            .fontSize(18)
            .fontColor(ColorUtils.alpha($r('app.color.special_white'), this.isBefore(item) ? 1 : 0.5))
            .width(42)
            .textAlign(TextAlign.Start)
          WeatherTempLineBar({
            barWidth: '100%',
            barHeight: 4,
            temp: this.isToday(item) ? this.weatherItemData?.weatherData?.observe?.temp : undefined,
            high: item?.high,
            low: item?.low,
            maxTemp: this.maxTempData()?.high,
            minTemp: this.minTempData()?.low
          })
            .layoutWeight(1)
          Blank().width(16)
          Text(getTemp(item?.high))
            .fontSize(18)
            .fontColor($r('app.color.special_white'))
        }
        .width('100%')
        .layoutWeight(1)
        .opacity(this.isBefore(item) ? 0.5 : 1)

        Divider()
          .strokeWidth(0.5)
          .color(ColorUtils.alpha($r('app.color.special_white'), 0.2))
      }
      .width('100%')
      .height(Constants.DAILY_WEATHER_ITEM_HEIGHT)
      .padding({ left: 16, right: 16 })
    }
  }

  @Builder
  lineChartDailyWeatherItem(item: WeatherDetailData, index: number) {
    Column() {
      Blank().height(12)
      Text(this.weatherDateTime(item))
        .fontSize(14)
        .fontColor(ColorUtils.alpha($r('app.color.special_white'), this.isBefore(item) ? 0.5 : 1))
        .fontWeight(FontWeight.Medium)
      Blank().height(12)
      Text(this.weatherDate(item))
        .fontSize(12)
        .fontColor(ColorUtils.alpha($r('app.color.special_white'), this.isBefore(item) ? 0.5 : 1))
      Blank().height(12)
      Text(item.day?.wthr)
        .fontSize(14)
        .fontColor(ColorUtils.alpha($r('app.color.special_white'), this.isBefore(item) ? 0.5 : 1))
      Blank().height(12)
      Image(WeatherIconUtils.getWeatherIconByType(item.day?.type ?? -1, item.day?.third_type ?? '', false))
        .width(24)
        .height(24)
        .draggable(false)
        .opacity(this.isBefore(item) ? 0.5 : 1)
      WeatherDailyTempPanel({
        panelWidth: 68.5,
        panelHeight: 128,
        preData: this.weatherItemData?.weatherData?.forecast15?.[index - 1],
        data: item,
        nextData: this.weatherItemData?.weatherData?.forecast15?.[index + 1],
        maxTemp: this.maxTempData()?.high,
        minTemp: this.minTempData()?.low
      })
      Image(WeatherIconUtils.getWeatherIconByType(item.night?.type ?? -1, item.night?.third_type ?? '', false))
        .width(24)
        .height(24)
        .draggable(false)
        .opacity(this.isBefore(item) ? 0.5 : 1)
      Blank().height(12)
      Text(item.night?.wthr)
        .fontSize(14)
        .fontColor(ColorUtils.alpha($r('app.color.special_white'), this.isBefore(item) ? 0.5 : 1))
      Blank().height(12)
      Text(item.wd)
        .fontSize(14)
        .fontColor(ColorUtils.alpha($r('app.color.special_white'), this.isBefore(item) ? 0.5 : 1))
      Blank().height(12)
      Text(item.wp)
        .fontSize(14)
        .fontColor(ColorUtils.alpha($r('app.color.special_white'), this.isBefore(item) ? 0.5 : 1))
      if (StrUtil.isNotEmpty(item.aqi_level_name)) {
        Blank().height(8)
        Text(item.aqi_level_name)
          .fontSize(11)
          .fontColor($r('app.color.special_white'))
          .padding({
            left: 8,
            top: 2,
            right: 8,
            bottom: 2
          })
          .borderRadius(8)
          .backgroundColor(ColorUtils.alpha(getAqiColor(item.aqi), 0.48))
      }
    }
    .width(68.5)
  }

  isToday(item: WeatherDetailData): boolean {
    const date = item?.date ?? ""
    return DateUtil.isToday(getHarmonyDateTimeFormattedString(date))
  }

  isBefore(item: WeatherDetailData): boolean {
    const date = item?.date ?? ""
    return isBefore(date)
  }

  weatherDateTime(item: WeatherDetailData): string {
    const date = item?.date ?? ""
    return getWeatherDateTime(date)
  }

  weatherDate(item: WeatherDetailData): string {
    const date = item?.date ?? ""
    return DateUtil.getFormatDateStr(getHarmonyDateTimeFormattedString(date), 'MM/dd')
  }

  maxTempData(): WeatherDetailData | undefined {
    return this.weatherItemData?.weatherData?.forecast15?.reduce((e1, e2) => (e1.high ?? 0) > (e2.high ?? 0) ? e1 : e2)
  }

  minTempData(): WeatherDetailData | undefined {
    return this.weatherItemData?.weatherData?.forecast15?.reduce((e1, e2) => (e1.low ?? 0) < (e2.low ?? 0) ? e1 : e2)
  }
}