import { StrUtil } from "@pura/harmony-utils";
import { CityData } from "../db/model/CityData";
import { getTemp } from "../utils/CommonUtils";

@ComponentV2
export struct CityManagerItem {
  @Param cityData?: CityData = undefined

  build() {
    Column() {
      Stack() {
        this.cityItem()
      }
      .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.9 })
      .borderRadius(16)
      .backgroundColor($r('app.color.color_999999'))
      .linearGradient({
        direction: GradientDirection.Right,
        colors: [[0xffff0000, 0.0], [0xff000000, 1.0]]
      })
      .width('100%')
      .height(98)
      .onClick(() => {
      })
    }
    .padding({ left: 16, right: 16 })
  }

  @Builder
  cityItem() {
    Row() {
      Column({ space: 4 }) {
        Row() {
          Text(this.title)
            .fontSize(20)
            .fontColor($r('app.color.special_white'))
            .fontWeight(FontWeight.Lighter)
          Image($r('app.media.writing_icon_location1'))
            .width(22)
            .height(22)
            .fillColor($r('app.color.special_white'))
            .visibility(this.isLocationCity ? Visibility.Visible : Visibility.Hidden)
        }

        Text(this.subTitle)
          .fontSize(14)
          .fontColor($r('app.color.special_white'))
          .fontWeight(FontWeight.Lighter)
      }
      .alignItems(HorizontalAlign.Start)

      Text(getTemp(this.cityData?.weatherData?.temp))
        .fontSize(38)
        .fontColor($r('app.color.special_white'))
        .fontWeight(FontWeight.Lighter)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Computed
  get isLocationCity() {
    return this.cityData?.isLocationCity ?? false
  }

  @Computed
  get title() {
    const isLocationCity = this.isLocationCity
    const city = this.cityData?.weatherData?.city ?? ''
    const street = this.cityData?.street ?? ''
    return !isLocationCity || StrUtil.isEmpty(street) ? city : city + ' ' + street
  }

  @Computed
  get subTitle() {
    const weatherData = this.cityData?.weatherData
    return weatherData?.weatherDesc + ' ' + getTemp(weatherData?.tempHigh) + ' / ' + getTemp(weatherData?.tempLow)
  }
}