export class ColorUtils {
  static alpha(color: Resource, opacity: number): ResourceColor {
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
}