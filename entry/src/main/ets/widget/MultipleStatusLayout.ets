import { ViewState } from "../constants/ViewState";

@ComponentV2
export struct MultipleStatusLayout {
  @Param message: string = '暂无数据'
  @Param viewState: string = ViewState.VIEW_STATE_LOADING
  @Param loadingProgressColor: ResourceColor = $r('app.color.color_999999')
  @BuilderParam contentView: () => void

  build() {
    Stack() {
      if (this.viewState == ViewState.VIEW_STATE_LOADING) {
        LoadingProgress()
          .color(this.loadingProgressColor)
          .width(48)
          .height(48)
          .transition(TransitionEffect.opacity(0).animation({ curve: Curve.Ease, duration: 400 }))
      } else if (this.viewState == ViewState.VIEW_STATE_ERROR) {
        Text(this.message)
          .fontColor($r('app.color.color_999999'))
          .fontSize(14)
          .transition(TransitionEffect.opacity(0).animation({ curve: Curve.Ease, duration: 400 }))
      } else {
        Stack() {
          this.contentView()
        }
        .width('100%')
        .height('100%')
        .transition(TransitionEffect.opacity(0).animation({ curve: Curve.Ease, duration: 400 }))
      }
    }
    .width('100%')
    .height('100%')
  }
}