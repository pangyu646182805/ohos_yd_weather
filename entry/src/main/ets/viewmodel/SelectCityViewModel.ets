import { Logger } from "@hzw/logger";
import { AppUtil, ArrayUtil, LocationUtil, PermissionUtil, ToastUtil } from "@pura/harmony-utils";
import { TaoYao } from "@shijing/taoyao";
import BaseViewModel from "../base/BaseViewModel";
import { ViewState } from "../constants/ViewState";
import { CityData } from "../db/model/CityData";
import { LocationData } from "../entity/LocationData";
import { SelectCityData } from "../entity/SelectCityData";
import SelectCityModel from "../model/SelectCityModel";
import { ResultData } from "../net/ResultData";
import { geoLocationManager } from "@kit.LocationKit";
import { JSON } from "@kit.ArkTS";
import { DialogAction, DialogHelper } from "@pura/harmony-dialog";
import { Permissions } from "@kit.AbilityKit";

@ObservedV2
export default class SelectCityViewModel extends BaseViewModel {
  @Trace selectCityData?: SelectCityData
  @Trace searchResult?: Array<CityData>
  @Trace addedCityData?: Array<CityData>
  @Trace searchResultContentOpacity: number = 0
  @Trace locationData?: LocationData
  // 0-定位中
  // 1-定位结束
  @Trace locationState: number = 0
  private model = new SelectCityModel()

  obtainHotCityData() {
    this.setViewState(ViewState.VIEW_STATE_LOADING)
    this.model.obtainHotCityData()
      .then((response: ResultData<SelectCityData>) => {
        this.selectCityData = response.data
        this.setViewState(ViewState.VIEW_STATE_SUCCESS)
        this.obtainAddedCityData()
        this.obtainLocationPermission()
      })
      .catch((e: Error) => {
        this.setErrorMessage(e.message)
        this.setViewState(ViewState.VIEW_STATE_ERROR)
      })
  }

  searchCity(searchKey: string) {
    this.model.searchCity(searchKey)
      .then((response: ResultData<Array<CityData>>) => {
        let searchResult = response.data
        if (ArrayUtil.isEmpty(searchResult)) {
          ToastUtil.showToast('无匹配城市')
        }
        this.searchResult = searchResult
      })
      .catch(() => {
        this.searchResult = undefined
      })
  }

  obtainAddedCityData() {
    this.model.obtainAddedCityData()
      .then(addedCityData => {
        Logger.e('addedCityData = ' + JSON.stringify(addedCityData))
        this.addedCityData = addedCityData
      })
  }

  obtainLocationPermission() {
    this.locationData = undefined
    this.locationState = 0
    const ps: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION']
    TaoYao.with(AppUtil.getContext())
      .runtime()
      .permission(ps)
      .onGranted(() => {
        this.onPermissionGranted()
      })
      .onDenied(() => {
        Logger.e('权限申请失败')
        this.locationData = undefined
        this.locationState = 1
        DialogHelper.showAlertDialog({
          title: '权限设置',
          content: $r('app.string.reason_location_permission'),
          primaryButton: '取消',
          secondaryButton: '去设置',
          onAction: (action) => {
            if (action == DialogAction.SURE) {
              PermissionUtil.requestPermissionsEasy(ps)
                .then(success => {
                  if (success) {
                    this.onPermissionGranted()
                  } else {
                    TaoYao.goToSettingPage(AppUtil.getContext())
                  }
                })
            }
          }
        })
      })
      .request()
  }

  private onPermissionGranted() {
    Logger.e('权限申请成功')
    this.startLocation()
      .then(location => {
        if (location) {
          Logger.e('longitude = ' + location.longitude + ' latitude = ' + location.latitude)
          this.model.obtainLocationDataByLocation(location)
            .then(response => {
              let locationData = response.result
              this.locationData = locationData
              this.locationState = 1
            })
            .catch(() => {
              this.locationData = undefined
              this.locationState = 1
            })
        } else {
          this.locationData = undefined
          this.locationState = 1
        }
      })
  }

  async startLocation(): Promise<geoLocationManager.Location | undefined> {
    const isLocationEnabled = LocationUtil.isLocationEnabled()
    Logger.e('isLocationEnabled = ' + isLocationEnabled)
    if (!isLocationEnabled) {
      return undefined
    }
    return LocationUtil.getCurrentLocationEasy()
  }

  @Monitor("searchResult")
  onSearchResultChange(monitor: IMonitor) {
    Logger.e('onSearchResultChange')
    let now = monitor.value<Array<CityData>>()?.now
    setTimeout(() => {
      this.searchResultContentOpacity = ArrayUtil.isEmpty(now) ? 0 : 1
    }, 20)
  }

  clearSearchResult() {
    this.searchResult = undefined
  }
}