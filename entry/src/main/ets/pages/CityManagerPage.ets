import { ZRouter } from "@hzw/zrouter"
import { AppUtil, ArrayUtil } from "@pura/harmony-utils"
import { CommonTitleBar, TitleType } from "common_title_bar"
import { RouterConstants } from "../constants/RouterConstants"
import { CityData } from "../db/model/CityData"
import { ColorUtils } from "../utils/ColorUtils"
import { fixPercent } from "../utils/CommonUtils"
import CityManagerViewModel from "../viewmodel/CityManagerViewModel"
import { CityManagerItem } from "../widget/CityManagerItem"

@ComponentV2
export struct CityManagerPage {
  @Param addedCityData?: Array<CityData> = []
  @Consumer('cityManagerVm') cityManagerVm: CityManagerViewModel = new CityManagerViewModel()
  @Param onBackPressed: () => boolean = () => this.cityManagerVm.isEditMode
  private listScroller: ListScroller = new ListScroller()

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
        leftImageResource: this.cityManagerVm.isEditMode ? $r('app.media.ic_close_icon1') :
        $r('app.media.ic_close_icon'),
        leftImageWidth: 22,
        leftImageHeight: 22,
        leftImagePadding: 0,
        leftOnClick: () => {
          if (this.cityManagerVm.isEditMode) {
            this.cityManagerVm.closeEditMode()
          }
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
          this.listScroller.closeAllSwipeActions()
        }
      })
      this.contentView()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_color'))
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
      $r('app.color.special_black')) : undefined)
      .onClick(() => {
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
    List({ scroller: this.listScroller }) {
      ListItem() {
        Text(this.title)
          .fontSize(28)
          .fontColor($r('app.color.black'))
          .opacity(1 - this.cityManagerVm.titleOpacity)
          .padding({ left: 16, top: 12 })
          .height(60)
      }

      ForEach(this.addedCityData, (cityData: CityData) => {
        ListItem() {
          CityManagerItem({
            cityData: cityData,
            isEditMode: this.cityManagerVm.isEditMode,
            isSelected: this.cityManagerVm.isSelected(cityData),
            toEditMode: (cityData) => {
              this.cityManagerVm.toEditMode(this.addedCityData?.length ?? 0, cityData)
            },
            onItemClick: (cityData) => {
              if (this.cityManagerVm.isEditMode) {
                this.cityManagerVm.selected(cityData)
              }
            }
          })
        }
        .swipeAction({
          end: !cityData.isLocationCity && !this.cityManagerVm.isEditMode ? () => {
            this.itemEnd(cityData)
          } : undefined,
        })
        .transition(TransitionEffect.SLIDE)
      }, (cityData: CityData): string => {
        return cityData.cityid ?? ''
      })
      ListItem() {
        Divider()
          .width('100%')
          .height(px2vp(AppUtil.getNavigationIndicatorHeight()) + (this.cityManagerVm.isEditMode ? 54 : 0))
          .color($r('app.color.transparent'))
      }
    }
    .width('100%')
    .height('100%')
    .divider({ strokeWidth: 12, color: $r('app.color.transparent') })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .onDidScroll(() => {
      const yOffset = this.listScroller.currentOffset().yOffset
      const percent = fixPercent(yOffset / 72)
      this.cityManagerVm.changeTitleOpacity(percent)
    })
  }

  @Builder
  itemEnd(item: CityData) {
    Stack() {
      Image($r('app.media.ic_delete_icon'))
        .width(20)
        .height(20)
        .colorFilter(ColorUtils.translateColor($r('app.color.special_white')))
    }
    .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
    .width(48)
    .height(48)
    .backgroundColor($r('app.color.color_fe2c3c'))
    .borderRadius(100)
    .margin({ right: 16 })
    .onClick(() => {
      this.cityManagerVm.removeItem(item, this.addedCityData)
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
        .opacity(this.cityManagerVm.hasSelected() ? 1 : 0.3)
        .onClick(this.cityManagerVm.hasSelected() ? () => {
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