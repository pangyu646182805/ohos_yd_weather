import BaseViewModel from "../base/BaseViewModel";

@ObservedV2
export default class WeatherBgEditViewModel extends BaseViewModel {
  @Trace isNight: boolean = false
  @Trace weatherCitySnapshotScale: number = 0
  @Trace isStartSelected: boolean = true
  @Trace isShowBubbleBox: boolean = false
  @Trace colors: Array<ResourceColor> = []
  @Trace nightColors: Array<ResourceColor> = []
  @Trace hsvColors: Array<[number, number, number]> = []
  @Trace hsvNightColors: Array<[number, number, number]> = []

  getColors(colors: Array<ResourceColor>): Array<[ResourceColor, number]> {
    return [[colors[0], 0.0], [colors[1], 1.0]]
  }
}