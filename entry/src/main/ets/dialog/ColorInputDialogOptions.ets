import { BaseDialogOptions } from "@pura/harmony-dialog"
import { PopupExitController } from "./PopupExitController"

export interface ColorInputDialogOptions extends BaseDialogOptions {
  ref: PopupExitController
  completed: (color: ResourceColor) => void
}