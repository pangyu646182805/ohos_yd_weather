import { fixPercent } from "../utils/CommonUtils"

@ComponentV2
export struct WeatherObserveUvChart {
  @Param @Require panelWidth: number
  @Param @Require panelHeight: number
  @Param uvIndex: number = 0
  @Param uvIndexMax: number = 0
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

      Text(this.uvIndex.toString())
        .fontSize(18)
        .fontColor($r('app.color.special_white'))
        .fontWeight(FontWeight.Bold)

      Text('uv')
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
    let grad = canvas.createConicGradient(0, centerX, centerY)
    grad.addColorStop(0.125, '#BB10DE')
    grad.addColorStop(0.25, '#BB10DE')
    grad.addColorStop(0.375, '#37CA00')
    grad.addColorStop(0.45, '#37CA00')
    grad.addColorStop(0.625, '#FFDE00')
    grad.addColorStop(0.75, '#FE5B21')
    grad.addColorStop(0.925, '#FC0B23')
    grad.addColorStop(1.0, '#BB10DE')
    canvas.strokeStyle = grad
    canvas.lineWidth = lineWidth
    canvas.lineCap = 'round'
    canvas.stroke()

    const percent = fixPercent(this.uvIndex / this.uvIndexMax)
    const radian = Math.PI * 0.75 + Math.PI * (2.25 - 0.75) * percent
    const x = centerX + radius * Math.cos(radian)
    const y = centerY + radius * Math.sin(radian)
    canvas.beginPath()
    canvas.arc(x, y, 7, 0, Math.PI * 2)
    canvas.globalCompositeOperation = 'destination-out'
    canvas.fill()

    let color = '#37CA00'
    if (percent > 0.8) {
      color = '#BB10DE'
    } else if (percent > 0.6) {
      color = '#FC0B23'
    } else if (percent > 0.4) {
      color = '#FE5B21'
    } else if (percent > 0.2) {
      color = '#FFDE00'
    }

    canvas.beginPath()
    canvas.arc(x, y, lineWidth, 0, Math.PI * 2)
    canvas.globalCompositeOperation = 'source-over'
    canvas.fillStyle = color
    canvas.fill()
  }
}