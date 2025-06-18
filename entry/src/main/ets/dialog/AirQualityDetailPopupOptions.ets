import { BaseDialogOptions } from "@pura/harmony-dialog"
import { WeatherEnvData } from "../entity/WeatherData"
import { PopupExitController } from "./PopupExitController"

export interface AirQualityDetailPopupOptions extends BaseDialogOptions {
  evn: WeatherEnvData
  isDark: boolean
  panelOpacity: number
  ref: PopupExitController
}