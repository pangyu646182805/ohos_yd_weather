import { DisplayUtil } from "@pura/harmony-utils"
import { CityData } from "../db/model/CityData"
import { WeatherItemData } from "../entity/WeatherItemData"
import { Pair } from "../utils/Pair"
import { WeatherCitySnapshot } from "./WeatherCitySnapshot"

@ComponentV2
export struct WeatherCitySelectorItem {
  @Param pair?: Pair<CityData | undefined, Array<WeatherItemData> | undefined> = undefined
  @Event onTap?: () => void

  build() {
    Stack({ alignContent: Alignment.Center }) {
      WeatherCitySnapshot({ cityData: this.pair?.first, data: this.pair?.second, scaleParams: { x: 0.6, y: 0.6 } })
    }
    .width('100%')
    .height('100%')
    .clip(false)
    .onClick(this.onTap)
  }
}