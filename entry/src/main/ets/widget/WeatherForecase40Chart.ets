import { ArrayUtil, DateUtil, DisplayUtil } from "@pura/harmony-utils"
import { WeatherDetailData } from "../entity/WeatherData"
import { getHarmonyDateTimeFormattedString, getTemp } from "../utils/CommonUtils"
import { Edges, Position } from "@ohos.arkui.node"
import { ColorUtils } from "../utils/ColorUtils"
import { JSON } from "@kit.ArkTS"

export class WeatherForecase40ChartController {
  updateCurrentSelectedItem = (_?: WeatherDetailData) => {
  }
}

@ComponentV2
export struct WeatherForecase40Chart {
  @Param initSelectedItem: WeatherDetailData | undefined = undefined
  @Param forecast40: Array<WeatherDetailData> = []
  @Param chartController?: WeatherForecase40ChartController = undefined
  @Event callback?: (currentSelectedItem?: WeatherDetailData) => void = undefined
  @Local currentSelectedItem: WeatherDetailData | undefined = undefined
  @Local currentAxisX: number = 0
  private maxTempData: WeatherDetailData | undefined = undefined
  private minTempData: WeatherDetailData | undefined = undefined
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private chartRect: Edges<number> = {
    left: 32,
    top: 0,
    right: px2vp(DisplayUtil.getWidth()) - 32,
    bottom: 0
  } as Edges<number>

  aboutToAppear(): void {
    if (this.chartController) {
      this.chartController.updateCurrentSelectedItem = (currentSelectedItem) => {
        const length = this.forecast40.length
        const chartRectWidth = this.chartRect.right - this.chartRect.left
        const gaps = 2.5
        const radius = (chartRectWidth - (length - 1) * gaps) / length / 2
        const index = this.forecast40.findIndex(it => it.date == currentSelectedItem?.date)
        this.currentAxisX = 32 + (2 * radius + gaps) * index + radius
        this.currentSelectedItem = currentSelectedItem
        this.draw()
      }
    }
    this.currentSelectedItem = this.initSelectedItem ?? this.forecast40?.[0]
    this.maxTempData = this.forecast40?.reduce((e1, e2) => (e1.high ?? 0) > (e2.high ?? 0) ? e1 : e2)
    this.minTempData = this.forecast40?.reduce((e1, e2) => (e1.low ?? 0) < (e2.low ?? 0) ? e1 : e2)
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Text(this.desc)
          .width(this.descWidth)
          .height(24)
          .textAlign(TextAlign.Center)
          .fontSize(12)
          .fontColor($r('app.color.special_black'))
          .borderRadius(100)
          .backgroundColor($r('app.color.special_white'))
          .margin({ left: this.marginLeft })
      }
      .width('100%')
      .height(38)
      .padding({ left: 32, right: 32 })

