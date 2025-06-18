import { BaseSheetOptions, DialogHelper } from "@pura/harmony-dialog"
import { AppUtil } from "@pura/harmony-utils"
import { ColorUtils } from "../utils/ColorUtils"
import { OpacityLayout } from "../widget/OpacityLayout"

@Builder
export function AirQualityQueryDialogBuilder(options: BaseSheetOptions) {
  AirQualityQueryDialog({ options: options })
}

@ComponentV2
export struct AirQualityQueryDialog {
  @Require @Param options: BaseSheetOptions

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Text('中国国家环境保护部\n空气质量指数及相关信息')
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(20)
          .fontColor($r('app.color.black'))
          .fontWeight(FontWeight.Bold)
          .margin({ top: 12 })

        OpacityLayout({
          child: () => {
            this.closeIcon()
          },
          onTap: () => {
            DialogHelper.closeBindSheet('air_quality_query_dialog')
          }
        })
      }
      .width('100%')

      Row() {
        Stack()
          .width(16)
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [[$r('app.color.color_00e301'), 0.0], [$r('app.color.color_fdfd01'), 0.2],
              [$r('app.color.color_fd7e01'), 0.4], [$r('app.color.color_f70001'), 0.6],
              [$r('app.color.color_98004c'), 0.8],
              [$r('app.color.color_7d0023'), 1.0]]
          })
          .borderRadius(100)
        Blank().width(12)
        Column() {
          this.content('优：0-50', '空气质量令人满意，基本无空气污染，各类人群可正常活动')
          this.content('良：51-100', '空气质量可接受，但某些污染物可能对极少数异常敏感人群健康有较弱影响')
          this.content('轻度污染：101-150', '儿童、老年人及心脏病、呼吸系统疾病患者应减少长时间、高强度的户外锻炼')
          this.content('中度污染：151-200',
            '儿童、老年人及心脏病、呼吸系统疾病患者应减少长时间、高强度的户外锻炼，一般人群适量减少户外运动')
          this.content('重度污染：201-300',
            '儿童、老年人和心脏病、肺病患者应停留在室内，停止户外运动，一般人群减少户外运动', FlexAlign.Center)
          this.content('严重污染：大于300', '儿童、老年人和病人应当留在室内，避免体力消耗，一般人群应避免户外活动',
            FlexAlign.End)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
      .layoutWeight(1)
      .margin({ top: 24, bottom: px2vp(AppUtil.getNavigationIndicatorHeight()) + 64 })
    }
    .width('100%')
    .backgroundColor($r('app.color.bg_color'))
    .borderRadius({ topLeft: 24, topRight: 24 })
  }

  @Builder
  closeIcon() {
    Stack() {
      Image($r('app.media.ic_close_icon1'))
        .width(22)
        .height(22)
        .colorFilter(ColorUtils.translateColor($r('app.color.black')))
        .draggable(false)
    }
    .padding(16)
  }

  @Builder
  content(title: string, content: string, justifyContent: FlexAlign = FlexAlign.Start) {
    Column() {
      Text(title)
        .fontSize(18)
        .fontColor($r('app.color.black'))
        .fontWeight(FontWeight.Bold)
      Blank().height(2)
      Text(content)
        .fontSize(15)
        .fontColor($r('app.color.text_color_01'))
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(justifyContent)
    .layoutWeight(1)
  }
}