import { BaseDialogOptions } from "@pura/harmony-dialog"
import { WeatherDetailData, WeatherForecast40Data, WeatherMetaData } from "../entity/WeatherData"
import { PopupExitController } from "./PopupExitController"

export interface WeatherForecase40DetailPopupOptions extends BaseDialogOptions {
  forecast40Data: WeatherForecast40Data
  forecast40: Array<WeatherDetailData>
  meta: WeatherMetaData
  isDark: boolean
  isWeatherHeaderDark: boolean
  panelOpacity: number
  ref: PopupExitController
}