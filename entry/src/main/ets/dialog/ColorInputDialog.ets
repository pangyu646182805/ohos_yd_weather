import { ColorInputDialogOptions } from "./ColorInputDialogOptions";
import { AppUtil, ObjectUtil, StrUtil } from "@pura/harmony-utils";
import { Logger } from "@hzw/logger";
import { DialogHelper } from "@pura/harmony-dialog";
import { ColorUtils } from "../utils/ColorUtils";

@Builder
export function ColorInputDialogBuilder(options: ColorInputDialogOptions) {
  ColorInputDialog({ options: options })
}

@ComponentV2
export struct ColorInputDialog {
  @Require @Param options: ColorInputDialogOptions
  @Local currentInputList: Array<string> = ['', '', '', '', '', '']
  @Local inputList: Array<string> = []
  @Local contentVisible: boolean = false
  @Local visible: boolean = false
  private currentIndex: number = 0

  aboutToAppear(): void {
    this.options.ref.exit = this.exit
    const size = 10 + 6 + 1 + 1
    for (let index = 0; index < size; index++) {
      if (index < 9) {
        this.inputList.push((index + 1).toString())
      } else if (index == 9) {
        this.inputList.push('A')
      } else if (index == 10) {
        this.inputList.push('B')
      } else if (index == 11) {
        this.inputList.push('C')
      } else if (index == 12) {
        this.inputList.push('D')
      } else if (index == 13) {
        this.inputList.push('E')
      } else if (index == 14) {
        this.inputList.push('F')
      } else if (index == 15) {
        this.inputList.push('space')
      } else if (index == 17) {
        this.inputList.push('del')
      } else {
        this.inputList.push('0')
      }
    }

    this.contentVisible = false
    this.visible = false
    setTimeout(() => {
      this.contentVisible = true
      setTimeout(() => {
        this.visible = true
      }, 200)
    }, 20)
  }

  exit = () => {
    this.visible = false
    setTimeout(() => {
      this.contentVisible = false
      setTimeout(() => {
        if (ObjectUtil.isNull(this.currentInputList.find(e => StrUtil.isEmpty(e)))) {
          const color = ColorUtils.hex2color(this.currentInputList.join(''))
          this.options.completed(color)
        }
        DialogHelper.closeDialog('color_input_dialog')
      }, 200)
    }, 200)
  }

  build() {
    Column() {
      Blank().height(24)
      Row({ space: 4 }) {
        this.buildInputResultItem('#')
        ForEach(this.currentInputList, (item: string) => {
          this.buildInputResultItem(item)
        })
      }

      Blank().height(32)
      Column() {
        Divider()
          .strokeWidth(0.5)
          .color($r('app.color.card_color_06'))

        if (this.visible) {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.inputList, (item: string) => {
              this.buildInputItem(item)
            }, (item: string): string => item)
          }
          .transition(TransitionEffect.move(TransitionEdge.BOTTOM).animation({ curve: Curve.Ease, duration: 200 }))
        }
      }
      .width('100%')
      .height(54 * 6 + 0.5)

      Blank().height(px2vp(AppUtil.getNavigationIndicatorHeight()))
    }
    .width('100%')
    .backgroundColor($r('app.color.bg_color'))
    .borderRadius({ topLeft: 12, topRight: 12 })
    .translate({ y: this.contentVisible ? '0%' : '100%' })
    .animation({ curve: Curve.Linear, duration: 200 })
  }

  @Builder
  buildInputResultItem(input: string) {
    Stack() {
      Text(input)
        .width(42)
        .height(42)
        .textAlign(TextAlign.Center)
        .fontSize(22)
        .fontColor($r('app.color.text_color_01'))
        .fontWeight(FontWeight.Bold)
        .opacity(StrUtil.isEmpty(input) ? 0 : 1)
        .animation({ duration: 200, curve: Curve.Linear })
    }
    .width(42)
    .height(42)
    .backgroundColor($r('app.color.card_color_06'))
    .borderRadius(8)
  }

  @Builder
  buildInputItem(input: string) {
    if (input == 'space') {
      Blank().width('33%').height(54)
    } else {
      Text(input == 'del' ? '删除' : input)
        .width('33%')
        .height(54)
        .textAlign(TextAlign.Center)
        .fontSize(input == 'del' ? 20 : 26)
        .fontColor($r('app.color.text_color_01'))
        .fontWeight(FontWeight.Bold)
        .borderWidth(0.5)
        .borderColor($r('app.color.card_color_06'))
        .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
        .onClick(() => {
          if (input == 'del') {
            let currentIndex = this.currentIndex
            if (currentIndex >= 0) {
              currentIndex--
              if (currentIndex < 0) {
                currentIndex = 0
              }
              this.currentIndex = currentIndex
              this.currentInputList[this.currentIndex] = ''
            }
          } else if (input != 'space') {
            if (this.currentIndex <= this.currentInputList.length - 1) {
              this.currentInputList[this.currentIndex] = input
              this.currentIndex++
            }
            if (ObjectUtil.isNull(this.currentInputList.find(e => StrUtil.isEmpty(e)))) {
              this.exit()
            }
            /*if (_currentIndex <= _currentInputList.length - 1) {
              setState(() {
                _currentInputList[_currentIndex] = input;
                _currentIndex++;
              });
            }
            if (_currentInputList.singleOrNull((e) => e.isEmpty) == null) {
              final color = ColorUtils.getColorFromHex(_currentInputList.join());
              Commons.post((_) {
                setState(() {
                _visible = false;
                Commons.postDelayed(delayMilliseconds: 200, () {
                  SmartDialog.dismiss(tag: "ColorInputDialog").then((_) {
                    widget.completed?.call(color);
                  });
                });
              });
            });
            }*/
          }
        })
    }
  }
}