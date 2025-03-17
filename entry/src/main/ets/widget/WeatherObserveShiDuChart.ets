import { StrUtil } from "@pura/harmony-utils"
import { ColorUtils } from "../utils/ColorUtils"
import { fixPercent } from "../utils/CommonUtils"

@ComponentV2
export struct WeatherObserveShiDuChart {
  @Param @Require panelWidth: number
  @Param @Require panelHeight: number
  @Param shiDu: string = ''
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  build() {
    Stack() {
      Canvas(this.canvasContext)
        .width(this.panelWidth)
        .height(this.panelHeight)
        .onReady(() => {
          this.draw()
        })

      Image($r('app.media.ic_water_icon'))
        .width(16)
        .height(16)
        .colorFilter(ColorUtils.translateColor($r('app.color.special_white')))

      Text(this.shiDuDesc)
        .width(this.panelWidth)
        .height(this.panelHeight)
        .textAlign(TextAlign.Center)
        .align(Alignment.Bottom)
        .padding({ bottom: 5 })
        .fontSize(11)
        .fontColor($r('app.color.special_white'))
    }
    .width(this.panelWidth)
    .height(this.panelHeight)
  }

  draw() {
    const canvas = this.canvasContext
    if (!canvas) {
      return
    }
    const lineWidth = 4
    const centerX = this.panelWidth / 2
    const centerY = this.panelHeight / 2
    const radius = this.panelWidth / 2 - lineWidth
    canvas.beginPath()
    canvas.arc(centerX, centerY, radius, Math.PI * 0.75, Math.PI * 0.25)
    canvas.lineWidth = lineWidth
    canvas.lineCap = 'round'
    canvas.strokeStyle = ColorUtils.alpha($r('app.color.special_white'), 0.4)
    canvas.stroke()

    const shiDuPercent = fixPercent(this.shiDuValue / 100)
    canvas.beginPath()
    canvas.arc(centerX, centerY, radius, Math.PI * 0.75, Math.PI * 0.75 + Math.PI * 1.5 * shiDuPercent)
    canvas.strokeStyle = ColorUtils.alpha($r('app.color.special_white'), 1)
    canvas.stroke()
  }

  get shiDuValue() {
    if (StrUtil.isEmpty(this.shiDu)) {
      return 0
    }
    if (this.shiDu.includes('%')) {
      return parseInt(this.shiDu.replaceAll('%', ''))
    }
    return 0
  }

  get shiDuDesc() {
    const shiDuValue = this.shiDuValue
    if (shiDuValue < 40) {
      return "干燥"
    }
    if (shiDuValue < 70) {
      return "舒适"
    }
    return "潮湿"
  }
}