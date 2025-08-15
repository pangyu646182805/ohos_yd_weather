import { Route, TranslateAnimationOptions, ZRouter } from "@hzw/zrouter";
import { AnimationHelper, DialogHelper } from "@pura/harmony-dialog";
import { AppUtil, DisplayUtil } from "@pura/harmony-utils";
import { Constants } from "../constants/Constants";
import { RouterConstants } from "../constants/RouterConstants";
import { ColorInputDialogBuilder } from "../dialog/ColorInputDialog";
import { ColorInputDialogOptions } from "../dialog/ColorInputDialogOptions";
import { PopupExitController } from "../dialog/PopupExitController";
import { WeatherBgModel } from "../entity/WeatherBgModel";
import { AppRuntimeData } from "../utils/AppRuntimeData";
import { ColorUtils } from "../utils/ColorUtils";
import { isDark, refreshStatusBar } from "../utils/CommonUtils";
import { HSVColor } from "../utils/HSVColor";
import { WeatherDataUtils } from "../utils/WeatherDataUtils";
import WeatherBgEditViewModel from "../viewmodel/WeatherBgEditViewModel";
import { OpacityLayout } from "../widget/OpacityLayout";
import { WeatherBgColorSelector, WeatherBgColorSelectorController } from "../widget/WeatherBgColorSelector";
import { WeatherCitySnapshot } from "../widget/WeatherCitySnapshot";

@Route({ name: RouterConstants.WEATHER_BG_EDIT_PAGE })
@ComponentV2
export struct WeatherBgEditPage {
  @Local weatherType: string =
    ZRouter.getInstance().getParamByKey<string | undefined>(Constants.WEATHER_TYPE) ?? ''
  @Local weatherBgModel?: WeatherBgModel =
    ZRouter.getInstance().getParamByKey<WeatherBgModel>(Constants.WEATHER_BG_MODEL)
  @Local isEdit: boolean = ZRouter.getInstance().getParamByKey<boolean>(Constants.IS_EDIT) ?? false
  @Local isPreviewMode: boolean = ZRouter.getInstance().getParamByKey<boolean>(Constants.IS_PREVIEW_MODE) ?? false
  @Local weatherBgEditVM: WeatherBgEditViewModel = new WeatherBgEditViewModel()
  private hColorSelectorController: WeatherBgColorSelectorController = new WeatherBgColorSelectorController()
  private sColorSelectorController: WeatherBgColorSelectorController = new WeatherBgColorSelectorController()
  private vColorSelectorController: WeatherBgColorSelectorController = new WeatherBgColorSelectorController()
  private popupExitRef = new PopupExitController()

  aboutToAppear(): void {
    this.weatherBgEditVM.colors = this.weatherBgModel?.colors?.map(e => e[0]) ?? []
    this.weatherBgEditVM.nightColors = this.weatherBgModel?.nightColors?.map(e => e[0]) ?? []
    this.weatherBgEditVM.hsvColors = this.weatherBgEditVM.colors.map(e => HSVColor.fromColor(e as Resource))
    this.weatherBgEditVM.hsvNightColors = this.weatherBgEditVM.nightColors.map(e => HSVColor.fromColor(e as Resource))
    setTimeout(() => {
      this.changeColorSelectorValue()
    }, 20)
    if (!this.isPreviewMode) {
      setTimeout(() => {
        this.weatherBgEditVM.isShowBubbleBox = true
      }, 400)
    }
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          OpacityLayout({
            child: () => {
              this.dayNightButton(true)
            },
            onTap: () => {
              if (this.weatherBgEditVM.isNight) {
                this.weatherBgEditVM.isStartSelected = true
                this.weatherBgEditVM.isNight = false
                this.changeColorSelectorValue()
              }
            }
          })
            .layoutWeight(1)
            .padding({ top: 12, bottom: 12 })
          OpacityLayout({
            child: () => {
              this.dayNightButton(false)
            },
            onTap: () => {
              if (!this.weatherBgEditVM.isNight) {
                this.weatherBgEditVM.isStartSelected = true
                this.weatherBgEditVM.isNight = true
                this.changeColorSelectorValue()
              }
            }
          })
            .layoutWeight(1)
            .padding({ top: 12, bottom: 12 })
        }
        .width('100%')
        .height(64)
        .padding({ left: 32, right: 32 })
        .margin({ top: px2vp(AppUtil.getStatusBarHeight()) })

