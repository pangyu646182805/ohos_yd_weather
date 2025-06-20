import { FrameCallback } from "@kit.ArkUI";

class FrameCallbackOptions {
  onFrameCallback?: () => void
  onIdleCallback?: () => void
}

export class MyFrameCallback extends FrameCallback {
  onFrameCallback?: () => void
  onIdleCallback?: () => void

  constructor(options: FrameCallbackOptions) {
    super();
    this.onFrameCallback = options.onFrameCallback
    this.onIdleCallback = options.onIdleCallback
  }

  onFrame(): void {
    if (this.onFrameCallback) {
      this.onFrameCallback()
    }
  }

  onIdle(): void {
    if (this.onIdleCallback) {
      this.onIdleCallback()
    }
  }
}