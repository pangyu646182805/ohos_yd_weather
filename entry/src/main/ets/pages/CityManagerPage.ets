import { ZRouter } from "@hzw/zrouter"
import { ArrayUtil } from "@pura/harmony-utils"
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
  @Local cityManagerVm: CityManagerViewModel = new CityManagerViewModel()
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
        leftImageResource: $r('app.media.ic_close_icon'),
        leftImageWidth: 22,
        leftImageHeight: 22,
        leftImagePadding: 0,
        leftOnClick: () => {
        },
        centerType: TitleType.CUSTOM,
        centerCustomView: () => {
          this.centerTitle()
        },
        rightType: TitleType.IMAGE,
        rightImageResource: $r('app.media.ic_search_icon'),
        rightImageWidth: 20,
        rightImageHeight: 20,
        rightImagePadding: 0,
        rightOnClick: () => {
          ZRouter.getInstance()
            .push(RouterConstants.SELECT_CITY_PAGE)
        },
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
  contentView() {
    Stack() {
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
          .height(72)
      }

      ForEach(this.addedCityData, (cityData: CityData, index: number) => {
        ListItem() {
          CityManagerItem({ cityData: cityData })
        }
        .swipeAction({
          end: () => {
            this.itemEnd(index)
          },
        })
      }, (cityData: CityData): string => {
        return cityData.cityid ?? ''
      })
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
  itemEnd(index: number) {
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
    })
  }

  @Builder
  bottomOperateButton() {

  }
}