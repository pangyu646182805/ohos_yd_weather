import { CityData } from "../db/model/CityData";

export interface SelectCityData {
  hot_international?: Array<CityData>
  hot_national?: Array<CityData>
}