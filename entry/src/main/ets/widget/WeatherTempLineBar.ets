import { ColorUtils } from "../utils/ColorUtils"
import { PathShape } from "@kit.ArkUI"

@ComponentV2
export struct WeatherTempLineBar {
  @Param @Require barWidth: Length = 0
  @Param @Require barHeight: number = 0
  @Param temp?: number = undefined
  @Param high: number = 0
  @Param low: number = 0
  @Param maxTemp: number = 0
  @Param minTemp: number = 0
  @Local colors: Array<[ResourceColor, number]> = []
  @Local pathCommands: string = ''
  @Local todayTempMarginLeft: number = 0

  build() {
    Stack() {
      Stack({ alignContent: Alignment.Start }) {
        if (this.temp) {
          Circle({ width: this.barHeight, height: this.barHeight })
            .fill($r('app.color.special_white'))
            .margin({ left: this.todayTempMarginLeft })
        }
      }
      .width('100%')
      .height(this.barHeight)
      .linearGradient({
        direction: GradientDirection.Right,
        colors: this.colors
      })
      .clipShape(new PathShape({ commands: this.pathCommands }))
    }
    .width(this.barWidth)
    .height(this.barHeight)
    .backgroundColor(ColorUtils.alpha($r('app.color.special_black'), 0.05))
    .borderRadius(100)
    .clip(true)
    .onSizeChange((_, newValue) => {
      const width = newValue.width
      if (width) {
        const widthValue = width as number
        const tempBarWidth =
          Math.max(((this.high - this.low) / (this.maxTemp - this.minTemp)) * widthValue, this.barHeight)
        const marginLeft = ((this.low - this.minTemp) / (this.maxTemp - this.minTemp)) * widthValue
        let todayTempMarginLeft = 0
        if (this.temp) {
          todayTempMarginLeft = (this.temp - this.minTemp) / (this.maxTemp - this.minTemp) * widthValue
          if (todayTempMarginLeft < 0) {
            todayTempMarginLeft = 0
          }
          if (todayTempMarginLeft > widthValue - this.barHeight) {
            todayTempMarginLeft = widthValue - this.barHeight
          }
          if (todayTempMarginLeft < marginLeft) {
            todayTempMarginLeft = marginLeft
          }
          if (todayTempMarginLeft > marginLeft + tempBarWidth - this.barHeight) {
            todayTempMarginLeft = marginLeft + tempBarWidth - this.barHeight
          }
        }
        const colors: Array<[ResourceColor, number]> = []
        let startStop = 0
        if (this.minTemp <= 0) {
          startStop += (0 - this.minTemp) / (this.maxTemp - this.minTemp)
          colors.push([$r('app.color.color_55dffc'), startStop])
        }
        if (this.maxTemp > 0 && this.minTemp <= 15) {
          startStop += (Math.min(this.maxTemp, 15) - Math.max(this.minTemp, 0)) / (this.maxTemp - this.minTemp)
          colors.push([$r('app.color.color_eade6f'), startStop])
        }
        if (this.maxTemp > 15 && this.minTemp <= 30) {
          startStop +=
          (Math.min(this.maxTemp, 30) - Math.max(this.minTemp, 15)) / (this.maxTemp - this.minTemp)
          colors.push([$r('app.color.color_feba4f'), startStop])
        }
        if (this.maxTemp > 30) {
          colors.push([$r('app.color.color_ff6f55'), 1])
        }
        this.colors = colors
        const barHeightPx = vp2px(this.barHeight)
        const marginLeftPx = vp2px(marginLeft)
        const tempBarWidthPx = vp2px(tempBarWidth)
        const radius = barHeightPx / 2

        this.pathCommands =
          `M ${marginLeftPx + radius} 0 Q ${marginLeftPx} ${radius}, ${marginLeftPx +
            radius} ${barHeightPx} H ${marginLeftPx + tempBarWidthPx -
            radius} Q ${marginLeftPx + tempBarWidthPx} ${radius}, ${marginLeftPx + tempBarWidthPx - radius} 0 Z`
        this.todayTempMarginLeft = todayTempMarginLeft
      }
    })
  }
}