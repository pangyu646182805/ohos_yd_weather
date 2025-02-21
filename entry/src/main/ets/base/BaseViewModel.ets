import { ViewState } from "../constants/ViewState";

@ObservedV2
export default class BaseViewModel {
  private _isDestroy = false
  @Trace viewState = ViewState.VIEW_STATE_LOADING
  @Trace errorMessage = ''

  constructor() {
    this._isDestroy = false
  }

  setViewState(viewState: string) {
    if (this.viewState != viewState && !this.hasData()) {
      this.viewState = viewState
    }
  }

  setErrorMessage(message: string) {
    this.errorMessage = message
  }

  isSuccess(): boolean {
    return ViewState.VIEW_STATE_SUCCESS == this.viewState
  }

  isLoading(): boolean {
    return ViewState.VIEW_STATE_LOADING == this.viewState
  }

  isError(): boolean {
    return ViewState.VIEW_STATE_ERROR == this.viewState
  }

  hasData(): boolean {
    return false
  }

  get isDestroy(): boolean {
    return this._isDestroy;
  }

  destroy(): void {
    this._isDestroy = true;
  }
}