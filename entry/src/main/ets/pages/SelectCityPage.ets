import { Logger } from "@hzw/logger";
import { Route, ZRouter } from "@hzw/zrouter";
import { AppUtil, ArrayUtil, StrUtil, ToastUtil } from "@pura/harmony-utils";
import { Constants } from "../constants/Constants";
import { RouterConstants } from "../constants/RouterConstants";
import { CityData } from "../db/model/CityData";
import { AppRuntimeData } from "../utils/AppRuntimeData";
import { debounce } from "../utils/CommonUtils";
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
      .onSubmit((value) => {
        if (!value) {
          ToastUtil.showToast('请输入搜索关键字')
        }
      })
      .onChange((value) => {
        debounce(() => {
          if (!value) {
            this.selectCityVm.clearSearchResult()
          } else {
            this.selectCityVm.searchCity(value)
          }
        }, 333)
      })
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

        Divider()
          .strokeWidth(0.5)
          .color($r('app.color.line_color'))

        Stack() {
          MultipleStatusLayout({
            message: this.selectCityVm.errorMessage,
            viewState: this.selectCityVm.viewState,
            contentView: () => {
              this.contentView()
            }
          })
          this.searchResultContent()
        }
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
        this.locationButton()
      }

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
  locationButton() {
    Row({ space: 4 }) {
      Image($r('app.media.writing_icon_location1'))
        .width(18)
        .height(18)
      Text(this.selectCityVm.locationState == 0 ? '定位中...' :
        (this.selectCityVm.locationData?.address_component?.district ?? '定位失败'))
        .fontSize(13)
        .fontColor($r('app.color.text_color_01'))
    }
    .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
    .padding({
      left: 12,
      top: 12,
      right: 12,
      bottom: 12
    })
    .backgroundColor($r('app.color.card_color_06'))
    .borderRadius(100)
    .margin({ left: 16, top: 12, bottom: 12 })
    .onClick(() => {
      if (!this.selectCityVm.locationData && this.selectCityVm.locationState == 1) {
        this.selectCityVm.obtainLocationPermission()
      }
    })
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
            .fontColor(this.hasAdded(cityData) ? $r('app.color.app_main') : $r('app.color.text_color_01'))
            .fontSize(13)
            .padding({ top: 12, bottom: 12 })
            .backgroundColor($r('app.color.card_color_06'))
            .borderRadius(100)
            .width('100%')
            .onClick(() => {
              this.gotoWeatherPreviewPage(cityData)
            })
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

  @Builder
  searchResultContent() {
    if (ArrayUtil.isNotEmpty(this.selectCityVm.searchResult)) {
      List() {
        ForEach(this.selectCityVm.searchResult, (cityData: CityData) => {
          ListItem() {
            Text(StrUtil.isEmpty(cityData.prov) ? cityData.name + ' - ' + cityData.country :
              cityData.name + ' - ' + cityData.prov + ' - ' + cityData.country)
              .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
              .fontColor(this.hasAdded(cityData) ? $r('app.color.app_main') : $r('app.color.text_color_01'))
              .fontSize(15)
              .padding({
                left: 16,
                top: 12,
                right: 16,
                bottom: 12
              })
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .onClick(() => {
                this.gotoWeatherPreviewPage(cityData)
              })
          }
        }, (cityData: CityData): string => {
          return cityData.cityid ?? ''
        })
        ListItem() {
          Divider()
            .strokeWidth(px2vp(AppUtil.getNavigationIndicatorHeight()))
            .color($r('app.color.transparent'))
        }
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .animatableOpacity(this.selectCityVm.searchResultContentOpacity)
      .animation({ duration: 222, curve: Curve.Linear })
      .backgroundColor($r('app.color.bg_color'))
    }
  }

  hasAdded(cityData: CityData) {
    const find = this.selectCityVm.addedCityData?.find(it => it.cityid == cityData.cityid)
    return find != undefined
  }

  gotoWeatherPreviewPage(cityData: CityData) {
    ZRouter.getInstance()
      .withParam(Constants.CITY_DATA, cityData)
      .setPopListener(() => {
        setTimeout(() => {
          AppRuntimeData.getInstance().addCity(cityData)
        }, 500)
      })
      .push(RouterConstants.WEATHER_PREVIEW_PAGE)
  }
}

@AnimatableExtend(List)
function animatableOpacity(opacity: number) {
  .opacity(opacity)
}