        Stack() {
          WeatherCitySnapshot({
            cityData: AppRuntimeData.getInstance().currentCityData,
            data: this.data,
            scaleParams: {
              x: this.weatherBgEditVM.weatherCitySnapshotScale,
              y: this.weatherBgEditVM.weatherCitySnapshotScale
            },
            useAnim: false,
            colors: this.colors
          })

          Column() {
            Divider()
              .strokeWidth(0)
              .color($r('app.color.transparent'))
              .margin({ top: 148 })
              .bindPopup(this.weatherBgEditVM.isShowBubbleBox, {
                builder: this.buildBubbleBox(this.weatherBgEditVM.isStartSelected, () => {
                  if (!this.weatherBgEditVM.isStartSelected) {
                    this.weatherBgEditVM.isStartSelected = true
                    this.changeColorSelectorValue()
                  } else {
                    this.showColorInputDialog()
                  }
                }),
                placement: Placement.Top,
                mask: false,
                autoCancel: false,
                onWillDismiss: () => {
                  this.weatherBgEditVM.isShowBubbleBox = false
                  ZRouter.getInstance().pop()
                },
                popupColor: this.weatherBgEditVM.isStartSelected ? $r('app.color.color_d5d5d5') :
                $r('app.color.special_white'),
                enableArrow: true,
                radius: 12,
                shadow: { radius: 0 },
                backgroundBlurStyle: BlurStyle.NONE
              })
            Divider()
              .strokeWidth(0)
              .color($r('app.color.transparent'))
              .margin({ bottom: 148 })
              .bindPopup(this.weatherBgEditVM.isShowBubbleBox, {
                builder: this.buildBubbleBox(!this.weatherBgEditVM.isStartSelected, () => {
                  if (this.weatherBgEditVM.isStartSelected) {
                    this.weatherBgEditVM.isStartSelected = false
                    this.changeColorSelectorValue()
                  } else {
                    this.showColorInputDialog()
                  }
                }),
                placement: Placement.Bottom,
                mask: false,
                autoCancel: false,
                onWillDismiss: () => {
                  this.weatherBgEditVM.isShowBubbleBox = false
                  ZRouter.getInstance().pop()
                },
                popupColor: this.weatherBgEditVM.isStartSelected ? $r('app.color.special_white') :
                $r('app.color.color_d5d5d5'),
                enableArrow: true,
                radius: 12,
                shadow: { radius: 0 },
                backgroundBlurStyle: BlurStyle.NONE
              })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .visibility(this.isPreviewMode ? Visibility.Hidden : Visibility.Visible)
        }
        .width('100%')
        .layoutWeight(1)
        .onSizeChange((_, newValue) => {
          const height = newValue.height
          if (height) {
            const heightValue = height as number
            this.weatherBgEditVM.weatherCitySnapshotScale = (heightValue - 16) / px2vp(DisplayUtil.getHeight())
          }
        })

        if (!this.isPreviewMode) {
          Column() {
            Divider()
              .strokeWidth(16)
              .color($r('app.color.transparent'))
            Text('色相：')
              .fontSize(14)
              .fontColor($r('app.color.black'))
              .fontWeight(FontWeight.Bold)
            Divider()
              .strokeWidth(4)
              .color($r('app.color.transparent'))
            WeatherBgColorSelector({
              weatherBgColorSelectorController: this.hColorSelectorController,
              selectorWidth: '100%',
              selectorHeight: 20,
              max: 360,
              onValueChanged: (hue) => {
                const hsvColor = this.hsvColor
                const newHsvColor: [number, number, number] = [hue, hsvColor[1], hsvColor[2]]
                if (this.weatherBgEditVM.isNight) {
                  this.weatherBgEditVM.hsvNightColors[this.weatherBgEditVM.isStartSelected ? 0 : 1] = newHsvColor
                  this.weatherBgEditVM.nightColors[this.weatherBgEditVM.isStartSelected ? 0 : 1] =
                    HSVColor.hsv2color(newHsvColor)
                } else {
                  this.weatherBgEditVM.hsvColors[this.weatherBgEditVM.isStartSelected ? 0 : 1] = newHsvColor
                  this.weatherBgEditVM.colors[this.weatherBgEditVM.isStartSelected ? 0 : 1] =
                    HSVColor.hsv2color(newHsvColor)
                }
              },
              colors: [[$r('app.color.color_ff0000'), 0.0], [$r('app.color.color_ffff00'), 1 / 6],
                [$r('app.color.color_00ff00'), 1 / 3], [$r('app.color.color_00ffff'), 1 / 2],
                [$r('app.color.color_0000ff'), 2 / 3], [$r('app.color.color_ff00ff'), 5 / 6],
                [$r('app.color.color_ff0000'), 1]]
            })
            Divider()
              .strokeWidth(16)
              .color($r('app.color.transparent'))
            Text('饱和度：')
              .fontSize(14)
              .fontColor($r('app.color.black'))
              .fontWeight(FontWeight.Bold)
            Divider()
              .strokeWidth(4)
              .color($r('app.color.transparent'))
            WeatherBgColorSelector({
              weatherBgColorSelectorController: this.sColorSelectorController,
              selectorWidth: '100%',
              selectorHeight: 20,
              max: 1,
              onValueChanged: (saturation) => {
                const hsvColor = this.hsvColor
                const newHsvColor: [number, number, number] = [hsvColor[0], saturation, hsvColor[2]]
                if (this.weatherBgEditVM.isNight) {
                  this.weatherBgEditVM.hsvNightColors[this.weatherBgEditVM.isStartSelected ? 0 : 1] = newHsvColor
                  this.weatherBgEditVM.nightColors[this.weatherBgEditVM.isStartSelected ? 0 : 1] =
                    HSVColor.hsv2color(newHsvColor)
                } else {
                  this.weatherBgEditVM.hsvColors[this.weatherBgEditVM.isStartSelected ? 0 : 1] = newHsvColor
                  this.weatherBgEditVM.colors[this.weatherBgEditVM.isStartSelected ? 0 : 1] =
                    HSVColor.hsv2color(newHsvColor)
                }
              },
              colors: [[$r('app.color.special_white'), 0.0], [HSVColor.hsv2color([this.hsvColor[0], 1, 1]), 1]]
            })
            Divider()
              .strokeWidth(16)
              .color($r('app.color.transparent'))
            Text('亮度：')
              .fontSize(14)
              .fontColor($r('app.color.black'))
              .fontWeight(FontWeight.Bold)
            Divider()
              .strokeWidth(4)
              .color($r('app.color.transparent'))
            WeatherBgColorSelector({
              weatherBgColorSelectorController: this.vColorSelectorController,
              selectorWidth: '100%',
              selectorHeight: 20,
              max: 1,
              onValueChanged: (value) => {
                const hsvColor = this.hsvColor
                const newHsvColor: [number, number, number] = [hsvColor[0], hsvColor[1], value]
                if (this.weatherBgEditVM.isNight) {
                  this.weatherBgEditVM.hsvNightColors[this.weatherBgEditVM.isStartSelected ? 0 : 1] = newHsvColor
                  this.weatherBgEditVM.nightColors[this.weatherBgEditVM.isStartSelected ? 0 : 1] =
                    HSVColor.hsv2color(newHsvColor)
                } else {
                  this.weatherBgEditVM.hsvColors[this.weatherBgEditVM.isStartSelected ? 0 : 1] = newHsvColor
                  this.weatherBgEditVM.colors[this.weatherBgEditVM.isStartSelected ? 0 : 1] =
                    HSVColor.hsv2color(newHsvColor)
                }
              },
              colors: [[$r('app.color.special_black'), 0.0], [$r('app.color.special_white'), 1]]
            })
          }
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 32, right: 32 })
        }

        if (!this.isPreviewMode) {
          Divider()
            .strokeWidth(12)
            .color($r('app.color.transparent'))
        }

        if (!this.isPreviewMode) {
          Row() {
            OpacityLayout({
              child: () => {
                this.functionButton('取消')
              },
              onTap: () => {
                this.weatherBgEditVM.isShowBubbleBox = false
                ZRouter.getInstance().pop()
              }
            })
              .layoutWeight(1)

            OpacityLayout({
              child: () => {
                this.functionButton('确定')
              },
              onTap: () => {
                const weatherBgModel = {
                  isSelected: this.isEdit ? this.weatherBgModel?.isSelected : undefined,
                  supportEdit: true,
                  colors: this.weatherBgEditVM.getColors(this.weatherBgEditVM.colors),
                  nightColors: this.weatherBgEditVM.getColors(this.weatherBgEditVM.nightColors)
                } as WeatherBgModel
                AppRuntimeData.getInstance().addWeatherBg(this.weatherType, weatherBgModel, () => {
                  this.weatherBgEditVM.isShowBubbleBox = false
                  ZRouter.getInstance().pop()
                }, this.isEdit ? this.weatherBgModel : undefined)
              }
            })
              .layoutWeight(1)
          }
          .width('100%')
          .height(64)
          .padding({ left: 32, right: 32 })
        }

        Divider()
          .strokeWidth(px2vp(AppUtil.getNavigationIndicatorHeight()))
          .color($r('app.color.transparent'))
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .height('100%')
    .width('100%')
    .onReady((context) => {
      ZRouter.animateMgr()
        .registerAnimParam(this, context)
        .setEnterAnimate({ duration: 500, curve: Curve.LinearOutSlowIn })
        .setExitAnimate({ duration: 500, curve: Curve.LinearOutSlowIn })
        .addAnimateOptions(new TranslateAnimationOptions({ y: '100%' }))
    })
    .onDisAppear(() => {
      ZRouter.animateMgr().unregisterAnim(this)
    })
    .onShown(() => {
      refreshStatusBar({
        isStatusBarLightIcon: isDark()
      })
    })
    .attributeModifier(ZRouter.animateMgr().modifier(this))
    .backgroundColor($r('app.color.bg_color'))
  }

  @Builder
  dayNightButton(isDayButton: boolean) {
    Text(isDayButton ? '日间' : '夜间')
      .width('100%')
      .height('100%')
      .textAlign(TextAlign.Center)
      .borderRadius(16)
      .backgroundColor(isDayButton ?
      ColorUtils.alphaStr($r('app.color.black'), this.weatherBgEditVM.isNight ? 0 : 0.25) :
      ColorUtils.alphaStr($r('app.color.black'), this.weatherBgEditVM.isNight ? 0.25 : 0))
      .fontSize(18)
      .fontColor($r('app.color.black'))
      .fontWeight(isDayButton ? this.weatherBgEditVM.isNight ? undefined : FontWeight.Bold :
        this.weatherBgEditVM.isNight ? FontWeight.Bold : undefined)
      .animation({ curve: Curve.Linear, duration: 400 })
  }

  @Builder
  functionButton(text: string) {
    Text(text)
      .width('100%')
      .height('100%')
      .textAlign(TextAlign.Center)
      .fontSize(18)
      .fontColor($r('app.color.black'))
      .fontWeight(FontWeight.Bold)
  }

  @Builder
  buildBubbleBox(isStartSelected: boolean, onTap: () => void) {
    Text(ColorUtils.color2hex(this.colors[isStartSelected ? 0 : 1][0] as Resource, true))
      .fontSize(15)
      .fontColor($r('app.color.color_333333'))
      .padding({
        left: 12,
        top: 8,
        right: 12,
        bottom: 8
      })
      .onClick(onTap)
  }

  get data() {
    const key = (AppRuntimeData.getInstance().currentCityData?.isLocationCity ?? false) ? Constants.LOCATION_CITY_ID :
      AppRuntimeData.getInstance().currentCityData?.cityid
    const weatherData = AppRuntimeData.getInstance().getWeatherData(key ?? '')
    return WeatherDataUtils.generateWeatherItems(AppRuntimeData.getInstance().currentWeatherCardSort,
      AppRuntimeData.getInstance().currentWeatherObservesCardSort, weatherData)
  }

  get colors() {
    return this.weatherBgEditVM.isNight ? this.weatherBgEditVM.getColors(this.weatherBgEditVM.nightColors) :
    this.weatherBgEditVM.getColors(this.weatherBgEditVM.colors)
  }

  get hsvColor() {
    return this.weatherBgEditVM.isNight ?
    this.weatherBgEditVM.hsvNightColors[this.weatherBgEditVM.isStartSelected ? 0 : 1] :
    this.weatherBgEditVM.hsvColors[this.weatherBgEditVM.isStartSelected ? 0 : 1]
  }

  changeColorSelectorValue() {
    const hsvColor = this.hsvColor
    this.hColorSelectorController.changeValue(hsvColor[0])
    this.sColorSelectorController.changeValue(hsvColor[1])
    this.vColorSelectorController.changeValue(hsvColor[2])
  }

  showColorInputDialog() {
    DialogHelper.showCustomDialog(wrapBuilder(ColorInputDialogBuilder), {
      dialogId: 'color_input_dialog',
      ref: this.popupExitRef,
      transition: AnimationHelper.transitionInDown(0),
      alignment: DialogAlignment.Bottom,
      onWillDismiss: () => {
        this.popupExitRef.exit()
      },
      completed: (color) => {
        if (this.weatherBgEditVM.isNight) {
          this.weatherBgEditVM.hsvNightColors[this.weatherBgEditVM.isStartSelected ? 0 : 1] =
            HSVColor.fromColor(color as Resource)
          this.weatherBgEditVM.nightColors[this.weatherBgEditVM.isStartSelected ? 0 : 1] = color
        } else {
          this.weatherBgEditVM.hsvColors[this.weatherBgEditVM.isStartSelected ? 0 : 1] =
            HSVColor.fromColor(color as Resource)
          this.weatherBgEditVM.colors[this.weatherBgEditVM.isStartSelected ? 0 : 1] = color
        }
        this.changeColorSelectorValue()
      }
    } as ColorInputDialogOptions)
  }
}