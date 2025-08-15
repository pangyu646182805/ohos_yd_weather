import { ZRouter } from "@hzw/zrouter"
import { AppUtil, ArrayUtil, DateUtil, EmitterUtil, PreferencesUtil } from "@pura/harmony-utils"
import { CommonTitleBar, TitleType } from "common_title_bar"
import { Constants } from "../constants/Constants"
import { RouterConstants } from "../constants/RouterConstants"
import { CityData } from "../db/model/CityData"
import { ColorUtils } from "../utils/ColorUtils"
import { fixPercent, isNight } from "../utils/CommonUtils"
import CityManagerViewModel from "../viewmodel/CityManagerViewModel"
import { CityManagerItem } from "../widget/CityManagerItem"
import { componentUtils } from "@kit.ArkUI"
import { AppRuntimeData } from "../utils/AppRuntimeData"
import { EmitterManager } from "../utils/EmitterManager"
import { WeatherBgUtils } from "../utils/WeatherBgUtils"

@ComponentV2
export struct CityManagerPage {
  @Param addedCityData?: Array<CityData> = undefined
  @Consumer('cityManagerVm') cityManagerVm: CityManagerViewModel = new CityManagerViewModel()
  @Event showWeatherPage?: (itemRectangle: componentUtils.ComponentInfo | undefined) => void = undefined

  @Computed
  get title() {
    return this.cityManagerVm.isEditMode ?
      (ArrayUtil.isEmpty(this.cityManagerVm.selectedList) ? '请选择项目' :
        '已选择' + this.cityManagerVm.selectedList.length + '项') : '城市管理'
  }