      Stack({ alignContent: Alignment.BottomStart }) {
        Column() {
          Text(getTemp(this.maxTempData?.high))
            .width(32)
            .textAlign(TextAlign.Center)
            .fontSize(12)
            .fontColor($r('app.color.special_white'))

          Text(getTemp(this.minTempData?.high))
            .width(32)
            .textAlign(TextAlign.Center)
            .fontSize(12)
            .fontColor($r('app.color.special_white'))
            .margin({ top: 35 })

          Text('水')
            .width(32)
            .textAlign(TextAlign.Center)
            .fontSize(12)
            .fontColor($r('app.color.special_white'))
        }
        .width(32)
        .height('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 18, bottom: 24 })

        Row() {
          this.dateItem(this.forecast40[0].date)
          this.dateItem(this.forecast40[9].date)
          this.dateItem(this.forecast40[19].date)
          this.dateItem(this.forecast40[29].date)
          this.dateItem(this.forecast40[39].date)
        }
        .width('100%')
        .height(28)

        Canvas(this.canvasContext)
          .width('100%')
          .height('100%')
          .onReady(() => {
            this.draw()
          })
      }
      .layoutWeight(1)
      .gesture(
        PanGesture({ direction: PanDirection.Horizontal })
          .onActionStart((event: GestureEvent | undefined) => {
            if (event) {
              this.touch(event.fingerList[0].localX)
            }
          })
          .onActionUpdate((event: GestureEvent | undefined) => {
            if (event) {
              this.touch(event.fingerList[0].localX)
            }
          })
          .onActionEnd((event: GestureEvent | undefined) => {
            if (event) {
              this.touch(event.fingerList[0].localX)
            }
          })
      )
      .onTouch((e) => {
        if (e.type == TouchType.Down) {
          this.touch(e.touches[0].x)
        }
      })
    }
    .layoutWeight(1)
  }

  get descWidth() {
    const desc = this.desc
    const width = px2vp(this.getUIContext().getMeasureUtils().measureText({
      textContent: desc,
      fontSize: 12
    }))
    return width + 2 * 8
  }

  get marginLeft() {
    let marginLeft = 0
    const fixedAxisX = this.currentAxisX - 32 - 16
    const descWidth = this.descWidth
    if (fixedAxisX > descWidth * 0.5) {
      const chartRectWidth = this.chartRect.right - this.chartRect.left
      const remainWidth = chartRectWidth - descWidth
      marginLeft = fixedAxisX - descWidth / 2
      marginLeft = Math.min(marginLeft, remainWidth)
    }
    return marginLeft
  }

  @Builder
  dateItem(date?: string) {
    Text(this.date(date))
      .fontSize(11)
      .fontColor($r('app.color.special_white'))
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
  }

  date(date?: string): string {
    return DateUtil.getFormatDateStr(DateUtil.getFormatDate(getHarmonyDateTimeFormattedString(date)), 'MM/dd')
  }

  touch(x: number) {
    if (ArrayUtil.isEmpty(this.forecast40)) {
      return
    }
    const length = this.forecast40.length
    const chartRectWidth = this.chartRect.right - this.chartRect.left
    let index = Math.round((x - this.chartRect.left) / (chartRectWidth / length))
    if (index < 0) {
      index = 0
    }
    if (index > length - 1) {
      index = length - 1
    }
    const gaps = 2.5
    const radius = (chartRectWidth - (length - 1) * gaps) / length / 2
    this.currentSelectedItem = this.forecast40[index]
    this.currentAxisX = 32 + (2 * radius + gaps) * index + radius
    this.draw()
    if (this.callback) {
      this.callback(this.currentSelectedItem)
    }
  }

  draw() {
    const canvas = this.canvasContext
    if (!canvas) {
      return
    }
    canvas.clearRect(0, 0, canvas.width, canvas.height)
    const hGap = 32
    const bGap = 28
    const newRect = {
      left: hGap,
      top: 0,
      right: canvas.width - hGap,
      bottom: canvas.height - bGap
    } as Edges<number>
    const length = this.forecast40?.length ?? 0
    const gaps = 2.5
    const radius = (newRect.right - newRect.left - (length - 1) * gaps) / length / 2
    const lineRect = {
      left: newRect.left,
      top: newRect.top + 24,
      right: newRect.right,
      bottom: newRect.bottom - 48
    } as Edges<number>
    this.drawDashLine(canvas, lineRect, lineRect.top, radius)
    this.drawDashLine(canvas, lineRect, lineRect.top + (lineRect.bottom - lineRect.top) / 2, radius)
    this.drawDashLine(canvas, lineRect, lineRect.bottom, radius)

    let currentPoint = {} as Position
    const linePath = new Path2D()
    this.forecast40?.forEach((e, index) => {
      const isSelected = e.date == this.currentSelectedItem?.date
      const isRain = this.isRain(e)
      const circleRect = {
        left: newRect.left + (2 * radius + gaps) * index,
        top: newRect.bottom - 2 * radius,
        right: newRect.left + (2 * radius + gaps) * index + 2 * radius,
        bottom: newRect.bottom
      } as Edges<number>
      this.drawLine(canvas, circleRect, newRect.top, radius, isSelected)
      this.drawCircle(canvas, circleRect, radius, isRain)
      const point = this.drawWeatherLine(linePath, e, index, circleRect, lineRect, isSelected)
      if (point) {
        currentPoint = point
      }
    })
    canvas.lineWidth = 2
    canvas.strokeStyle = ColorUtils.alpha($r('app.color.color_0da8ff'), 1)
    canvas.stroke(linePath)

    canvas.beginPath()
    canvas.shadowBlur = 4
    canvas.shadowColor = ColorUtils.alphaStr($r('app.color.color_0da8ff'), 0.4)
    canvas.fillStyle = ColorUtils.alpha($r('app.color.special_white'), 1)
    canvas.arc(currentPoint.x, currentPoint.y, 6, 0, Math.PI * 2)
    console.log('currentPoint = ' + JSON.stringify(currentPoint))
    canvas.fill()

    canvas.beginPath()
    canvas.fillStyle = ColorUtils.alpha($r('app.color.color_0da8ff'), 1)
    canvas.arc(currentPoint.x, currentPoint.y, 4, 0, Math.PI * 2)
    canvas.fill()
  }

  drawWeatherLine(linePath: Path2D, data: WeatherDetailData, index: number,
    circleRect: Edges<number>, lineRect: Edges<number>, isSelected: boolean): Position | undefined {
    const high = this.maxTempData?.high ?? 0
    const low = this.minTempData?.high ?? 0
    const currentTemp = data.high ?? 0
    const percent = (currentTemp - low) / (high - low)
    const centerX = circleRect.left + (circleRect.right - circleRect.left) / 2
    const point = { x: centerX, y: lineRect.bottom - (lineRect.bottom - lineRect.top) * percent } as Position
    if (index == 0) {
      linePath.moveTo(point.x, point.y)
    } else {
      linePath.lineTo(point.x, point.y)
    }
    if (isSelected) {
      return point
    }
    return undefined
  }

  drawCircle(canvas: CanvasRenderingContext2D, circleRect: Edges<number>, radius: number, isRain: boolean) {
    const centerX = circleRect.left + (circleRect.right - circleRect.left) / 2
    const centerY = circleRect.top + (circleRect.bottom - circleRect.top) / 2
    canvas.beginPath()
    canvas.arc(centerX, centerY, radius, 0, Math.PI * 2)
    canvas.fillStyle =
      isRain ? ColorUtils.alpha($r('app.color.color_0da8ff'), 1) : ColorUtils.alpha($r('app.color.special_white'), 1)
    canvas.fill()
  }

  drawLine(canvas: CanvasRenderingContext2D, circleRect: Edges<number>, lineY: number, radius: number,
    isSelected: boolean) {
    const x = circleRect.left + (circleRect.right - circleRect.left) / 2
    canvas.beginPath()
    canvas.moveTo(x, circleRect.bottom - radius)
    canvas.lineTo(x, lineY)
    canvas.lineWidth = isSelected ? 2 : 0.5
    canvas.strokeStyle = isSelected ? ColorUtils.alpha($r('app.color.color_0da8ff'), 1) :
    ColorUtils.alpha($r('app.color.special_white'), 0.4)
    canvas.stroke()
  }

  drawDashLine(canvas: CanvasRenderingContext2D, lineRect: Edges<number>, lineY: number, radius: number) {
    const dashWidth = 2
    const spaceWidth = 8
    let startX = lineRect.left + radius
    canvas.lineWidth = 0.8
    canvas.strokeStyle = ColorUtils.alpha($r('app.color.special_white'), 0.8)
    while (startX < lineRect.right) {
      let endX = startX + dashWidth
      if (endX > lineRect.right - radius) {
        endX = lineRect.right - radius
      }
      canvas.beginPath()
      canvas.moveTo(startX, lineY)
      canvas.lineTo(endX, lineY)
      canvas.stroke()
      startX += dashWidth + spaceWidth
    }
  }

  get desc() {
    const date = DateUtil.getFormatDate(getHarmonyDateTimeFormattedString(this.currentSelectedItem?.date))
    return `${DateUtil.getFormatDateStr(date,
      'MM月dd日')} ${this.currentSelectedItem?.day?.wthr} ${getTemp(this.currentSelectedItem?.low)}~${getTemp(this.currentSelectedItem?.high)}`
  }

  isRain(data: WeatherDetailData): boolean {
    const weatherType = data.day?.third_type
    return weatherType == 'LIGHT_RAIN' || weatherType == 'MODERATE_RAIN' || weatherType == 'HEAVY_RAIN' ||
      weatherType == 'STORM_RAIN'
  }
}