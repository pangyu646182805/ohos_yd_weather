import { ColorUtils } from "../utils/ColorUtils"

@ComponentV2
export struct WeatherObservePressureChart {
  @Param @Require panelWidth: number
  @Param @Require panelHeight: number
  @Param pressure: string = ''
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

      Image($r('app.media.ic_arrow_down'))
        .width(20)
        .height(20)
        .colorFilter(ColorUtils.translateColor($r('app.color.special_white')))

      Text('hPa')
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
    canvas.strokeStyle = ColorUtils.alpha($r('app.color.special_white'), 1)
    canvas.stroke()

    canvas.save()
    canvas.translate(centerX, centerY)
    const pressure = parseInt(this.pressure.replaceAll('hPa', ''))
    let max = 0
    let min = 0
    if (pressure < 100) {
      min = 0
      max = 200
    } else if (pressure < 1000) {
      min = pressure - pressure % 100
      max = min + 300
    } else {
      min = pressure - pressure % 1000
      max = min + 300
    }
    const percent = (pressure - min) / (max - min)
    canvas.rotate(Math.PI * 0.75 + Math.PI * 1.5 * percent)
    canvas.beginPath()
    canvas.moveTo(centerX - 4, 0)
    canvas.lineTo(centerX - 4, 0)
    canvas.lineWidth = 6
    canvas.lineCap = 'square'
    canvas.globalCompositeOperation = 'destination-out'
    canvas.stroke()

    canvas.beginPath()
    canvas.moveTo(centerX - 4 + 4, 0)
    canvas.lineTo(centerX - 4 - 4, 0)
    canvas.lineWidth = 2.5
    canvas.lineCap = 'round'
    canvas.globalCompositeOperation = 'source-over'
    canvas.strokeStyle = ColorUtils.alpha($r('app.color.special_white'), 1)
    canvas.stroke()

    canvas.restore()
  }
}