import { ZRouter } from "@hzw/zrouter";
import { ArrayUtil, EmitterUtil, ObjectUtil, PreferencesUtil, StrUtil } from "@pura/harmony-utils";
import BaseViewModel from "../base/BaseViewModel";
import { Constants } from "../constants/Constants";
import { RouterConstants } from "../constants/RouterConstants";
import { appDatabase } from "../db/AppDatabase";
import { CityData, cityDataTable } from "../db/model/CityData";
import { AppRuntimeData } from "../utils/AppRuntimeData";
import { EmitterManager } from "../utils/EmitterManager";

@ObservedV2
export default class CityManagerViewModel extends BaseViewModel {
  @Trace isEditMode: boolean = false
  @Trace selectedList: Array<CityData> = []
  @Trace titleOpacity: number = 0

  changeTitleOpacity(opacity: number) {
    this.titleOpacity = opacity
  }

  closeEditMode() {
    this.isEditMode = false
    this.clearSelected()
  }

  toEditMode(citySize: number, cityData?: CityData) {
    if (!this.isEditMode && !ObjectUtil.isNull(cityData)) {
      const isLocationCity = cityData?.isLocationCity ?? false
      if (citySize <= 1 && isLocationCity) {
        return
      }
      this.isEditMode = true
      if (!isLocationCity) {
        this.selected(cityData)
      }
    }
  }

  isSelectedAll(addedCityData?: Array<CityData>): boolean {
    if (ArrayUtil.isEmpty(addedCityData)) {
      return false
    }
    const find = addedCityData!.find(it => it.isLocationCity)
    return ObjectUtil.isNull(find) ? this.selectedList.length == addedCityData!.length :
      this.selectedList.length == addedCityData!.length - 1
  }

  clearSelected() {
    const deleteCount = this.selectedList.length
    this.selectedList.splice(0, deleteCount)
  }

  selected(cityData?: CityData) {
    if (ObjectUtil.isNull(cityData)) {
      return
    }
    const findIndex = this.selectedList.findIndex(it => it.cityid == cityData!.cityid)
    if (findIndex >= 0) {
      this.selectedList.splice(findIndex, 1)
    } else {
      this.selectedList.push(cityData!)
    }
  }

  selectedAll(addedCityData?: Array<CityData>) {
    if (ArrayUtil.isEmpty(addedCityData)) {
      return
    }
    this.clearSelected()
    this.selectedList.push(...addedCityData!.filter(it => !it.isLocationCity))
  }

  isSelected(cityData?: CityData): boolean {
    if (!this.isEditMode) {
      return false
    }
    if (ObjectUtil.isNull(cityData)) {
      return false
    }
    return this.selectedList.find(it => it.cityid == cityData!.cityid) != null
  }

  hasSelected(): boolean {
    return this.selectedList.length > 0
  }

  async removeItem(cityData?: CityData, addedCityData?: Array<CityData>) {
    if (!ObjectUtil.isNull(cityData) && !ArrayUtil.isEmpty(addedCityData)) {
      const findIndex = addedCityData!.findIndex(it => it.cityid == cityData!.cityid)
      if (findIndex >= 0) {
        animateTo({
          duration: 200,
          curve: Curve.Linear,
          onFinish: async () => {
            await appDatabase.cityDataDao.deleteIf(it => it.equalTo(cityDataTable.cityid, cityData!.cityid))
            const currentCityIdList = await PreferencesUtil.get(Constants.CURRENT_CITY_ID_LIST, []) as Array<string>
            const index = currentCityIdList.findIndex(it => StrUtil.equal(it, cityData!.cityid))
            if (index >= 0) {
              currentCityIdList.splice(index, 1)
              await PreferencesUtil.put(Constants.CURRENT_CITY_ID_LIST, currentCityIdList)
            }
            this.afterRemove(StrUtil.equal(AppRuntimeData.getInstance().currentCityData?.cityid, cityData!.cityid),
              addedCityData)
          }
        }, () => {
          addedCityData?.splice(findIndex, 1)
        })
      }
    }
  }

  async removeItems(addedCityData?: Array<CityData>) {
    if (!ArrayUtil.isEmpty(addedCityData)) {
      animateTo({
        duration: 200,
        curve: Curve.Linear,
        onFinish: () => {
          this.selectedList.forEach(async removeItem => {
            await appDatabase.cityDataDao.deleteIf(it => it.equalTo(cityDataTable.cityid, removeItem.cityid))
          })
          const resetCurrentCityData = this.selectedList.find(removeItem => removeItem.cityid ==
            AppRuntimeData.getInstance().currentCityData?.cityid) != null
          this.closeEditMode()
          this.afterRemove(resetCurrentCityData, addedCityData)
        }
      }, () => {
        this.selectedList.forEach(removeItem => {
          const findIndex = addedCityData!.findIndex(it => it.cityid == removeItem.cityid)
          if (findIndex >= 0) {
            addedCityData?.splice(findIndex, 1)
          }
        })
      })
    }
  }

  private afterRemove(resetCurrentCityData: boolean, addedCityData?: Array<CityData>) {
    if (ArrayUtil.isEmpty(addedCityData)) {
      PreferencesUtil.putSync(Constants.CURRENT_CITY_ID, '')
      ZRouter.getInstance()
        .replace(RouterConstants.SELECT_CITY_PAGE)
    } else {
      if (resetCurrentCityData) {
        AppRuntimeData.getInstance().setCurrentCityData(addedCityData![0])
        EmitterUtil.post(EmitterManager.REFRESH_WEATHER_DATA_EVENT, undefined)
      }
    }
  }
}