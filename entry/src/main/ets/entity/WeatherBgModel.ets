export interface WeatherBgModel {
  supportEdit?: boolean
  isSelected?: boolean
  colors?: Array<[ResourceColor, number]>
  nightColors?: Array<[ResourceColor, number]>
}

export function equalsWeatherBgModel(e: WeatherBgModel | undefined, other: WeatherBgModel | undefined): boolean {
  if (!e || !other) {
    return false
  }
  const colors = e.colors
  const otherColors = other!.colors
  const nightColors = e.nightColors ?? e.colors
  const otherNightColors = other!.nightColors ?? other!.colors
  if ((colors?.length ?? 0) >= 2 && (otherColors?.length ?? 0) >= 2 && (nightColors?.length ?? 0) >= 2 &&
    (otherNightColors?.length ?? 0) >= 2) {
    const r1 = typeof colors![0][0] == 'number' ? colors![0][0] as number : (colors![0][0] as Resource).id
    const otherR1 =
      typeof otherColors![0][0] == 'number' ? otherColors![0][0] as number : (otherColors![0][0] as Resource).id
    const r2 = typeof colors![1][0] == 'number' ? colors![1][0] as number : (colors![1][0] as Resource).id
    const otherR2 =
      typeof otherColors![1][0] == 'number' ? otherColors![1][0] as number : (otherColors![1][0] as Resource).id
    const nightR1 =
      typeof nightColors![0][0] == 'number' ? nightColors![0][0] as number : (nightColors![0][0] as Resource).id
    const nightOtherR1 = typeof otherNightColors![0][0] == 'number' ? otherNightColors![0][0] as number :
    (otherNightColors![0][0] as Resource).id
    const nightR2 =
      typeof nightColors![1][0] == 'number' ? nightColors![1][0] as number : (nightColors![1][0] as Resource).id
    const nightOtherR2 = typeof otherNightColors![1][0] == 'number' ? otherNightColors![1][0] as number :
    (otherNightColors![1][0] as Resource).id
    return r1 == otherR1 && r2 == otherR2 && nightR1 == nightOtherR1 && nightR2 == nightOtherR2
  }
  return false
}