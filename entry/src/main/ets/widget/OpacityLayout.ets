@ComponentV2
export struct OpacityLayout {
  @Param pressedOpacity: number = 0.4
  @BuilderParam child: () => void
  @Event onTap?: () => void = undefined
  @Local currentOpacity: number = 1

  build() {
    Stack() {
      this.child()
    }
    .opacity(this.currentOpacity)
    .animation({ curve: Curve.Ease, duration: 300 })
    .onTouch(e => {
      if (e.type == TouchType.Down) {
        this.currentOpacity = this.pressedOpacity
      } else if (e.type == TouchType.Up || e.type == TouchType.Cancel) {
        this.currentOpacity = 1
      }
    })
    .onClick(this.onTap)
  }
}