  build() {
    Column() {
      CommonTitleBar({
        statusBarColor: $r('app.color.transparent'),
        titleBarColor: $r('app.color.transparent'),
        showBottomLine: false,
        leftType: TitleType.CUSTOM,
        leftCustomView: () => {
          this.leftIcon()
        },
        centerType: TitleType.CUSTOM,
        centerCustomView: () => {
          this.centerTitle()
        },
        rightType: TitleType.CUSTOM,
        rightCustomView: () => {
          this.rightIcon()
        }
      }).onTouch(e => {
        if (e.type == TouchType.Up) {
          this.cityManagerVm.listScroller.closeAllSwipeActions()
        }
      })
      this.contentView()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_color'))
  }

  @Builder
  leftIcon() {
    Image(this.cityManagerVm.isEditMode ? $r('app.media.ic_close_icon1') : $r('app.media.ic_close_icon'))
      .width(22)
      .height(22)
      .colorFilter(ColorUtils.translateColor($r('app.color.black')))
      .onClick(() => {
        if (this.cityManagerVm.isEditMode) {
          this.cityManagerVm.closeEditMode()
        } else {
          if (this.showWeatherPage) {
            this.showWeatherPage(undefined)
          }
        }
      })
  }

  @Builder
  centerTitle() {
    Text(this.title)
      .fontSize(18)
      .fontColor($r('app.color.black'))
      .opacity(this.cityManagerVm.titleOpacity)
  }

  @Builder
  rightIcon() {
    Image(this.cityManagerVm.isEditMode ? $r('app.media.ic_select_all_icon') : $r('app.media.ic_search_icon'))
      .width(20)
      .height(20)
      .colorFilter(this.cityManagerVm.isEditMode ?
      ColorUtils.translateColor(this.cityManagerVm.isSelectedAll(this.addedCityData) ? $r('app.color.app_main') :
      $r('app.color.black')) : ColorUtils.translateColor($r('app.color.black')))
      .onClick(async () => {
        if (this.cityManagerVm.isEditMode) {
          if (this.cityManagerVm.isSelectedAll(this.addedCityData)) {
            this.cityManagerVm.clearSelected()
          } else {
            this.cityManagerVm.selectedAll(this.addedCityData)
          }
        } else {
          ZRouter.getInstance()
            .push(RouterConstants.SELECT_CITY_PAGE)
        }
      })
  }

  @Builder
  contentView() {
    Stack({ alignContent: Alignment.Bottom }) {
      this.cityList()
      this.bottomOperateButton()
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  cityList() {
    List({ scroller: this.cityManagerVm.listScroller }) {
      ListItem() {
        Text(this.title)
          .fontSize(28)
          .fontColor($r('app.color.black'))
          .opacity(1 - this.cityManagerVm.titleOpacity)
          .padding({ left: 16, top: 12 })
          .height(60)
      }

      ForEach(this.addedCityData, (cityData: CityData) => {
        CityManagerItem({
          cityData: cityData,
          index: this.addedCityData?.findIndex(it => it.cityid == cityData.cityid),
          startIndex: this.cityManagerVm.startIndex,
          endIndex: this.cityManagerVm.endIndex,
          itemOpacity: this.cityManagerVm.itemOpacity,
          length: this.addedCityData?.length,
          isEditMode: this.cityManagerVm.isEditMode,
          isSelected: this.cityManagerVm.isSelected(cityData),
          toEditMode: (cityData) => {
            // 编辑模式
            this.cityManagerVm.toEditMode(this.addedCityData?.length ?? 0, cityData)
          },
          onItemClick: (index, cityData) => {
            if (!cityData) {
              return
            }
            if (this.cityManagerVm.isEditMode) {
              // 编辑模式下选中item
              this.cityManagerVm.selected(cityData)
            } else {
              if (cityData?.cityid != AppRuntimeData.getInstance().currentCityData?.cityid) {
                AppRuntimeData.getInstance().setCurrentCityData(cityData)
                EmitterUtil.post(EmitterManager.REFRESH_WEATHER_DATA_EVENT, false)
              }
              if (this.showWeatherPage) {
                const itemRectangle = componentUtils.getRectangleById(`city_item_${index}`)
                this.showWeatherPage(itemRectangle)
              }
            }
          },
          onRemoveItem: (cityData) => {
            // 删除item
            this.cityManagerVm.removeItem(cityData, this.addedCityData)
          },
          onReorderStart: () => {
            // 开始拖拽排序的回调
            // 返回值为true表示可以拖拽
            // 此处表示不是定位城市才可进行拖拽排序
            this.cityManagerVm.deleteButtonEnable = false
            return !cityData.isLocationCity
          },
          beforeChange: (target) => {
            // 如果返回值是true 表示不能交换item位置
            const targetCityData = this.addedCityData?.[target]
            return targetCityData?.isLocationCity ?? false
          },
          onChangeItem: (from, to) => {
            // 当item交换位置时 列表数据需要交换
            if (ArrayUtil.isNotEmpty(this.addedCityData)) {
              const tmp = this.addedCityData?.splice(from, 1)
              this.addedCityData?.splice(to, 0, tmp![0])
            }
          },
          onReorderDone: async () => {
            // 拖拽排序结束的回调
            this.cityManagerVm.deleteButtonEnable = true
            const currentCityIdList =
              this.addedCityData!.map(it => it.isLocationCity ? Constants.LOCATION_CITY_ID : it.cityid ?? '')
            await PreferencesUtil.put(Constants.CURRENT_CITY_ID_LIST, currentCityIdList)
          }
        })
      }, (cityData: CityData): string => {
        const weatherBg = WeatherBgUtils.generateWeatherBg(cityData.weatherData?.weatherType ?? '',
          isNight(DateUtil.getToday(), cityData.weatherData?.sunrise, cityData.weatherData?.sunset), true)
        return (cityData.cityid ?? '') + weatherBg.toString()
      })
    }
    .id('city_list')
    .width('100%')
    .height('100%')
    .divider({ strokeWidth: 12, color: $r('app.color.transparent') })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .cachedCount(this.addedCityData?.length)
    .contentEndOffset(px2vp(AppUtil.getNavigationIndicatorHeight()) + (this.cityManagerVm.isEditMode ? 54 : 0))
    .onDidScroll(() => {
      const yOffset = this.cityManagerVm.listScroller.currentOffset().yOffset
      const percent = fixPercent(yOffset / 72)
      this.cityManagerVm.changeTitleOpacity(percent)
    })
  }

  @Builder
  bottomOperateButton() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Column({ space: 4 }) {
          Image($r('app.media.ic_delete_icon'))
            .width(20)
            .height(20)
            .colorFilter(ColorUtils.translateColor($r('app.color.black')))
          Text('删除')
            .fontSize(12)
            .fontColor($r('app.color.black'))
        }
        .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
        .opacity(this.cityManagerVm.hasSelected() && this.cityManagerVm.deleteButtonEnable ? 1 : 0.3)
        .onClick(this.cityManagerVm.hasSelected() && this.cityManagerVm.deleteButtonEnable ? () => {
          this.cityManagerVm.removeItems(this.addedCityData)
        } : undefined)
      }
      .width('100%')
      .height(54)
    }
    .width('100%')
    .padding({ bottom: px2vp(AppUtil.getNavigationIndicatorHeight()) })
    .translate({ y: this.cityManagerVm.isEditMode ? 0 : 54 + px2vp(AppUtil.getNavigationIndicatorHeight()) })
    .opacity(this.cityManagerVm.isEditMode ? 1 : 0)
    .animation({ duration: 200, curve: Curve.Linear })
    .backgroundColor($r('app.color.bg_color'))
  }
}