import { DateUtil } from "@pura/harmony-utils"
import { WeatherDetailData } from "../entity/WeatherData"
import { ColorUtils } from "../utils/ColorUtils"
import { getHarmonyDateTimeFormattedString, getTemp, isBefore } from "../utils/CommonUtils"
import { Position } from "@ohos.arkui.node"

@ComponentV2
export struct WeatherDailyTempPanel {
  @Param @Require panelWidth: number
  @Param @Require panelHeight: number
  @Param preData?: WeatherDetailData = undefined
  @Param data?: WeatherDetailData = undefined
  @Param nextData?: WeatherDetailData = undefined
  @Param maxTemp: number = 0
  @Param minTemp: number = 0
  private topAndBottomGaps: number = 32
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
    this.drawStartArea(canvas, true)
    this.drawStartArea(canvas, false)
    this.drawCenterArea(canvas, true)
    this.drawCenterArea(canvas, false)
    this.drawEndArea(canvas, true)
    this.drawEndArea(canvas, false)
  }

  drawStartArea(canvas: CanvasRenderingContext2D, isHigh: boolean) {
    if (!this.preData && this.data && this.nextData) {
      const centerX = this.panelWidth / 2
      const tempYAxis = this.calTempYAxis((isHigh ? this.data.high : this.data.low) ?? 0)
      const nextTempYAxis = this.calTempYAxis((isHigh ? this.nextData.high : this.nextData.low) ?? 0)
      canvas.lineWidth = 1
      canvas.beginPath()
      canvas.moveTo(centerX, tempYAxis)
      canvas.quadraticCurveTo(centerX + this.panelWidth / 4, (nextTempYAxis - tempYAxis) / 4 + tempYAxis,
        this.panelWidth, (nextTempYAxis - tempYAxis) / 2 + tempYAxis)
      canvas.strokeStyle = ColorUtils.alpha($r('app.color.special_white'), 0.3)
      canvas.stroke()

      canvas.beginPath()
      canvas.arc(centerX, tempYAxis, 2.5, 0, Math.PI * 2)
      canvas.fillStyle = ColorUtils.alpha($r('app.color.special_white'), 0.3)
      canvas.fill()

      this.drawTemp(canvas, getTemp(isHigh ? this.data.high : this.data.low),
        ColorUtils.alpha($r('app.color.special_white'), 0.3), tempYAxis, isHigh)
    }
  }

  drawCenterArea(canvas: CanvasRenderingContext2D, isHigh: boolean) {
    if (this.preData && this.data && this.nextData) {
      const centerX = this.panelWidth / 2
      const dateIsToday = DateUtil.isToday(getHarmonyDateTimeFormattedString(this.data.date))
      const dateIsBefore = isBefore(this.data.date)
      const tempYAxis = this.calTempYAxis((isHigh ? this.data.high : this.data.low) ?? 0)
      const preTempYAxis = this.calTempYAxis((isHigh ? this.preData.high : this.preData.low) ?? 0)
      const nextTempYAxis = this.calTempYAxis((isHigh ? this.nextData.high : this.nextData.low) ?? 0)
      const moveToY = (preTempYAxis - tempYAxis) / 2 + tempYAxis
      const p1 = { x: this.panelWidth / 4, y: (moveToY - tempYAxis) / 2 + tempYAxis } as Position
      const p2 =
        { x: this.panelWidth - this.panelWidth / 4, y: (nextTempYAxis - tempYAxis) / 4 + tempYAxis } as Position
      if (dateIsToday || dateIsBefore) {
        canvas.save()
        canvas.rect(this.panelWidth / 2, 0, this.panelWidth / 2, this.panelHeight)
        canvas.clip()
        this.drawCenterLine(canvas, moveToY, p1, p2, tempYAxis, nextTempYAxis,
          ColorUtils.alpha($r('app.color.special_white'), 1))
        canvas.restore()

        canvas.save()
        canvas.rect(0, 0, this.panelWidth / 2, this.panelHeight)
        canvas.clip()
        this.drawCenterLine(canvas, moveToY, p1, p2, tempYAxis, nextTempYAxis,
          ColorUtils.alpha($r('app.color.special_white'), 0.3))
        canvas.restore()
      } else {
        this.drawCenterLine(canvas, moveToY, p1, p2, tempYAxis, nextTempYAxis,
          ColorUtils.alpha($r('app.color.special_white'), 1))
      }

      canvas.beginPath()
      canvas.arc(centerX, (p2.y - p1.y) / 2 + p1.y, 2.5, 0, Math.PI * 2)
      canvas.fillStyle = ColorUtils.alpha($r('app.color.special_white'), dateIsBefore ? 0.3 : 1)
      canvas.fill()

      this.drawTemp(canvas, getTemp(isHigh ? this.data.high : this.data.low),
        ColorUtils.alpha($r('app.color.special_white'), dateIsBefore ? 0.3 : 1), (p2.y - p1.y) / 2 + p1.y, isHigh)
    }
  }

  drawCenterLine(canvas: CanvasRenderingContext2D, moveToY: number, p1: Position, p2: Position,
    tempYAxis: number, nextTempYAxis: number, lineColor: number) {
    if (this.preData && this.data && this.nextData) {
      canvas.lineWidth = 1
      canvas.beginPath()
      canvas.moveTo(0, moveToY)
      canvas.bezierCurveTo(p1.x, p2.y, p2.x, p2.y, this.panelWidth, (nextTempYAxis - tempYAxis) / 2 + tempYAxis)
      canvas.strokeStyle = lineColor
      canvas.stroke()
    }
  }

  drawEndArea(canvas: CanvasRenderingContext2D, isHigh: boolean) {
    if (this.preData && this.data && !this.nextData) {
      const centerX = this.panelWidth / 2
      const tempYAxis = this.calTempYAxis((isHigh ? this.data.high : this.data.low) ?? 0)
      const preTempYAxis = this.calTempYAxis((isHigh ? this.preData.high : this.preData.low) ?? 0)
      canvas.lineWidth = 1
      canvas.beginPath()
      canvas.moveTo(centerX, tempYAxis)
      canvas.quadraticCurveTo(centerX - this.panelWidth / 4, (preTempYAxis - tempYAxis) / 4 + tempYAxis,
        0, (preTempYAxis - tempYAxis) / 2 + tempYAxis)
      canvas.strokeStyle = ColorUtils.alpha($r('app.color.special_white'), 1)
      canvas.stroke()

      canvas.beginPath()
      canvas.arc(centerX, tempYAxis, 2.5, 0, Math.PI * 2)
      canvas.fillStyle = ColorUtils.alpha($r('app.color.special_white'), 1)
      canvas.fill()

      this.drawTemp(canvas, getTemp(isHigh ? this.data.high : this.data.low),
        ColorUtils.alpha($r('app.color.special_white'), 1), tempYAxis, isHigh)
    }
  }

  drawTemp(canvas: CanvasRenderingContext2D, text: string, textColor: number, tempYAxis: number, isHigh: boolean) {
    const centerX = this.panelWidth / 2
    canvas.textAlign = 'center'
    canvas.font = '13vp sans-serif'
    canvas.fillStyle = textColor
    canvas.textBaseline = isHigh ? 'bottom' : 'top'
    canvas.fillText(text, centerX, isHigh ? tempYAxis - 4 : tempYAxis + 4)
  }

  calTempYAxis(temp: number): number {
    const diff = this.maxTemp - temp
    const diffTemp = this.maxTemp - this.minTemp
    const percent = diff / diffTemp
    return (this.panelHeight - 2 * this.topAndBottomGaps) * percent + this.topAndBottomGaps
  }
}