import { Route, ZRouter } from "@hzw/zrouter";
import { AppUtil } from "@pura/harmony-utils";
import { RouterConstants } from "../constants/RouterConstants";
import { CityData } from "../db/model/CityData";
import { KeyboardDismissOnTap } from "../utils/KeyboardDismissOnTap";
import SelectCityViewModel from "../viewmodel/SelectCityViewModel";
import { MultipleStatusLayout } from "../widget/MultipleStatusLayout";

@Route({ name: RouterConstants.SELECT_CITY_PAGE })
@ComponentV2
export struct SelectCityPage {
  @Local selectCityVm: SelectCityViewModel = new SelectCityViewModel()

  aboutToAppear(): void {
    this.selectCityVm.obtainHotCityData()
  }

  @Computed
  get exitApp() {
    return ZRouter.getInstance().getAllPathName().length <= 1;
  }

  @Builder
  SearchContent() {
    Search({
      placeholder: '搜索城市（中文/拼音）',
      icon: '/resources/base/media/ic_search_home.webp',
    })
      .backgroundColor($r('app.color.card_color_02'))
      .placeholderFont({ size: 16 })
      .placeholderColor($r('app.color.color_999999'))
      .searchIcon({ color: $r('app.color.color_999999') })
      .padding({ left: 8, right: 8 })
      .margin({ top: 0, bottom: 0 })
      .layoutWeight(1)
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          this.SearchContent()
          if (!this.exitApp) {
            Text('取消')
              .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
              .fontColor($r('app.color.color_999999'))
              .fontSize(16)
              .padding(8)
              .onClick(() => {
                ZRouter.getInstance().pop()
              })
          }
        }
        .padding({
          left: 16,
          top: 8,
          right: 8,
          bottom: 8
        })

        MultipleStatusLayout({
          message: this.selectCityVm.errorMessage,
          viewState: this.selectCityVm.viewState,
          contentView: () => {
            this.contentView()
          }
        })
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .attributeModifier(new KeyboardDismissOnTap())
    }
    .hideTitleBar(true)
    .padding({ top: px2vp(AppUtil.getStatusBarHeight()) })
    .height('100%')
    .width('100%')
    .onBackPressed(() => {
      if (this.exitApp) {
        AppUtil.getContext().terminateSelf()
        return true
      }
      return false
    })
  }

  @Builder
  contentView() {
    List() {
      ListItem() {
        this.header('国内热门城市')
      }

      ListItem() {
        this.content(this.selectCityVm.selectCityData?.hot_national)
      }

      ListItem() {
        this.header('国际热门城市')
      }

      ListItem() {
        this.content(this.selectCityVm.selectCityData?.hot_international)
      }
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  header(header: string) {
    Text(header)
      .fontColor($r('app.color.text_color_01'))
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .padding({ left: 16 })
      .margin({ top: 8 })
  }

  @Builder
  content(cityList?: Array<CityData>) {
    Grid() {
      ForEach(cityList, (cityData: CityData) => {
        GridItem() {
          Text(cityData.name)
            .textAlign(TextAlign.Center)
            .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
            .fontColor($r('app.color.text_color_01'))
            .fontSize(13)
            .padding({ top: 12, bottom: 12 })
            .backgroundColor($r('app.color.card_color_06'))
            .borderRadius(100)
            .width('100%')
        }
      }, (cityData: CityData): string => {
        return cityData.cityid ?? ''
      })
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .columnsGap(16)
    .rowsGap(16)
    .maxCount(4)
    .layoutDirection(GridDirection.Row)
    .padding({
      left: 16,
      top: 12,
      right: 16,
      bottom: 16
    })
  }
}