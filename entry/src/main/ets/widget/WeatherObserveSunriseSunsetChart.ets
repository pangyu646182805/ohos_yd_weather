import { Position } from "@ohos.arkui.node"
import { DateUtil } from "@pura/harmony-utils"
import { ColorUtils } from "../utils/ColorUtils"
import { fixPercent, getHarmonyDateTimeFormattedString } from "../utils/CommonUtils"

@ComponentV2
export struct WeatherObserveSunriseSunsetChart {
  @Param @Require panelWidth: number
  @Param @Require panelHeight: number
  @Param date: string = ''
  @Param sunrise: string = ''
  @Param sunset: string = ''
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  build() {
    Canvas(this.canvasContext)
      .width(this.panelWidth)
      .height(this.panelHeight)
      .onReady(() => {
        this.draw()
      })
  }

  draw() {
    const canvas = this.canvasContext
    if (!canvas) {
      return
    }
    const centerX = this.panelWidth / 2
    const lineWidth = 4
    const left = lineWidth
    const top = lineWidth
    const right = this.panelWidth - lineWidth
    const bottom = this.panelHeight - lineWidth
    const width = right - left
    const height = bottom - top
    canvas.save()
    const lineY = height * 0.8
    canvas.moveTo(0, lineY)
    canvas.lineTo(right, lineY)
    canvas.lineWidth = 0.5
    canvas.strokeStyle = ColorUtils.alpha($r('app.color.special_white'), 0.4)
    canvas.stroke()
    canvas.restore()

    canvas.save()
    canvas.rect(0, 0, this.panelWidth, lineY)
    canvas.clip()
    canvas.beginPath()
    canvas.lineWidth = lineWidth
    canvas.moveTo(left, bottom)
    const p1 = { x: left + width / 4 + width / 4 / 2, y: bottom } as Position
    const p2 = { x: left + width / 4 - width / 4 / 2, y: top } as Position
    canvas.bezierCurveTo(p1.x, p1.y, p2.x, p2.y, centerX, top)
    canvas.strokeStyle = ColorUtils.alpha($r('app.color.special_white'), 1)
    canvas.lineCap = 'round'
    canvas.stroke()

    const p3 = { x: right - width / 4 + width / 4 / 2, y: top } as Position
    const p4 = { x: right - width / 4 - width / 4 / 2, y: bottom } as Position
    canvas.bezierCurveTo(p3.x, p3.y, p4.x, p4.y, right, bottom)
    canvas.stroke()
    canvas.restore()

    canvas.save()
    canvas.rect(0, lineY, this.panelWidth, this.panelHeight)
    canvas.clip()
    canvas.beginPath()
    canvas.lineWidth = lineWidth
    canvas.moveTo(left, bottom)
    canvas.bezierCurveTo(p1.x, p1.y, p2.x, p2.y, centerX, top)
    canvas.strokeStyle = ColorUtils.alpha($r('app.color.special_white'), 0.4)
    canvas.lineCap = 'round'
    canvas.stroke()

    canvas.bezierCurveTo(p3.x, p3.y, p4.x, p4.y, right, bottom)
    canvas.stroke()
    canvas.clip()
    canvas.restore()

    const currentMill = DateUtil.getToday().getTime()
    const sunriseSunsetMill = this.sunriseSunsetMill
    const sunriseMill = sunriseSunsetMill[0]
    const sunsetMill = sunriseSunsetMill[1]
    let percent = 0
    if (currentMill < sunriseMill) {
      const dateTime = getHarmonyDateTimeFormattedString(`${this.date}0000`)
      const mill = DateUtil.getFormatDate(dateTime).getTime()
      percent = (currentMill - mill) / (sunriseMill - mill) * 0.2
    } else if (currentMill < sunsetMill) {
      percent = 0.2 + (currentMill - sunriseMill) / (sunsetMill - sunriseMill) * 0.6
    } else {
      const dateTime = getHarmonyDateTimeFormattedString(`${this.date}2400`)
      const mill = DateUtil.getFormatDate(dateTime).getTime()
      percent = 0.2 + 0.6 + (currentMill - sunsetMill) / (mill - sunsetMill) * 0.2
    }
    percent = fixPercent(percent)

    let h: Position
    if (percent < 0.5) {
      h = this.getBezier3Point({ x: left, y: bottom }, p1, p2, { x: centerX, y: lineWidth }, percent / 0.5)
    } else {
      h = this.getBezier3Point({ x: centerX, y: lineWidth }, p3, p4, { x: right, y: bottom }, (percent - 0.5) / 0.5)
    }
    canvas.beginPath()
    canvas.arc(h.x, h.y, 7, 0, Math.PI * 2)
    canvas.globalCompositeOperation = 'destination-out'
    canvas.fill()

    canvas.beginPath()
    canvas.arc(h.x, h.y, 4, 0, Math.PI * 2)
    canvas.globalCompositeOperation = 'source-over'
    canvas.fillStyle = ColorUtils.alpha($r('app.color.special_white'), percent < 0.2 || percent > 0.8 ? 0.4 : 1)
    canvas.fill()
  }

  get sunriseSunsetMill() {
    const sunriseDateTime =
      getHarmonyDateTimeFormattedString(`${this.date}${this.sunrise}`.replaceAll(':', ''))
    const sunsetDateTime =
      getHarmonyDateTimeFormattedString(`${this.date}${this.sunset}`.replaceAll(':', ''))
    const sunriseMill = DateUtil.getFormatDate(sunriseDateTime).getTime()
    const sunsetMill = DateUtil.getFormatDate(sunsetDateTime).getTime()
    return [sunriseMill, sunsetMill]
  }

  getBezier3Point(p1: Position, cp1: Position, cp2: Position, p2: Position, t: number): Position {
    const a = this.lerp(p1, cp1, t)
    const b = this.lerp(cp1, cp2, t)
    const c = this.lerp(cp2, p2, t)

    const e = this.lerp(a, b, t)
    const f = this.lerp(b, c, t)
    return this.lerp(e, f, t)
  }

  lerp(p1: Position, p2: Position, t: number): Position {
    return {
      x: (1 - t) * p1.x + t * p2.x,
      y: (1 - t) * p1.y + t * p2.y,
    }
  }
}