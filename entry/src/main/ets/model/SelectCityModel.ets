import { SelectCityData } from "../entity/SelectCityData";
import { Api } from "../net/Api";
import { netUtils } from "../net/NetUtils";
import { ResultData } from "../net/ResultData";

export default class SelectCityModel {
  async obtainHotCityData(): Promise<ResultData<SelectCityData>> {
    return netUtils.netGet<SelectCityData>(Api.SELECT_CITY_API)
  }
}