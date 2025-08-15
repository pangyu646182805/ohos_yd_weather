import { DialogHelper } from "@pura/harmony-dialog"
import { AppUtil, DisplayUtil, ObjectUtil, PreferencesUtil, StrUtil } from "@pura/harmony-utils"
import { Constants } from "../constants/Constants"
import { appDatabase } from "../db/AppDatabase"
import { CityData } from "../db/model/CityData"
import { WeatherItemData } from "../entity/WeatherItemData"
import { AppRuntimeData } from "../utils/AppRuntimeData"
import { ColorUtils } from "../utils/ColorUtils"
import { MyFrameCallback } from "../utils/MyFrameCallback"
import { Pair } from "../utils/Pair"
import { WeatherDataUtils } from "../utils/WeatherDataUtils"
import { WeatherCitySelectorItem } from "../widget/WeatherCitySelectorItem"
import { WeatherCitySelectorOptions } from "./WeatherCitySelectorOptions"
import { curves } from "@kit.ArkUI"
import { WeatherCitySnapshot } from "../widget/WeatherCitySnapshot"
import { ZRouter } from "@hzw/zrouter"
import { RouterConstants } from "../constants/RouterConstants"

@Builder
export function WeatherCitySelectorBuilder(options: WeatherCitySelectorOptions) {
  WeatherCitySelector({ options: options })
}

@ComponentV2
export struct WeatherCitySelector {
  @Require @Param options: WeatherCitySelectorOptions
  @Local isSwiperShow: boolean = false
  @Local hideSwiper: boolean = false
  @Local blurAnimValue: number = 0
  @Local list?: Array<Pair<CityData | undefined, Array<WeatherItemData> | undefined>>
  @Local scaleArr: Array<number> = []
  @Local currentCityData?: CityData
  @Local currentData?: Array<WeatherItemData>
  @Local scaleAnimValue: number = 0.6
  private swiperController: SwiperController = new SwiperController()
  private screenWidth = px2vp(DisplayUtil.getWidth())
  private screenHeight = px2vp(DisplayUtil.getHeight())
  private index = 0

  aboutToAppear(): void {
    this.options.ref.exit = this.exit
    setTimeout(() => {
      this.blurAnimValue = 1
    }, 16)
    this.generateData()
      .then((list) => {
        this.list = list
        const scaleArr = list.map((e) => {
          return e.first?.cityid == AppRuntimeData.getInstance().currentCityData?.cityid ? 1 : 0.9
        })
        this.scaleArr = scaleArr
        const index = scaleArr.findIndex((e) => e == 1)
        if (index > 0) {
          this.getUIContext().postFrameCallback(new MyFrameCallback({
            onIdleCallback: () => {
              this.isSwiperShow = true
              this.swiperController.changeIndex(index, true)
            }
          }))
        } else {
          this.isSwiperShow = true
        }
      })
  }

  async generateData(): Promise<Array<Pair<CityData | undefined, Array<WeatherItemData> | undefined>>> {
    const list: Array<Pair<CityData | undefined, Array<WeatherItemData> | undefined>> = []
    const currentCityIdList = await PreferencesUtil.get(Constants.CURRENT_CITY_ID_LIST, []) as Array<string>
    const query = await appDatabase.cityDataDao.query()
    currentCityIdList.forEach((cityId) => {
      const cityData = query.find(it => it.key == cityId)
      const findCityId = cityData?.cityid ?? ''
      if (StrUtil.isNotEmpty(findCityId)) {
        const pair = {
          first: cityData,
          second: WeatherDataUtils.generateWeatherItems(AppRuntimeData.getInstance().currentWeatherCardSort,
            AppRuntimeData.getInstance().currentWeatherObservesCardSort,
            AppRuntimeData.getInstance().getWeatherData(cityId))
        } as Pair<CityData | undefined, Array<WeatherItemData> | undefined>
        if (cityId == Constants.LOCATION_CITY_ID) {
          list.splice(0, 0, pair)
        } else {
          list.push(pair)
        }
      }
    })
    return list
  }

