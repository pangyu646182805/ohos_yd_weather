import { FrameCallback } from "@kit.ArkUI";

export class MyFrameCallback extends FrameCallback {
  onFrameCallback: () => void

  constructor(onFrameCallback: () => void) {
    super();
    this.onFrameCallback = onFrameCallback
  }

  onFrame(): void {
    this.onFrameCallback()
  }
}