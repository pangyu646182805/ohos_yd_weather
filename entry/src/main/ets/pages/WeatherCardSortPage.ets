import { Route, TranslateAnimationOptions, ZRouter } from "@hzw/zrouter";
import { ArrayUtil, DisplayUtil, ToastUtil } from "@pura/harmony-utils";
import { CommonTitleBar, TitleType } from "common_title_bar";
import { Constants } from "../constants/Constants";
import { RouterConstants } from "../constants/RouterConstants";
import { AppRuntimeData } from "../utils/AppRuntimeData";
import { ColorUtils } from "../utils/ColorUtils";
import { isDark, refreshStatusBar } from "../utils/CommonUtils";
import { WeatherCardSortListItem } from "../widget/WeatherCardSortListItem";

@Route({ name: RouterConstants.WEATHER_CARD_SORT_PAGE })
@ComponentV2
export struct WeatherCardSortPage {
  @Local isBackEnabled: boolean = true
  @Local currentWeatherCardSort: Array<number> = []
  @Local currentWeatherObserveCardSort: Array<number> = []
  @Local contentOpacity: number = 1
  @Local gridOpacity: number = 0
  @Local marginTop: number = 0
  @Local animDuration: number = 0
  private tempMarginTop = 0

  aboutToAppear(): void {
    this.currentWeatherCardSort =
      AppRuntimeData.getInstance().currentWeatherCardSort.filter(it => it != Constants.ITEM_TYPE_WEATHER_HEADER)
    this.currentWeatherObserveCardSort = AppRuntimeData.getInstance().currentWeatherObservesCardSort
  }

