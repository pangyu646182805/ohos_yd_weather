import BaseViewModel from "../base/BaseViewModel";
import { ViewState } from "../constants/ViewState";
import { SelectCityData } from "../entity/SelectCityData";
import SelectCityModel from "../model/SelectCityModel";
import { ResultData } from "../net/ResultData";

@ObservedV2
export default class SelectCityViewModel extends BaseViewModel {
  @Trace selectCityData?: SelectCityData
  private model = new SelectCityModel()

  async obtainHotCityData(): Promise<void> {
    this.setViewState(ViewState.VIEW_STATE_LOADING)
    this.model.obtainHotCityData()
      .then((response: ResultData<SelectCityData>) => {
        this.selectCityData = response.data
        this.setViewState(ViewState.VIEW_STATE_SUCCESS)
      })
      .catch((e: Error) => {
        this.setErrorMessage(e.message)
        this.setViewState(ViewState.VIEW_STATE_ERROR)
      })
  }
}