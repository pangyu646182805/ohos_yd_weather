import { BaseDialogOptions } from "@pura/harmony-dialog";
import { WeatherAlarmsData } from "../entity/WeatherData";
import { PopupExitController } from "./PopupExitController";

export interface WeatherAlarmsDetailPopupOptions extends BaseDialogOptions {
  alarms: Array<WeatherAlarmsData>
  isDark: boolean
  panelOpacity: number
  ref: PopupExitController
}