  build() {
    NavDestination() {
      Column() {
        CommonTitleBar({
          statusBarColor: $r('app.color.transparent'),
          titleBarColor: $r('app.color.transparent'),
          showBottomLine: false,
          leftType: TitleType.CUSTOM,
          leftCustomView: () => {
            this.leftIcon()
          },
          centerText: '卡片排序',
          centerTextColor: $r('app.color.black'),
          rightType: TitleType.TEXT,
          rightText: '恢复默认',
          rightTextColor: ColorUtils.alpha($r('app.color.black'), this.isBackEnabled ? 1 : 0.2),
          rightOnClick: this.isBackEnabled ? () => {
            const currentWeatherCardSort = [Constants.ITEM_TYPE_WEATHER_HEADER]
            currentWeatherCardSort.push(...this.currentWeatherCardSort)
            if (this.compareCurrentWeatherCardSort(currentWeatherCardSort) ||
            this.compareCurrentWeatherObserverCardSort(this.currentWeatherObserveCardSort)) {
              const defaultWeatherCardSort = [...Constants.DEFAULT_WEATHER_CARD_SORT]
              const currentWeatherObserveCardSort = [...Constants.DEFAULT_WEATHER_OBSERVES_CARD_SORT]
              AppRuntimeData.getInstance().setCurrentWeatherCardSort(defaultWeatherCardSort)
              AppRuntimeData.getInstance().setCurrentWeatherObservesCardSort(currentWeatherObserveCardSort)
              this.currentWeatherCardSort =
                defaultWeatherCardSort.filter(it => it != Constants.ITEM_TYPE_WEATHER_HEADER)
              this.currentWeatherObserveCardSort = currentWeatherObserveCardSort
            }
            ToastUtil.showToast('已恢复默认')
          } : undefined
        })
        Stack() {
          this.weatherCardSortList()
          this.weatherCardSortGrid()
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .height('100%')
    .width('100%')
    .onReady((context) => {
      ZRouter.animateMgr()
        .registerAnimParam(this, context)
        .setEnterAnimate({ duration: 500, curve: Curve.LinearOutSlowIn })
        .setExitAnimate({ duration: 500, curve: Curve.LinearOutSlowIn })
        .addAnimateOptions(new TranslateAnimationOptions({ y: '100%' }))
    })
    .onDisAppear(() => {
      ZRouter.animateMgr().unregisterAnim(this)
    })
    .onShown(() => {
      refreshStatusBar({
        isStatusBarLightIcon: isDark()
      })
    })
    .attributeModifier(ZRouter.animateMgr().modifier(this))
    .backgroundColor($r('app.color.bg_color'))
  }

  @Builder
  leftIcon() {
    Image($r('app.media.ic_close_icon1'))
      .width(20)
      .height(20)
      .colorFilter(ColorUtils.translateColor($r('app.color.black'), this.isBackEnabled ? 1 : 0.2))
      .onClick(this.isBackEnabled ? () => {
        ZRouter.getInstance().pop()
      } : undefined)
  }

  @Builder
  weatherCardSortList() {
    List() {
      ListItem() {
        Text('首页的天气卡片将会按照以下排序进行展示')
          .height(30)
          .textAlign(TextAlign.Start)
          .align(Alignment.BottomStart)
          .padding({ left: 16 })
          .fontSize(14)
          .fontColor($r('app.color.color_999999'))
      }

      ForEach(this.currentWeatherCardSort, (item: number) => {
        WeatherCardSortListItem({
          weatherCardItemType: item,
          index: this.currentWeatherCardSort.findIndex(it => it == item),
          length: this.currentWeatherCardSort.length,
          onReorderStart: () => {
            this.isBackEnabled = false
            return true
          },
          onChangeItem: (from, to) => {
            if (ArrayUtil.isNotEmpty(this.currentWeatherCardSort)) {
              const tmp = this.currentWeatherCardSort.splice(from, 1)
              this.currentWeatherCardSort.splice(to, 0, tmp[0])
            }
          },
          onReorderDone: () => {
            this.isBackEnabled = true
            const currentWeatherCardSort = [Constants.ITEM_TYPE_WEATHER_HEADER]
            currentWeatherCardSort.push(...this.currentWeatherCardSort)
            AppRuntimeData.getInstance().setCurrentWeatherCardSort(currentWeatherCardSort)
          },
          onWeatherObserveSortTap: () => {
            const index = this.currentWeatherCardSort.findIndex(it => it == item)
            if (index >= 0) {
              this.contentOpacity = 0
              this.animDuration = 0
              this.marginTop = index * (48 + 12)
              this.tempMarginTop = this.marginTop
              setTimeout(() => {
                this.animDuration = 200
                this.marginTop = 0
                this.gridOpacity = 1
              }, 16)
            }
          }
        })
      }, (item: number) => item.toString())
    }
    .width('100%')
    .height('100%')
    .divider({ strokeWidth: 12, color: $r('app.color.transparent') })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .opacity(this.contentOpacity)
    .animation({ curve: Curve.Ease, duration: 200 })
  }

  @Builder
  weatherCardSortGrid() {
    List() {
      ListItem() {
        Text('专业数据卡片将会按照以下排序进行展示')
          .height(30)
          .textAlign(TextAlign.Start)
          .align(Alignment.BottomStart)
          .padding({ left: 16 })
          .fontSize(14)
          .fontColor($r('app.color.color_999999'))
      }

      ListItem() {
        Row() {
          Row() {
            Text('专业数据')
              .fontSize(16)
              .fontColor($r('app.color.black'))
              .fontWeight(FontWeight.Bold)
            Image($r('app.media.ic_sort_icon'))
              .width(18)
              .height(18)
              .colorFilter(ColorUtils.translateColor($r('app.color.color_999999')))
              .margin({ left: 8 })
              .draggable(false)
          }

          Image($r('app.media.ic_close_icon1'))
            .width(18)
            .height(18)
            .colorFilter(ColorUtils.translateColor($r('app.color.color_999999')))
            .draggable(false)
            .onClick(() => {
              this.gridOpacity = 0
              this.animDuration = 200
              this.marginTop = this.tempMarginTop
              setTimeout(() => {
                this.contentOpacity = 1
              }, 200)
            })
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r('app.color.card_color_06'))
        .borderRadius(6)
        .padding({ left: 16, right: 16 })
      }
      .padding({ left: 16, right: 16 })
      .margin({ top: this.marginTop })
      .animation({ curve: Curve.Ease, duration: this.animDuration })

      ListItem() {
        Grid() {
          ForEach(this.currentWeatherObserveCardSort, (item: number) => {
            this.weatherCardSortGridItem(item, '100%')
          }, (item: number) => item.toString())
        }
        .width('100%')
        .scrollBar(BarState.Off)
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .maxCount(2)
        .padding({ left: 16, right: 16 })
        .layoutDirection(GridDirection.Row)
        .opacity(this.gridOpacity)
        .animation({ curve: Curve.Ease, duration: 200 })
        .editMode(true)
        .supportAnimation(true)
        .onItemDragStart((_, itemIndex: number) => {
          this.isBackEnabled = false
          return this.pixelMapBuilder(this.currentWeatherObserveCardSort[itemIndex])
        })
        .onItemDrop((_, itemIndex: number, insertIndex: number, isSuccess: boolean) => {
          if (!isSuccess || insertIndex >= this.currentWeatherObserveCardSort.length) {
            return
          }
          this.isBackEnabled = true
          this.changeGridIndex(itemIndex, insertIndex)
        })
      }
    }
    .width('100%')
    .height('100%')
    .divider({ strokeWidth: 12, color: $r('app.color.transparent') })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .backgroundColor($r('app.color.bg_color'))
    .opacity(1 - this.contentOpacity)
    .animation({ curve: Curve.Ease, duration: 200 })
    .visibility(this.contentOpacity == 1 ? Visibility.Hidden : Visibility.Visible)
  }

  @Builder
  weatherCardSortGridItem(itemType: number, width: number | string) {
    GridItem() {
      Row() {
        Text(this.getTitle(itemType))
          .fontSize(16)
          .fontColor($r('app.color.black'))
          .fontWeight(FontWeight.Bold)

        Image($r('app.media.ic_menu_icon'))
          .width(24)
          .height(24)
          .colorFilter(ColorUtils.translateColor($r('app.color.color_999999')))
          .draggable(false)
      }
      .width(width)
      .height(48)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('app.color.card_color_06'))
      .borderRadius(6)
      .padding({ left: 16, right: 16 })
    }
  }

  @Builder
  pixelMapBuilder(itemType: number) {
    this.weatherCardSortGridItem(itemType, (px2vp(DisplayUtil.getWidth()) - 2 * 16 - 12) / 2)
  }

  changeGridIndex(index1: number, index2: number) {
    let tmp = this.currentWeatherObserveCardSort.splice(index1, 1)
    this.currentWeatherObserveCardSort.splice(index2, 0, tmp[0])
    AppRuntimeData.getInstance().setCurrentWeatherObservesCardSort(this.currentWeatherObserveCardSort)
  }

  getTitle(itemType: number): string {
    switch (itemType) {
      case Constants.ITEM_TYPE_OBSERVE_UV:
        return "紫外线指数"
      case Constants.ITEM_TYPE_OBSERVE_SHI_DU:
        return "湿度"
      case Constants.ITEM_TYPE_OBSERVE_TI_GAN:
        return "体感温度"
      case Constants.ITEM_TYPE_OBSERVE_WD:
        return "风向";
      case Constants.ITEM_TYPE_OBSERVE_SUNRISE_SUNSET:
        return "日出日落"
      case Constants.ITEM_TYPE_OBSERVE_PRESSURE:
        return "气压"
      case Constants.ITEM_TYPE_OBSERVE_VISIBILITY:
        return "可见度"
      case Constants.ITEM_TYPE_OBSERVE_FORECAST40:
        return "未来40日天气"
    }
    return ""
  }

  compareCurrentWeatherCardSort(currentWeatherCardSort: Array<number>): boolean {
    if (currentWeatherCardSort.length != Constants.DEFAULT_WEATHER_CARD_SORT.length) {
      return false
    }
    for (let index = 0; index < currentWeatherCardSort.length; index++) {
      if (Constants.DEFAULT_WEATHER_CARD_SORT[index] != currentWeatherCardSort[index]) {
        return true
      }
    }
    return false
  }

  compareCurrentWeatherObserverCardSort(currentWeatherObserverCardSort: Array<number>): boolean {
    if (currentWeatherObserverCardSort.length !=
    Constants.DEFAULT_WEATHER_OBSERVES_CARD_SORT.length) {
      return false
    }
    for (let index = 0; index < currentWeatherObserverCardSort.length; index++) {
      if (Constants.DEFAULT_WEATHER_OBSERVES_CARD_SORT[index] != currentWeatherObserverCardSort[index]) {
        return true
      }
    }
    return false
  }
}