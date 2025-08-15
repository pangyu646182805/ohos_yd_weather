import { fixPercent } from "../utils/CommonUtils"

export class WeatherBgColorSelectorController {
  changeValue = (_: number) => {
  }
}

@ComponentV2
export struct WeatherBgColorSelector {
  @Param weatherBgColorSelectorController?: WeatherBgColorSelectorController = undefined
  @Param @Require selectorWidth: Length = 0
  @Param @Require selectorHeight: number = 0
  @Param @Require max: number
  @Event onValueChanged?: (value: number) => void
  @Param colors: Array<[ResourceColor, number]> = []
  @Local widthValue: number = 0
  @Local currentValue: number = 0

  aboutToAppear(): void {
    if (this.weatherBgColorSelectorController) {
      this.weatherBgColorSelectorController.changeValue = this.changeValue
    }
  }

  changeValue = (value: number) => {
    if (value < 0) {
      this.currentValue = 0
    } else if (value > this.max) {
      this.currentValue = this.max
    } else {
      this.currentValue = value
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Stack()
        .width(this.selectorHeight)
        .height(this.selectorHeight)
        .borderRadius(100)
        .backgroundColor($r('app.color.special_white'))
        .borderWidth(2)
        .borderColor($r('app.color.color_cccccc'))
        .margin({ left: this.marginLeft })
    }
    .width(this.selectorWidth)
    .height(this.selectorHeight)
    .borderRadius(100)
    .linearGradient({
      direction: GradientDirection.Right,
      colors: this.colors
    })
    .gesture(
      GestureGroup(GestureMode.Sequence,
        PanGesture()
          .onActionStart((event) => {
            this.handle(event.fingerList[0].localX)
          })
          .onActionUpdate((event: GestureEvent) => {
            this.handle(event.fingerList[0].localX)
          })
      )
    )
    .onTouch((e) => {
      if (e.type == TouchType.Down) {
        this.handle(e.touches[0].x)
      }
    })
    .onSizeChange((_, newValue) => {
      const width = newValue.width
      if (width) {
        this.widthValue = width as number
      }
    })
  }

  get marginLeft() {
    const percent = this.currentValue / this.max
    return (this.widthValue - this.selectorHeight) * percent
  }

  handle(dx: number) {
    const movePercent = fixPercent(dx / this.widthValue)
    this.currentValue = this.max * movePercent
    if (this.onValueChanged) {
      this.onValueChanged(this.currentValue)
    }
  }
}