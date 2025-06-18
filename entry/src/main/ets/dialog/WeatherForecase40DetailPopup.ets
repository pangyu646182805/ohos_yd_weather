import { WeatherForecase40DetailPopupOptions } from "./WeatherForecase40DetailPopupOptions"
import { componentUtils } from "@kit.ArkUI"
import { AppUtil, ArrayUtil, DateUtil, DisplayUtil, ObjectUtil, StrUtil } from "@pura/harmony-utils"
import { OpacityLayout } from "../widget/OpacityLayout"
import { ColorUtils } from "../utils/ColorUtils"
import { DialogHelper } from "@pura/harmony-dialog"
import { WeatherDetailData } from "../entity/WeatherData"
import { getAqiColor, getHarmonyDateTimeFormattedString } from "../utils/CommonUtils"
import { Constants } from "../constants/Constants"
import { WeatherIconUtils } from "../utils/WeatherIconUtils"
import { WeatherForecase40Chart, WeatherForecase40ChartController } from "../widget/WeatherForecase40Chart"

@Builder
export function WeatherForecase40DetailPopupBuilder(options: WeatherForecase40DetailPopupOptions) {
  WeatherForecase40DetailPopup({ options: options })
}

@ComponentV2
export struct WeatherForecase40DetailPopup {
  @Require @Param options: WeatherForecase40DetailPopupOptions
  @Local contentOpacity: number = 0
  @Local titleBarOpacity: number = 0
  @Local calendarPanelWidth: number = 0
  @Local calendarPanelHeight: number = 0
  @Local marginTop: number = 0
  @Local pageData: Array<Array<WeatherDetailData>> = []
  @Local currentSelectedItem: WeatherDetailData | undefined = undefined
  private itemAlign: ItemAlign = ItemAlign.End
  private swiperController = new SwiperController()
  private chartController = new WeatherForecase40ChartController()

  aboutToAppear(): void {
    this.generatePageData()
    this.options.ref.exit = this.exit
    const weatherObserveForecase40PanelRectangle = componentUtils.getRectangleById('weather_observe_forecase40_panel')
    this.calendarPanelWidth = px2vp(weatherObserveForecase40PanelRectangle.size.width)
    this.calendarPanelHeight = px2vp(weatherObserveForecase40PanelRectangle.size.height)
    this.marginTop =
      px2vp(weatherObserveForecase40PanelRectangle.windowOffset.y) - 48 - 12 - px2vp(AppUtil.getStatusBarHeight())
    this.itemAlign =
      weatherObserveForecase40PanelRectangle.windowOffset.x < DisplayUtil.getWidth() / 2 ? ItemAlign.Start :
      ItemAlign.End
    setTimeout(() => {
      this.calendarPanelWidth = px2vp(DisplayUtil.getWidth()) - 2 * 16
      this.calendarPanelHeight = 488
      this.marginTop = 0
      this.contentOpacity = 1
      setTimeout(() => {
        this.titleBarOpacity = 1
      }, 200)
    }, 16)
  }

  generatePageData() {
    this.pageData.splice(0, this.pageData.length)
    const temp = [...this.options.forecast40]
    const firstDateTime = DateUtil.getFormatDate(getHarmonyDateTimeFormattedString(temp[0].date))
    const lastDateTime = DateUtil.getFormatDate(getHarmonyDateTimeFormattedString(temp[temp.length - 1].date))
    const firstWeekday = firstDateTime.getDay()
    const fixedFirstWeekday = firstWeekday >= 7 ? 0 : firstWeekday
    let index = 1
    let list: Array<WeatherDetailData>
    for (let i = 0; i < 2; i++) {
      list = []
      for (let j = 0; j < 28; j++) {
        if (i == 0) {
          if (j < fixedFirstWeekday) {
            list.push({
              date: DateUtil.getAmountDayStr(firstDateTime, -(fixedFirstWeekday - j), Constants.YYYYMMDD)
            } as WeatherDetailData)
          } else {
            const removeItem = temp.splice(0, 1)[0]
            if (!this.currentSelectedItem) {
              const date = DateUtil.getFormatDate(getHarmonyDateTimeFormattedString(removeItem.date))
              if (DateUtil.isToday(date)) {
                this.currentSelectedItem = removeItem
              }
            }
            list.push(removeItem)
          }
        } else {
          if (ArrayUtil.isNotEmpty(temp)) {
            list.push(temp.splice(0, 1)[0])
          } else {
            list.push({
              date: DateUtil.getAmountDayStr(lastDateTime, index, Constants.YYYYMMDD)
            } as WeatherDetailData)
            index++
          }
        }
      }
      this.pageData.push(list)
    }
  }

