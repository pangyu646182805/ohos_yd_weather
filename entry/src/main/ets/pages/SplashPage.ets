import { ZRouter } from '@hzw/zrouter'
import { RouterConstants } from '../constants/RouterConstants'
import { Route } from '@hzw/zrouter'
import { Logger } from '@hzw/logger'
import { Constants } from '../constants/Constants'
import { PreferencesUtil, StrUtil } from '@pura/harmony-utils'
import { appDatabase } from '../db/AppDatabase'
import { cityDataTable } from '../db/model/CityData'

@Route({ name: RouterConstants.SPLASH_PAGE })
@ComponentV2
export struct SplashPage {
  build() {
    NavDestination() {
      Column() {
        Image($r('app.media.splash'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      }
    }
    .hideTitleBar(true)
    .height('100%')
    .width('100%')
    .onAppear(() => {
      Logger.e('SplashPage aboutToAppear')
      setTimeout(() => {
        this.handle()
      }, 800)
    })
    .onBackPressed(() => {
      console.log('onBackPressed');
      return true
    })
  }

  async handle() {
    let locationCity =
      await appDatabase.cityDataDao.queryOne(it => it.equalTo(cityDataTable.key, Constants.LOCATION_CITY_ID))
    Logger.e('locationCity = ' + locationCity)
    if (!locationCity) {
      locationCity = {
        key: Constants.LOCATION_CITY_ID,
        isLocationCity: true
      }
      await appDatabase.cityDataDao.insert(locationCity)
    }

    const currentCityId = PreferencesUtil.getStringSync(Constants.CURRENT_CITY_ID)
    Logger.e('currentCityId = ' + currentCityId)
    if (StrUtil.isNotEmpty(locationCity?.cityid) || StrUtil.isNotEmpty(currentCityId)) {
      let currentCity = await appDatabase.cityDataDao.queryOne(it => it.equalTo(cityDataTable.key, currentCityId))
      Logger.e('currentCity = ' + currentCity)
      ZRouter.getInstance().replace(RouterConstants.WEATHER_MAIN_PAGE)
    } else {
      ZRouter.getInstance().replace(RouterConstants.SELECT_CITY_PAGE)
    }
  }
}