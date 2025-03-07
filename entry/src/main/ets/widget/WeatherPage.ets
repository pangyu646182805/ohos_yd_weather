import { CommonTitleBar, TitleType } from "common_title_bar";
import { ColorUtils } from "../utils/ColorUtils";
import { componentUtils, PathShape } from "@kit.ArkUI";
import { DisplayUtil } from "@pura/harmony-utils";
import WeatherMainViewModel from "../viewmodel/WeatherMainViewModel";
import { fixPercent } from "../utils/CommonUtils";

@ComponentV2
export struct WeatherPage {
  @Consumer('weatherMainVM') weatherMainVM: WeatherMainViewModel = new WeatherMainViewModel()
  @Event showCityManagerPage?: () => componentUtils.ComponentInfo | undefined = undefined
  @Event showCityList?: () => void = undefined
  @Event hideCityList?: () => void = undefined

  aboutToAppear(): void {
    this.weatherMainVM.pathCommands = this.buildPathCommands(0)
    this.weatherMainVM.animatorOptions = this.getUIContext().createAnimator({
      duration: 400,
      delay: 0,
      easing: 'ease',
      iterations: 1,
      fill: "forwards",
      direction: 'normal',
      begin: 0,
      end: 1
    })
    this.weatherMainVM.animatorOptions.onFrame = (animValue: number) => {
      this.weatherMainVM.animValue = animValue
      this.weatherMainVM.pathCommands = this.buildPathCommands(animValue)
      this.weatherMainVM.contentVisibility = animValue >= 1 ? Visibility.Hidden : Visibility.Visible
    }
    this.weatherMainVM.animatorOptions.onFinish = () => {
      if (this.weatherMainVM.isShowCityManagerPage) {
        if (this.showCityList) {
          this.showCityList()
        }
      } else {
        if (this.hideCityList) {
          this.hideCityList()
        }
      }
    }
  }

  private buildPathCommands(animValue: number): string {
    const radius = vp2px(16)
    const offsetY = this.weatherMainVM.offsetY
    const itemHeight = vp2px(98)
    const vy =
      (DisplayUtil.getHeight() - offsetY - itemHeight) * (1 - animValue) + offsetY + itemHeight - radius * animValue
    return `M ${radius * animValue} ${(offsetY + radius) *
      animValue} Q ${radius * animValue} ${offsetY *
      animValue}, ${2 * radius * animValue} ${offsetY *
      animValue} H ${DisplayUtil.getWidth() - 2 * radius * animValue} Q ${DisplayUtil.getWidth() -
      radius * animValue} ${offsetY * animValue},
      ${DisplayUtil.getWidth() - radius * animValue} ${(offsetY + radius) *
      animValue} V ${vy} Q ${DisplayUtil.getWidth() - radius * animValue}
      ${vy + radius * animValue}, ${DisplayUtil.getWidth() -
      2 * radius * animValue} ${vy + radius * animValue}
      H ${2 * radius * animValue} Q ${radius * animValue}
      ${vy + radius * animValue}, ${radius * animValue} ${vy} Z`
  }

  aboutToDisappear(): void {
    this.weatherMainVM.animatorOptions = undefined
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      this.weatherContentList()
      CommonTitleBar({
        statusBarColor: $r('app.color.transparent'),
        titleBarColor: $r('app.color.transparent'),
        showBottomLine: false,
        leftType: TitleType.NONE,
        centerType: TitleType.NONE,
        rightType: TitleType.CUSTOM,
        rightCustomView: () => {
          this.rightIcon()
        }
      })
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: this.weatherMainVM.weatherBg
    })
    .clipShape(new PathShape({ commands: this.weatherMainVM.pathCommands }))
    .animation({ duration: 600, curve: Curve.Linear })
    .visibility(this.weatherMainVM.contentVisibility)
    .opacity(1 - fixPercent((this.weatherMainVM.animValue - 0.95) / 0.05))
  }

  @Builder
  rightIcon() {
    Image($r('app.media.ic_add'))
      .width(20)
      .height(20)
      .colorFilter(ColorUtils.translateColor($r('app.color.special_white')))
      .onClick(() => {
        if (this.showCityManagerPage) {
          const itemRectangle = this.showCityManagerPage()
          this.weatherMainVM.showCityManagerPage(itemRectangle)
        }
      })
  }

  @Builder
  weatherContentList() {
    List() {

    }
    .width('100%')
    .height('100%')
  }
}