import { ColorUtils } from "../utils/ColorUtils"

@ComponentV2
export struct WeatherObserveWdChart {
  @Param @Require panelWidth: number
  @Param @Require panelHeight: number
  @Param wd: string = ''
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
      Stack() {
        Image($r('app.media.ic_wd_icon'))
          .width(12)
          .height(12)
          .colorFilter(ColorUtils.translateColor($r('app.color.special_white')))
      }
      .width(24)
      .height(24)
      .borderRadius(100)
      .backgroundColor($r('app.color.color_0da8ff'))

      Text('北')
        .width(this.panelWidth)
        .height(this.panelHeight)
        .textAlign(TextAlign.Center)
        .align(Alignment.Top)
        .padding({ top: 8 })
        .fontSize(11)
        .fontColor($r('app.color.special_white'))
        .fontWeight(FontWeight.Bold)
      Text('南')
        .width(this.panelWidth)
        .height(this.panelHeight)
        .textAlign(TextAlign.Center)
        .align(Alignment.Bottom)
        .padding({ bottom: 8 })
        .fontSize(11)
        .fontColor($r('app.color.special_white'))
        .fontWeight(FontWeight.Bold)
      Text('西')
        .width(this.panelWidth)
        .height(this.panelHeight)
        .textAlign(TextAlign.Start)
        .align(Alignment.Center)
        .padding({ left: 8 })
        .fontSize(11)
        .fontColor($r('app.color.special_white'))
        .fontWeight(FontWeight.Bold)
      Text('东')
        .width(this.panelWidth)
        .height(this.panelHeight)
        .textAlign(TextAlign.End)
        .align(Alignment.Center)
        .padding({ right: 8 })
        .fontSize(11)
        .fontColor($r('app.color.special_white'))
        .fontWeight(FontWeight.Bold)
    }
    .width(this.panelWidth)
    .height(this.panelHeight)
  }

  draw() {
    const canvas = this.canvasContext
    if (!canvas) {
      return
    }
    const centerX = this.panelWidth / 2
    const centerY = this.panelHeight / 2
    const length = 6
    canvas.lineWidth = 1
    canvas.save()
    canvas.translate(centerX, centerY)
    for (let index = 0; index < 72; index++) {
      canvas.beginPath()
      canvas.moveTo(centerX - length, 0)
      canvas.lineTo(centerX, 0)
      canvas.strokeStyle = ColorUtils.alpha($r('app.color.special_white'),
        index == 0 || index == 18 || index == 36 || index == 54 ? 1 : 0.4)
      canvas.stroke()
      canvas.rotate(2 * Math.PI / 72)
    }
    canvas.restore()

    canvas.save()
    canvas.translate(centerX, centerY)
    const wd = this.wd
    if (wd == "南风") {
      canvas.rotate(Math.PI * 0.5)
    } else if (wd == "西风") {
      canvas.rotate(Math.PI)
    } else if (wd == "北风") {
      canvas.rotate(Math.PI * 1.5)
    } else if (wd == "东南风") {
      canvas.rotate(Math.PI * 0.25)
    } else if (wd == "西南风") {
      canvas.rotate(Math.PI * 0.75)
    } else if (wd == "西北风") {
      canvas.rotate(Math.PI * 1.25)
    } else if (wd == "东北风") {
      canvas.rotate(Math.PI * 1.75)
    }
    canvas.beginPath()
    canvas.moveTo(centerX - length, -0.8)
    canvas.lineTo(-centerX + length + 3, -0.8)
    canvas.lineTo(-centerX + length + 3 + 3, -0.8 - 3)
    canvas.lineTo(-centerX, 0)
    canvas.lineTo(-centerX + length + 3 + 3, 0.8 + 3)
    canvas.lineTo(-centerX + length + 3, 0.8)
    canvas.lineTo(centerX - length, 0.8)
    canvas.fillStyle = ColorUtils.alpha($r('app.color.color_0da8ff'), 1)
    canvas.fill()

    canvas.beginPath()
    canvas.arc(centerX - length, 0, 4, 0, Math.PI * 2)
    canvas.fillStyle = ColorUtils.alpha($r('app.color.color_0da8ff'), 1)
    canvas.fill()

    canvas.beginPath()
    canvas.arc(centerX - length, 0, 2, 0, Math.PI * 2)
    canvas.fillStyle = ColorUtils.alpha($r('app.color.special_white'), 1)
    canvas.fill()
    canvas.restore()
  }
}