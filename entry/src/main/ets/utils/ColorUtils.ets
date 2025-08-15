import { Logger } from "@hzw/logger";
import { common2D, drawing } from "@kit.ArkGraphics2D";
import { ObjectUtil } from "@pura/harmony-utils";

export class ColorUtils {
  static alpha(color: Resource, opacity: number): number {
    let colorValue = 0
    if (typeof color == "number") {
      colorValue = color
    } else {
      colorValue = getContext().resourceManager.getColorSync(color.id)
    }
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
    let colorValue = 0
    if (typeof color == "number") {
      colorValue = color
    } else {
      colorValue = getContext().resourceManager.getColorSync(color.id)
    }
    const red = (colorValue >> 16) & 0xff;
    const green = (colorValue >> 8) & 0xff;
    const blue = colorValue & 0xff;
    const clampedOpacity = Math.max(0, Math.min(1, opacity));
    return `rgba(${red}, ${green}, ${blue}, ${clampedOpacity})`
  }

  static getDarkness(color: Resource): number {
    let colorValue = 0
    if (typeof color == "number") {
      colorValue = color
    } else {
      colorValue = getContext().resourceManager.getColorSync(color.id)
    }
    const red = (colorValue >> 16) & 0xff;
    const green = (colorValue >> 8) & 0xff;
    const blue = colorValue & 0xff;
    return 1 - (0.299 * red + 0.587 * green + 0.114 * blue) / 255;
  }

  static estimateBrightnessForColor(color: Resource): ColorMode {
    let colorValue = 0
    if (typeof color == "number") {
      colorValue = color
    } else {
      colorValue = getContext().resourceManager.getColorSync(color.id)
    }
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
    let colorValue = 0
    if (typeof color == "number") {
      colorValue = color
    } else {
      colorValue = getContext().resourceManager.getColorSync(color.id)
    }
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

  static color2hex(color: Resource, toUpperCase: boolean = false): string {
    let colorValue = 0
    if (typeof color == "number") {
      colorValue = color
    } else {
      colorValue = getContext().resourceManager.getColorSync(color.id)
    }
    const red = (colorValue >> 16) & 0xff;
    const green = (colorValue >> 8) & 0xff;
    const blue = colorValue & 0xff;
    const result = ColorUtils.rgb2hex(red, green, blue, toUpperCase)
    Logger.e("color2hex = " + result)
    return result
  }

  static rgb2hex(r: number, g: number, b: number, toUpperCase: boolean = false): string {
    const result = `#${[r, g, b].map(n => n.toString(16).padStart(2, '0')).join('')}`
    return toUpperCase ? result.toUpperCase() : result
  }

  static hex2color(hex: string): number {
    const rgb = ColorUtils.hex2rgb(hex)
    const alpha = 255
    const red = rgb[0]
    const green = rgb[1]
    const blue = rgb[2]
    const rgbaColor = ((alpha & 0xff) << 24) | (red << 16) | (green << 8) | blue
    return rgbaColor >>> 0
  }

  static hex2rgb(hex: string): [number, number, number] {
    const hexInfo = ColorUtils.formatHex(hex)

    return [
      parseInt(hexInfo[0].substring(1, 3), 16),
      parseInt(hexInfo[0].substring(3, 5), 16),
      parseInt(hexInfo[0].substring(5, 7), 16),
    ]
  }

  static formatHex(hex: string): [string, number] {
    const str = hex.replace('#', '')

    if (str.length === 4) {
      return [`#${str[1].repeat(2)}${str[2].repeat(2)}${str[3].repeat(2)}`, parseInt(str[0].repeat(2), 16) / 255]
    } else if (str.length === 3) {
      return [`#${str[0].repeat(2)}${str[1].repeat(2)}${str[2].repeat(2)}`, 1]
    } else if (str.length === 8) {
      return [`#${str.substring(2, 8)}`, parseInt(str.substring(0, 2), 16) / 255]
    } else if (str.length === 6) {
      return [`#${str}`, 1]
    } else {
      throw new Error('Invalid hex color format')
    }
  }

  static calSimilarity(color1: Resource | number | undefined, color2: Resource | number | undefined): number {
    if (ObjectUtil.isNull(color1) || ObjectUtil.isNull(color2)) {
      return 0
    }
    let colorValue1 = 0
    let colorValue2 = 0
    if (typeof color1 == "number") {
      colorValue1 = color1
    } else {
      colorValue1 = getContext().resourceManager.getColorSync(color1!.id)
    }
    if (typeof color2 == "number") {
      colorValue2 = color2
    } else {
      colorValue2 = getContext().resourceManager.getColorSync(color2!.id)
    }

    const red1 = (colorValue1 >> 16) & 0xff
    const green1 = (colorValue1 >> 8) & 0xff
    const blue1 = colorValue1 & 0xff
    const red2 = (colorValue2 >> 16) & 0xff
    const green2 = (colorValue2 >> 8) & 0xff
    const blue2 = colorValue2 & 0xff

    const distance = Math.sqrt(
      Math.pow(red1 - red2, 2) + Math.pow(green1 - green2, 2) + Math.pow(blue1 - blue2, 2))
    return 1 - distance / 255 / Math.sqrt(3);
  }
}