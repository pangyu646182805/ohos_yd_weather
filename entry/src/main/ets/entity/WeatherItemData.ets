import { WeatherData } from "./WeatherData";

export interface WeatherItemData {
  itemType: number
  weatherData: WeatherData
  itemTypeObserves: Array<number>
  maxHeight: number
  minHeight: number
  animMaxHeight: number | undefined
}