  exit = () => {
    this.titleBarOpacity = 0
    setTimeout(() => {
      const weatherObserveForecase40PanelRectangle = componentUtils.getRectangleById('weather_observe_forecase40_panel')
      this.calendarPanelWidth = px2vp(weatherObserveForecase40PanelRectangle.size.width)
      this.calendarPanelHeight = px2vp(weatherObserveForecase40PanelRectangle.size.height)
      this.marginTop =
        px2vp(weatherObserveForecase40PanelRectangle.windowOffset.y) - 48 - 12 - px2vp(AppUtil.getStatusBarHeight())
      this.contentOpacity = 0
      setTimeout(() => {
        DialogHelper.closeDialog('weather_forecase40_detail_popup')
      }, 200)
    }, 200)
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Start }) {
        Text(this.options.meta?.city)
          .width('100%')
          .height(48)
          .textAlign(TextAlign.Center)
          .fontSize(20)
          .fontColor(this.options.isWeatherHeaderDark ? $r('app.color.special_white') : $r('app.color.special_black'))
          .fontWeight(FontWeight.Bold)

        OpacityLayout({
          child: () => {
            this.closeIcon()
          },
          onTap: () => {
            this.exit()
          }
        })
      }
      .width('100%')
      .height(48)
      .margin({ top: px2vp(AppUtil.getStatusBarHeight()) })
      .opacity(this.titleBarOpacity)
      .animation({ curve: Curve.Ease, duration: 200 })

      Scroll() {
        Column() {
          Column() {
            this.weatherForecase40Calendar()
          }
          .width(this.calendarPanelWidth)
          .height(this.calendarPanelHeight)
          .alignSelf(this.itemAlign)
          .borderRadius(12)
          .backgroundColor(ColorUtils.alpha(this.options.isDark ? $r('app.color.special_white') :
          $r('app.color.special_black'), this.options.panelOpacity))
          .clip(true)
          .margin({ top: this.marginTop })
          .opacity(this.contentOpacity)
          .animation({ curve: Curve.Ease, duration: 200 })

          Blank().height(12)
          Column() {
            this.weatherForecase40Chart()
          }
          .width('100%')
          .height(288)
          .borderRadius(12)
          .backgroundColor(ColorUtils.alpha(this.options.isDark ? $r('app.color.special_white') :
          $r('app.color.special_black'), this.options.panelOpacity))
          .opacity(this.titleBarOpacity)
          .animation({ curve: Curve.Ease, duration: 200 })
        }
        .padding({
          left: 16,
          top: 12,
          right: 16,
          bottom: px2vp(AppUtil.getNavigationIndicatorHeight()) + 12
        })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  closeIcon() {
    Stack() {
      Image($r('app.media.ic_close_icon1'))
        .width(22)
        .height(22)
        .colorFilter(ColorUtils.translateColor(this.options.isWeatherHeaderDark ? $r('app.color.special_white') :
        $r('app.color.special_black')))
    }
    .width(54)
    .height(48)
  }

  @Builder
  weatherForecase40Calendar() {
    Column() {
      Row() {
        this.weekTitle('日')
        this.weekTitle('一')
        this.weekTitle('二')
        this.weekTitle('三')
        this.weekTitle('四')
        this.weekTitle('五')
        this.weekTitle('六')
      }

      Swiper(this.swiperController) {
        ForEach(this.pageData, (item: Array<WeatherDetailData>) => {
          this.weatherForecase40CalendarItem(item)
        }, (item: Array<WeatherDetailData>) => item[0].date)
      }
      .width('100%')
      .height(348)
      .loop(false)
      .indicator(
        Indicator.dot()
          .itemWidth(3)
          .itemHeight(2)
          .selectedItemWidth(6)
          .selectedItemHeight(2)
          .color(ColorUtils.alpha($r('app.color.special_white'), 0.5))
          .selectedColor($r('app.color.special_white'))
          .bottom(0)
      )

      Blank().height(6)
      Divider()
        .strokeWidth(0.5)
        .color(ColorUtils.alpha($r('app.color.special_white'), 0.2))
      Row() {
        Column() {
          Text(this.currentDateStr)
            .fontSize(18)
            .fontColor($r('app.color.special_white'))
          Blank().height(8)
          Text(this.currentWeekDay)
            .fontSize(15)
            .fontColor($r('app.color.special_white'))
        }
        .alignItems(HorizontalAlign.Start)

        Column() {
          Row() {
            Text(this.currentSelectedItem?.aqi_level_name)
              .fontSize(11)
              .fontColor($r('app.color.special_white'))
              .padding({
                left: 8,
                top: 2,
                right: 8,
                bottom: 2
              })
              .borderRadius(8)
              .backgroundColor(ColorUtils.alpha(getAqiColor(this.currentSelectedItem?.aqi), 0.48))
              .visibility(StrUtil.isNotEmpty(this.currentSelectedItem?.aqi_level_name) ? Visibility.Visible :
              Visibility.Hidden)
            Blank().width(4)
            Text(`${this.currentSelectedItem?.high}/${this.currentSelectedItem?.low}°`)
              .fontSize(18)
              .fontColor($r('app.color.special_white'))
          }

          Blank().height(8)
          Text(`${this.currentSelectedItem?.day?.wthr} ${this.currentSelectedItem?.day?.wd}${this.currentSelectedItem?.day?.wp}`)
            .fontSize(15)
            .fontColor($r('app.color.special_white'))
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }

  @Builder
  weatherForecase40Chart() {
    Column() {
      Blank().height(12)
      Text('40日天气趋势')
        .fontSize(18)
        .fontColor($r('app.color.special_white'))
        .fontWeight(FontWeight.Bold)
        .padding({ left: 16 })
      Blank().height(16)
      Row() {
        Blank()
        Text(`${this.options.forecast40Data?.down_days ?? 0}`)
          .fontSize(18)
          .fontColor($r('app.color.special_white'))
        Text('天降温')
          .fontSize(13)
          .fontColor(ColorUtils.alpha($r('app.color.special_white'), 0.6))
        Blank().width(4)
        Text(`${this.options.forecast40Data?.up_days ?? 0}`)
          .fontSize(18)
          .fontColor($r('app.color.special_white'))
        Text('天升温')
          .fontSize(13)
          .fontColor(ColorUtils.alpha($r('app.color.special_white'), 0.6))
        Blank().width(4)
        Text(`${this.options.forecast40Data?.rain_days ?? 0}`)
          .fontSize(18)
          .fontColor($r('app.color.special_white'))
        Text('天有降水')
          .fontSize(13)
          .fontColor(ColorUtils.alpha($r('app.color.special_white'), 0.6))
        Blank()
      }
      .width('100%')

      WeatherForecase40Chart({
        initSelectedItem: this.currentSelectedItem,
        forecast40: this.options.forecast40,
        chartController: this.chartController,
        callback: (currentSelectedItem) => {
          const index = this.pageData.findIndex(it => it.find(it1 => it1.date == currentSelectedItem?.date) != null)
          if (index >= 0) {
            this.swiperController.changeIndex(index, true)
          }
          this.currentSelectedItem = currentSelectedItem
        }
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  weekTitle(title: string) {
    Text(title)
      .fontSize(12)
      .fontColor($r('app.color.special_white'))
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .padding({ top: 12, bottom: 12 })
  }

  @Builder
  weatherForecase40CalendarItem(item: Array<WeatherDetailData>) {
    Grid() {
      ForEach(item, (innerItem: WeatherDetailData, index: number) => {
        this.weatherForecase40CalendarDateItem(innerItem, item[index - 1])
      }, (innerItem: WeatherDetailData) => innerItem.date)
    }
    .width('100%')
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
    .maxCount(7)
    .layoutDirection(GridDirection.Row)
  }

  @Builder
  weatherForecase40CalendarDateItem(item: WeatherDetailData, preItem: WeatherDetailData | undefined) {
    GridItem() {
      Stack() {
        Stack()
          .width('100%')
          .height(324 / 4)
          .borderRadius(6)
          .backgroundColor(this.isSelected(item) ?
          ColorUtils.alpha(this.options.isDark ? $r('app.color.special_black') : $r('app.color.special_white'),
            this.options.panelOpacity) : undefined)
          .opacity(this.isSelected(item) ? 1 : 0)
          .animation({ curve: Curve.Ease, duration: 200 })

        Column() {
          Blank().height(12)
          Text(this.isToday(item) ? '今天' : this.dateStr(item, preItem))
            .fontSize(15)
            .fontColor(ColorUtils.alpha($r('app.color.special_white'), this.isEnabled(item) ? 1 : 0.6))
            .fontWeight(this.isToday(item) ? FontWeight.Bold : undefined)
          Blank().height(4)
          if (this.isEnabled(item)) {
            Image(WeatherIconUtils.getWeatherIconByType(item.day?.type ?? -1, item.day?.third_type ?? '', false))
              .width(24)
              .height(24)
          } else {
            Blank().width(24).height(24)
          }
          Blank()
          Text('降水')
            .align(Alignment.Bottom)
            .padding({
              left: 6,
              top: 3,
              right: 6,
              bottom: 3
            })
            .margin({ bottom: 4 })
            .borderRadius(100)
            .backgroundColor($r('app.color.color_0da8ff'))
            .fontSize(13)
            .fontColor($r('app.color.special_white'))
            .visibility(this.isRain(item) ? Visibility.Visible : Visibility.Hidden)
        }
        .height(324 / 4)
      }
      .width('100%')
      .height(324 / 4)
      .onClick(this.isEnabled(item) ? () => {
        this.currentSelectedItem = item
        this.chartController.updateCurrentSelectedItem(item)
      } : undefined)
    }
  }

  isSelected(data: WeatherDetailData): boolean {
    return this.currentSelectedItem?.date == data.date
  }

  isEnabled(data: WeatherDetailData | undefined): boolean {
    return !ObjectUtil.isEmpty(data?.day)
  }

  isToday(data: WeatherDetailData): boolean {
    const date = DateUtil.getFormatDate(getHarmonyDateTimeFormattedString(data.date))
    return DateUtil.isToday(date)
  }

  isRain(data: WeatherDetailData): boolean {
    const weatherType = data.day?.third_type
    return weatherType == 'LIGHT_RAIN' || weatherType == 'MODERATE_RAIN' || weatherType == 'HEAVY_RAIN' ||
      weatherType == 'STORM_RAIN'
  }

  dateStr(data: WeatherDetailData, preData: WeatherDetailData | undefined): string {
    const date = DateUtil.getFormatDate(getHarmonyDateTimeFormattedString(data.date))
    let dateStr = DateUtil.getFormatDateStr(date, 'dd')
    if (preData) {
      const preDate = DateUtil.getFormatDate(getHarmonyDateTimeFormattedString(preData.date))
      if (date.getMonth() != preDate.getMonth()) {
        dateStr = parseInt(DateUtil.getFormatDateStr(date, 'MM')) + '月'
      }
    }
    return dateStr
  }

  get currentDateStr() {
    const date = DateUtil.getFormatDate(getHarmonyDateTimeFormattedString(this.currentSelectedItem?.date))
    return DateUtil.getFormatDateStr(date, 'MM月dd日')
  }

  get currentWeekDay() {
    const date = DateUtil.getFormatDate(getHarmonyDateTimeFormattedString(this.currentSelectedItem?.date))
    const weekDay = DateUtil.getWeekDay(date)
    switch (weekDay) {
      case 0:
        return '星期日'
      case 1:
        return '星期一'
      case 2:
        return '星期二'
      case 3:
        return '星期三'
      case 4:
        return '星期四'
      case 5:
        return '星期无'
      case 6:
        return '星期六'
    }
    return ''
  }
}