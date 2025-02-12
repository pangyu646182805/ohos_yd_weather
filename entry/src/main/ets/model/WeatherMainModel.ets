import { WeatherData } from "../entity/WeatherData";
import { Api } from "../net/Api";
import { netUtils } from "../net/NetUtils";

export default class WeatherMainModel {
  async obtainWeatherData(): Promise<WeatherData> {
    return netUtils.netGetT<WeatherData>(Api.WEATHER_API, new Map([
      ['citykey', 101210113],
    ]))
  }
}