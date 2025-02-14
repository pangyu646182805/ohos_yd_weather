import { ViewState } from "../constants/ViewState";

@ComponentV2
export struct MultipleStatusLayout {
  @Param message: string = '暂无数据'
  @Param viewState: string = ViewState.VIEW_STATE_LOADING
  @BuilderParam contentView: () => void

  build() {
    Stack() {
      if (this.viewState == ViewState.VIEW_STATE_LOADING) {
        LoadingProgress()
          .color($r('app.color.color_999999'))
          .width(48)
          .height(48)
      } else if (this.viewState == ViewState.VIEW_STATE_ERROR) {
        Text(this.message)
          .fontColor($r('app.color.color_999999'))
          .fontSize(14)
      } else {
        this.contentView()
      }
    }
    .width('100%')
    .height('100%')
  }
}