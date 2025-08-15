export class HSVColor {
  static fromColor(color: Resource): [number, number, number] {
    let colorValue = 0
    if (typeof color == "number") {
      colorValue = color
    } else {
      colorValue = getContext().resourceManager.getColorSync(color.id)
    }
    const red = (colorValue >> 16) & 0xff;
    const green = (colorValue >> 8) & 0xff;
    const blue = colorValue & 0xff;
    return HSVColor.rgb2hsv(red, green, blue)
  }

  static rgb2hsv(r: number, g: number, b: number): [number, number, number] {
    let h: number, s: number, v: number
    const max = Math.max(r, g, b)
    const min = Math.min(r, g, b)
    const delta = max - min

    if (delta === 0) {
      h = 0
    } else if (r === max) {
      h = ((g - b) / delta) % 6
    } else if (g === max) {
      h = (b - r) / delta + 2
    } else {
      h = (r - g) / delta + 4
    }

    h = Math.round(h * 60)
    if (h < 0) {
      h += 360
    }

    s = max === 0 ? 0 : delta / max

    v = max / 255

    return [h, s, v]
  }

  static hsv2color(hsv: [number, number, number]): number {
    const rgb = HSVColor.hsv2rgb(hsv[0], hsv[1], hsv[2])
    const alpha = 255
    const red = rgb[0]
    const green = rgb[1]
    const blue = rgb[2]
    const rgbaColor = ((alpha & 0xff) << 24) | (red << 16) | (green << 8) | blue
    return rgbaColor >>> 0
  }

  static hsv2rgb(h: number, s: number, v: number): [number, number, number] {
    let rgb: number[] = []
    const c = v * s
    const hh = h / 60
    const x = c * (1 - Math.abs((hh % 2) - 1))
    const m = v - c

    if (hh >= 0 && hh < 1) {
      rgb = [c, x, 0]
    } else if (hh >= 1 && hh < 2) {
      rgb = [x, c, 0]
    } else if (hh >= 2 && hh < 3) {
      rgb = [0, c, x]
    } else if (h >= 3 && hh < 4) {
      rgb = [0, x, c]
    } else if (h >= 4 && hh < 5) {
      rgb = [x, 0, c]
    } else if (h >= 5 && hh <= 6) {
      rgb = [c, 0, x]
    } else {
      rgb = [0, 0, 0]
    }

    return [Math.round(255 * (rgb[0] + m)), Math.round(255 * (rgb[1] + m)), Math.round(255 * (rgb[2] + m))]
  }
}