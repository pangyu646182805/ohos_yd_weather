import { AppUtil, DateUtil, StrUtil } from "@pura/harmony-utils"
import { Constants } from "../constants/Constants"
import { WeatherItemData } from "../entity/WeatherItemData"
import { ColorUtils } from "../utils/ColorUtils"
import { buildPathCommands, fixPercent } from "../utils/CommonUtils"
import { PathShape } from "@kit.ArkUI"

@ComponentV2
export struct WeatherObserveVisibilityPanel {
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
        Text('可见度')
          .fontSize(12)
          .fontColor(ColorUtils.alpha($r('app.color.special_white'), 0.6))
          .width('100%')
          .height(Constants.ITEM_STICKY_HEIGHT)
          .padding({ left: Constants.ITEM_PANEL_MARGIN })
          .translate({ y: this.stickyTranslateY })

        Column() {
          Text(`${Math.round(this.visibilityValue)}${this.visibilityUnit}`)
            .fontSize(32)
            .fontColor($r('app.color.special_white'))
          Blank().height(33)
          Text(this.visibilityDesc)
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

  @Computed
  get currentWeatherDetailData() {
    return this.weatherItemData?.weatherData?.forecast15?.find(it => StrUtil.equal(it.date,
      DateUtil.getFormatDateStr(DateUtil.getToday(), Constants.YYYYMMDD)))
  }

  get weatherVisibility() {
    let visibility = this.weatherItemData?.weatherData?.observe?.visibility
    if (StrUtil.isEmpty(visibility)) {
      visibility = this.currentWeatherDetailData?.visibility
    }
    return visibility
  }

  get visibilityValue() {
    const weatherVisibility = this.weatherVisibility
    if (StrUtil.isEmpty(weatherVisibility)) {
      return 0
    }
    if (weatherVisibility?.toUpperCase().includes('KM')) {
      return parseFloat(weatherVisibility.replaceAll('KM', ''))
    }
    if (weatherVisibility?.toUpperCase().includes('M')) {
      return parseFloat(weatherVisibility.replaceAll('M', ''))
    }
    return 0
  }

  get visibilityUnit() {
    const weatherVisibility = this.weatherVisibility
    if (StrUtil.isEmpty(weatherVisibility)) {
      return ''
    }
    if (weatherVisibility?.toUpperCase().includes('KM')) {
      return '公里'
    }
    if (weatherVisibility?.toUpperCase().includes('M')) {
      return '米'
    }
    return ''
  }

  get visibilityDesc() {
    const weatherVisibility = this.weatherVisibility
    if (StrUtil.isEmpty(weatherVisibility)) {
      return ''
    }
    const visibilityValue = this.visibilityValue
    if (weatherVisibility?.toUpperCase().includes('KM')) {
      if (visibilityValue <= 1) {
        return '视野较差'
      }
      return '视野非常好'
    }
    if (weatherVisibility?.toUpperCase().includes('M')) {
      if (visibilityValue <= 1000) {
        return '视野较差'
      }
      return '视野非常好'
    }
    return ''
  }
}