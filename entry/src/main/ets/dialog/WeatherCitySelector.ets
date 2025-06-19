import { DialogHelper } from "@pura/harmony-dialog"
import { PreferencesUtil, StrUtil } from "@pura/harmony-utils"
import { Constants } from "../constants/Constants"
import { appDatabase } from "../db/AppDatabase"
import { CityData, cityDataTable } from "../db/model/CityData"
import { WeatherItemData } from "../entity/WeatherItemData"
import { AppRuntimeData } from "../utils/AppRuntimeData"
import { ColorUtils } from "../utils/ColorUtils"
import { Pair } from "../utils/Pair"
import { WeatherDataUtils } from "../utils/WeatherDataUtils"
import { WeatherCitySelectorOptions } from "./WeatherCitySelectorOptions"

@Builder
export function WeatherCitySelectorBuilder(options: WeatherCitySelectorOptions) {
  WeatherCitySelector({ options: options })
}

@ComponentV2
export struct WeatherCitySelector {
  @Require @Param options: WeatherCitySelectorOptions
  @Local blurAnimValue: number = 0
  @Local list?: Array<Pair<CityData | undefined, Array<WeatherItemData> | undefined>>

  aboutToAppear(): void {
    this.options.ref.exit = this.exit
    setTimeout(() => {
      this.blurAnimValue = 1
    }, 16)
    this.generateData()
      .then((list) => {
        this.list = list
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
            AppRuntimeData.getInstance().currentWeatherObservesCardSort, AppRuntimeData.getInstance().getWeatherData(cityId))
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

  exit = () => {
    this.blurAnimValue = 0
    setTimeout(() => {
      DialogHelper.closeDialog('weather_city_selector')
    }, 200)
  }

  build() {
    Stack() {

    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorUtils.alpha($r('app.color.special_black'), 0.15))
    .opacity(this.blurAnimValue)
    .blur(this.blurAnimValue * 100)
    .animation({ curve: Curve.Linear, duration: 200 })
  }
}