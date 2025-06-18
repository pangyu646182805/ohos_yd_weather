import { AppUtil, DisplayUtil } from "@pura/harmony-utils"
import { Constants } from "../constants/Constants"
import { WeatherItemData } from "../entity/WeatherItemData"
import { ColorUtils } from "../utils/ColorUtils"
import { buildPathCommands, fixPercent } from "../utils/CommonUtils"
import { PathShape } from "@kit.ArkUI"
import { WeatherIndexData } from "../entity/WeatherData"
import { ImageKnifeComponent } from "@ohos/imageknife"

@ComponentV2
export struct WeatherLifeIndexPanel {
  @Param weatherItemData?: WeatherItemData = undefined
  @Param isDark: boolean = false
  @Param panelOpacity: number = 0.1
  @Local contentOpacity: number = 1
  @Local stickyTranslateY: number = 0
  @Local panelPathCommands: string = ''
  @Local handlePopupArr: Array<boolean> = []

  aboutToAppear(): void {
    this.panelPathCommands = buildPathCommands(this.panelHeight)
    this.handlePopupArr = this.weatherItemData?.weatherData?.indexes?.map(it => false) ?? []
  }

  build() {
    ListItem() {
      Stack({ alignContent: Alignment.TopStart }) {
        Text('生活指数')
          .fontSize(12)
          .fontColor(ColorUtils.alpha($r('app.color.special_white'), 0.6))
          .width('100%')
          .height(Constants.ITEM_STICKY_HEIGHT)
          .padding({ left: Constants.ITEM_PANEL_MARGIN })
          .translate({ y: this.stickyTranslateY })

        Grid() {
          ForEach(this.weatherItemData?.weatherData?.indexes, (item: WeatherIndexData, index: number) => {
            this.lifeIndexItem(item, index)
          }, (item: WeatherIndexData) => item.name)
        }
        .columnsTemplate('1fr 1fr 1fr')
        .maxCount(3)
        .layoutDirection(GridDirection.Row)
        .padding({ top: Constants.ITEM_STICKY_HEIGHT })
        .clipShape(new PathShape({ commands: this.panelPathCommands }))
      }
      .width('100%')
      .height(this.panelHeight)
      .backgroundColor(ColorUtils.alpha(this.isDark ? $r('app.color.special_white') : $r('app.color.special_black'),
        this.panelOpacity))
      .borderRadius(Constants.ITEM_PANEL_RADIUS)
      .opacity(this.contentOpacity)
      .onAreaChange((_, newValue) => {
        const y = newValue.globalPosition.y
        if (y) {
          const panelHeight = this.panelHeight
          const yValue = y as number
          const offset = px2vp(AppUtil.getStatusBarHeight()) + Constants.WEATHER_HEADER_MIN_HEIGHT - yValue
          const percent = fixPercent((offset - (panelHeight - Constants.ITEM_STICKY_HEIGHT)) /
          Constants.ITEM_STICKY_HEIGHT)
          const stickyTranslateY =
            offset < 0 ? 0 : offset > panelHeight - Constants.ITEM_STICKY_HEIGHT ?
              panelHeight - Constants.ITEM_STICKY_HEIGHT : offset
          this.stickyTranslateY = stickyTranslateY + percent * Constants.ITEM_STICKY_HEIGHT * 0.5
          this.panelPathCommands =
            buildPathCommands(panelHeight, offset + Constants.ITEM_STICKY_HEIGHT)
          this.contentOpacity = 1 - percent
        }
      })
    }
  }

  get panelHeight() {
    const length = this.weatherItemData?.weatherData?.indexes?.length ?? 0
    const columnHeight = this.columnHeight
    return Math.ceil(length / 3) * columnHeight + Constants.ITEM_STICKY_HEIGHT
  }

  get columnHeight() {
    return (px2vp(DisplayUtil.getWidth()) - 2 * 16) / 3
  }

  @Builder
  lifeIndexItem(item: WeatherIndexData, index: number) {
    GridItem() {
      Column() {
        Column() {
          ImageKnifeComponent({
            imageKnifeOption: {
              loadSrc: item.ext?.icon,
              placeholderSrc: $r('app.color.transparent'),
              errorholderSrc: $r('app.color.transparent'),
              objectFit: ImageFit.Contain
            }
          }).width(48).height(48)
          Blank().height(8)
          Text(item.value)
            .fontSize(13)
            .fontColor($r('app.color.special_white'))
        }
        .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
        .onClick(() => {
          this.handlePopupArr[index] = !this.handlePopupArr[index]
        })
        .gesture(
          LongPressGesture()
            .onAction((event: GestureEvent | undefined) => {
              if (event) {
                this.handlePopupArr[index] = !this.handlePopupArr[index]
              }
            })
        )
        .bindPopup(this.handlePopupArr[index], {
          builder: this.lifeIndexPopup(item),
          placement: Placement.Top,
          mask: false,
          popupColor: $r('app.color.special_white'),
          enableArrow: true,
          radius: 12,
          shadow: { radius: 0 },
          onStateChange: (e) => {
            if (!e.isVisible) {
              this.handlePopupArr[index] = false
            }
          }
        })
      }
      .height(this.columnHeight)
      .justifyContent(FlexAlign.Center)
    }
  }

  @Builder
  lifeIndexPopup(item: WeatherIndexData) {
    Column() {
      Text(item.name)
        .fontSize(18)
        .fontColor($r('app.color.special_black'))
        .fontWeight(FontWeight.Bold)
      Blank().height(8)
      Text(item.desc)
        .fontSize(15)
        .fontColor($r('app.color.special_black'))
    }
    .padding(8)
    .constraintSize({ maxWidth: px2vp(DisplayUtil.getWidth()) - 2 * Constants.ITEM_PANEL_MARGIN })
  }
}