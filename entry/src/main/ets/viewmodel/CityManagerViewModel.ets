import BaseViewModel from "../base/BaseViewModel";
import { CityData } from "../db/model/CityData";

@ObservedV2
export default class CityManagerViewModel extends BaseViewModel {
  @Trace isEditMode: boolean = false
  @Trace selectedList: Array<CityData> = []
  @Trace titleOpacity: number = 0

  changeTitleOpacity(opacity: number) {
    console.log('titleOpacity = ' + opacity)
    this.titleOpacity = opacity
  }
}