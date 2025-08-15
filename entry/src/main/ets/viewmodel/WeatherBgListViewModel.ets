import BaseViewModel from "../base/BaseViewModel";
import { WeatherBgModel } from "../entity/WeatherBgModel";
import { AppRuntimeData } from "../utils/AppRuntimeData";

@ObservedV2
export default class WeatherBgListViewModel extends BaseViewModel {
  @Trace weatherBgMap?: Map<string, Array<WeatherBgModel>>
  @Trace isNight: boolean = false
  @Trace isShowMenu: boolean = false

  getWeatherBgMap() {
    this.weatherBgMap = new Map(AppRuntimeData.getInstance().getWeatherBgMap())
  }
}