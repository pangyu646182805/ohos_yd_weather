import BaseViewModel from "../base/BaseViewModel";
import { ViewState } from "../constants/ViewState";
import { WeatherData } from "../entity/WeatherData";
import WeatherMainModel from "../model/WeatherMainModel";

@ObservedV2
export default class WeatherMainViewModel extends BaseViewModel {
  @Trace weatherData = ''
  private model = new WeatherMainModel()

  async obtainWeatherData(): Promise<void> {
    this.setViewState(ViewState.VIEW_STATE_LOADING)
    this.model.obtainWeatherData()
      .then((weatherData: WeatherData) => {
        this.weatherData = JSON.stringify(weatherData)
        this.setViewState(ViewState.VIEW_STATE_SUCCESS)
      })
      .catch((e:  Error) => {
        this.setErrorMessage(e.message)
        this.setViewState(ViewState.VIEW_STATE_ERROR)
      })
  }
}