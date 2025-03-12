import { AppUtil, DateUtil, StrUtil } from "@pura/harmony-utils"
import { Constants } from "../constants/Constants"
import { WeatherItemData } from "../entity/WeatherItemData"
import { AppRuntimeData } from "../utils/AppRuntimeData"
import { fixPercent, getTemp } from "../utils/CommonUtils"

@ComponentV2
export struct WeatherHeaderWidget {
  @Param weatherHeaderOffset: number = 0
  @Param isWeatherHeaderDark: boolean = false
  @Param weatherItemData?: WeatherItemData = undefined
  @Param previewCity: boolean = false
  @Local currentHeight: number = Constants.WEATHER_HEADER_MAX_HEIGHT
  @Local marginTop: number = 44
  @Local opacity1: number = 1
  @Local opacity2: number = 1
  @Local opacity3: number = 1
  @Local opacity4: number = 0
  private maxMarginTop = 44
  private minMarginTop = 22

  @Monitor('weatherHeaderOffset')
  onOffsetChanged(monitor: IMonitor) {
    const offset = monitor.value<number>()?.now ?? 0
    const percent = offset / (Constants.WEATHER_HEADER_MAX_HEIGHT - Constants.WEATHER_HEADER_MIN_HEIGHT)
    const newPercent = fixPercent(offset / (Constants.WEATHER_HEADER_MAX_HEIGHT - Constants.WEATHER_HEADER_MIN_HEIGHT))
    const currentHeight = Constants.WEATHER_HEADER_MAX_HEIGHT - offset;
    const minHeight = Constants.WEATHER_HEADER_MIN_HEIGHT
    this.currentHeight = currentHeight < minHeight ? minHeight : currentHeight

    const marginTop = this.minMarginTop + (this.maxMarginTop - this.minMarginTop) * (1 - percent)
    this.marginTop = marginTop < this.minMarginTop ? this.minMarginTop : marginTop

    const opacity1 = 1 - (newPercent - 0.2) / (0.3 - 0.2)
    this.opacity1 = fixPercent(opacity1)
    const opacity2 = 1 - (newPercent - 0.4) / (0.5 - 0.4)
    this.opacity2 = fixPercent(opacity2)
    const opacity3 = 1 - (newPercent - 0.7) / (0.8 - 0.7)
    this.opacity3 = fixPercent(opacity3)
    const opacity4 = 1 - (newPercent - 0.9) / (0.9 - 1.0)
    this.opacity4 = fixPercent(opacity4)
  }

  build() {
    Column() {
      Text(this.title)
        .textStyle(28, FontWeight.Normal, this.isWeatherHeaderDark)
        .margin({ top: this.marginTop })
      Stack({ alignContent: Alignment.Top }) {
        Column({ space: 5 }) {
          Row() {
            Blank()
              .layoutWeight(1)
            Text(this.temp)
              .textStyle(92, FontWeight.Lighter, this.isWeatherHeaderDark)
            Text('°')
              .textStyle(86, FontWeight.Lighter, this.isWeatherHeaderDark)
              .layoutWeight(1)
          }
          .width('100%')
          .opacity(this.opacity3)

          Row() {
            Text('最\n高')
              .textStyle(15, FontWeight.Normal, this.isWeatherHeaderDark)
            Blank().width(3)
            Text(getTemp(this.currentWeatherDetailData?.high))
              .textStyle(34, FontWeight.Lighter, this.isWeatherHeaderDark)
            Blank().width(12)
            Text('最\n低')
              .textStyle(15, FontWeight.Normal, this.isWeatherHeaderDark)
            Blank().width(3)
            Text(getTemp(this.currentWeatherDetailData?.low))
              .textStyle(34, FontWeight.Lighter, this.isWeatherHeaderDark)
          }
          .opacity(this.opacity2)

          Text(this.weatherDesc)
            .textStyle(20, FontWeight.Normal, this.isWeatherHeaderDark)
            .opacity(this.opacity1)
        }

        Text(`${getTemp(this.weatherItemData?.weatherData?.observe?.temp)} | ${this.weatherDesc}`)
          .textStyle(20, FontWeight.Normal, this.isWeatherHeaderDark)
          .opacity(this.opacity4)
      }
      .margin({ top: 5 })
    }
    .width('100%')
    .height(this.currentHeight)
    .margin({ top: px2vp(AppUtil.getStatusBarHeight()) })
    .hitTestBehavior(HitTestMode.Transparent)
    .clip(true)
  }

  get currentWeatherDetailData() {
    return this.weatherItemData?.weatherData?.forecast15?.find(it => StrUtil.equal(it.date,
      DateUtil.getFormatDateStr(DateUtil.getToday(), Constants.YYYYMMDD)))
  }

  get title() {
    const cityData = this.previewCity ? undefined : AppRuntimeData.getInstance().currentCityData
    const isLocationCity = cityData?.isLocationCity ?? false
    const street = cityData?.street ?? "";
    const city = this.weatherItemData?.weatherData?.meta?.city ?? "";
    return !isLocationCity || StrUtil.isEmpty(street) ? city : `${city} ${street}`
  }

  get temp() {
    return this.weatherItemData?.weatherData?.observe?.temp?.toString() ?? ''
  }

  get weatherDesc() {
    return this.weatherItemData?.weatherData?.observe?.wthr ?? this.currentWeatherDetailData?.wthr ?? ''
  }
}

@Extend(Text)
function textStyle(fontSize: number, fontWeight: FontWeight = FontWeight.Lighter, isWeatherHeaderDark: boolean) {
  .fontSize(fontSize)
  .fontColor(isWeatherHeaderDark ? $r('app.color.special_white') : $r('app.color.special_black'))
  .fontWeight(fontWeight)
  .textShadow({
    radius: 2,
    color: $r('app.color.black_3'),
    offsetX: 1,
    offsetY: 1
  })
}