  exit = (changeWeatherBg: boolean = false) => {
    this.isSwiperShow = false
    setTimeout(() => {
      this.blurAnimValue = 0
      setTimeout(() => {
        DialogHelper.closeDialog('weather_city_selector')
        if (changeWeatherBg) {
          ZRouter.getInstance()
            .push(RouterConstants.WEATHER_BG_LIST_PAGE)
        }
      }, 200)
    }, 200)
  }

  build() {
    Stack() {
      Stack()
        .width('100%')
        .height('100%')
        .backgroundColor(ColorUtils.alpha($r('app.color.special_black'), 0.15))
        .opacity(this.blurAnimValue)
        .blur(this.blurAnimValue * 100)
        .animation({ curve: Curve.Linear, duration: 200 })
        .onClick(() => {
          this.exit()
        })
      Stack({ alignContent: Alignment.Bottom }) {
        this.changeWeatherBgButton()
      }
      .hitTestBehavior(HitTestMode.Transparent)
      .width('100%')
      .height('100%')

      this.content()

      if (!ObjectUtil.isNull(this.currentCityData)) {
        WeatherCitySnapshot({
          cityData: this.currentCityData,
          data: this.currentData,
          scaleParams: { x: this.scaleAnimValue, y: this.scaleAnimValue }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  content() {
    Swiper(this.swiperController) {
      ForEach(this.list, (item: Pair<CityData | undefined, Array<WeatherItemData> | undefined>, index: number) => {
        WeatherCitySelectorItem({
          pair: item, onTap: () => {
            if (this.index == index) {
              this.switchWeatherCity(index)
            } else {
              this.swiperController.changeIndex(index, true)
            }
          }
        })
          .scale({ x: this.scaleArr[index], y: this.scaleArr[index] })
      }, (item: Pair<CityData | undefined, Array<WeatherItemData> | undefined>) => item.first?.key)
    }
    .direction(Direction.Rtl)
    .clip(false)
    .loop(false)
    .prevMargin(this.screenWidth * 0.2)
    .nextMargin(this.screenWidth * 0.2)
    .indicator(false)
    .customContentTransition({
      timeout: 200,
      transition: (proxy: SwiperContentTransitionProxy) => {
        let scale = 1.0 - (Math.abs(proxy.position)) * 0.1
        this.scaleArr[(proxy.index)%(this.scaleArr.length)] = scale
      }
    })
    .onChange((index) => {
      this.index = index
    })
    .curve(Curve.Friction)
    .height(this.screenHeight * 0.6)
    .opacity(this.hideSwiper ? 0 : (this.isSwiperShow ? 1 : 0))
    .translate({ x: this.isSwiperShow ? 0 : -this.screenWidth })
    .animation({ curve: curves.interpolatingSpring(14, 1, 170, 17), duration: 200 })
    .onClick(() => {
      this.exit()
    })
  }

  @Builder
  changeWeatherBgButton() {
    Text('更改天气背景')
      .width(172)
      .height(42)
      .textAlign(TextAlign.Center)
      .fontSize(16)
      .fontColor($r('app.color.special_white'))
      .borderRadius(100)
      .borderWidth(0.5)
      .borderColor(ColorUtils.alpha($r('app.color.special_white'), 0.5))
      .backgroundColor(ColorUtils.alpha($r('app.color.special_black'), 0.2))
      .margin({ bottom: px2vp(AppUtil.getNavigationIndicatorHeight()) + 32 })
      .opacity(this.blurAnimValue)
      .animation({ curve: Curve.Linear, duration: 200 })
      .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
      .onClick(() => {
        this.exit(true)
      })
  }

  switchWeatherCity(index: number) {
    this.currentCityData = this.list?.[index].first
    this.currentData = this.list?.[index].second
    this.getUIContext().postFrameCallback(new MyFrameCallback({
      onIdleCallback: () => {
        this.scaleAnimValue = 1
        this.hideSwiper = true
        setTimeout(() => {
          this.exit()
        }, 400)
      }
    }))
  }
}