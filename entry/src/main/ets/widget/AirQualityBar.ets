import { fixPercent } from "../utils/CommonUtils"

@ComponentV2
export struct AirQualityBar {
  @Param @Require barWidth: Length = 0
  @Param @Require barHeight: number = 0
  @Param aqi: number = 0
  @Local marginStart: number = 0

  build() {
    Stack({ alignContent: Alignment.Start }) {
      Circle({ width: this.barHeight, height: this.barHeight })
        .fill($r('app.color.special_white'))
        .margin({ left: this.marginStart })
    }
    .width(this.barWidth)
    .height(this.barHeight)
    .linearGradient({
      direction: GradientDirection.Right,
      colors: [[$r('app.color.color_00e301'), 0.0], [$r('app.color.color_fdfd01'), 0.2],
        [$r('app.color.color_fd7e01'), 0.4], [$r('app.color.color_f70001'), 0.6], [$r('app.color.color_98004c'), 0.8],
        [$r('app.color.color_7d0023'), 1.0]]
    })
    .borderRadius(100)
    .onSizeChange((_, newValue) => {
      const width = newValue.width
      if (width) {
        const widthValue = width as number
        const percent = fixPercent(this.aqi / 500)
        this.marginStart = (widthValue - this.barHeight) * percent
      }
    })
  }
}