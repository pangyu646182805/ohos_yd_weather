import { common2D, drawing } from "@kit.ArkGraphics2D";

export class ColorUtils {
  static alpha(color: Resource, opacity: number): number {
    let colorValue = getContext().resourceManager.getColorSync(color.id)
    // 将透明度限制在0到1之间
    const clampedOpacity = Math.max(0, Math.min(1, opacity));

    // 将颜色值转换为RGBA格式
    const red = (colorValue >> 16) & 0xff;
    const green = (colorValue >> 8) & 0xff;
    const blue = colorValue & 0xff;

    // 计算带透明度的颜色值
    const alpha = Math.round(clampedOpacity * 255);
    const rgbaColor = ((alpha & 0xff) << 24) | (red << 16) | (green << 8) | blue;

    // 使用 >>> 0 确保返回无符号整数
    return rgbaColor >>> 0;
  }

  static adjustAlpha(colorValue: number, factor: number): number {
    const alpha = (colorValue >> 24) & 0xff
    const red = (colorValue >> 16) & 0xff
    const green = (colorValue >> 8) & 0xff
    const blue = colorValue & 0xff
    const adjustAlpha = alpha * factor
    const rgbaColor = ((adjustAlpha & 0xff) << 24) | (red << 16) | (green << 8) | blue
    return rgbaColor >>> 0
  }

  static alphaStr(color: Resource, opacity: number): string {
    let colorValue = getContext().resourceManager.getColorSync(color.id)
    const red = (colorValue >> 16) & 0xff;
    const green = (colorValue >> 8) & 0xff;
    const blue = colorValue & 0xff;
    const clampedOpacity = Math.max(0, Math.min(1, opacity));
    return `rgba(${red}, ${green}, ${blue}, ${clampedOpacity})`
  }

  static getDarkness(color: Resource): number {
    let colorValue = getContext().resourceManager.getColorSync(color.id)
    const red = (colorValue >> 16) & 0xff;
    const green = (colorValue >> 8) & 0xff;
    const blue = colorValue & 0xff;
    return 1 - (0.299 * red + 0.587 * green + 0.114 * blue) / 255;
  }

  static estimateBrightnessForColor(color: Resource): ColorMode {
    let colorValue = getContext().resourceManager.getColorSync(color.id)
    const red = (colorValue >> 16) & 0xff;
    const green = (colorValue >> 8) & 0xff;
    const blue = colorValue & 0xff;
    const relativeLuminance = ColorUtils.computeLuminance(red / 255, green / 255, blue / 255)
    const kThreshold = 0.15
    if ((relativeLuminance + 0.05) * (relativeLuminance + 0.05) > kThreshold) {
      return ColorMode.LIGHT
    }
    return ColorMode.DARK
  }

  private static computeLuminance(red: number, green: number, blue: number): number {
    const r = ColorUtils.linearizeColorComponent(red)
    const g = ColorUtils.linearizeColorComponent(green)
    const b = ColorUtils.linearizeColorComponent(blue)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
  }

  private static linearizeColorComponent(component: number): number {
    if (component <= 0.03928) {
      return component / 12.92
    }
    return Math.pow((component + 0.055) / 1.055, 2.4)
  }

  static translateColor(color: Resource, opacity: number = 1): drawing.ColorFilter {
    let colorValue = getContext().resourceManager.getColorSync(color.id)
    const red = (colorValue >> 16) & 0xff;
    const green = (colorValue >> 8) & 0xff;
    const blue = colorValue & 0xff;
    const color2D: common2D.Color = {
      alpha: 255 * opacity,
      red: red,
      green: green,
      blue: blue
    }
    return drawing.ColorFilter.createBlendModeColorFilter(color2D, drawing.BlendMode.SRC_IN)
  }
}