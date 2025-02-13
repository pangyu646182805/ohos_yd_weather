import { ZRouter } from '@hzw/zrouter'
import { RouterConstants } from '../constants/RouterConstants'
import { Route } from '@hzw/zrouter'
import { Logger } from '@hzw/logger'
import { myDatabase } from '../db/AppDatabase'
import { TableCityData } from '../db/model/CityData'
import { Constants } from '../constants/Constants'
import { PreferencesUtil, StrUtil } from '@pura/harmony-utils'

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

  handle() {
    myDatabase.beginAsync((db) => {
      let locationCity = db.cityDataDao.firstOrNull(it => it.equalTo(TableCityData.key, Constants.LOCATION_CITY_ID))
      Logger.e('locationCity = ' + locationCity)
      if (locationCity == null) {
        locationCity = {
          key: Constants.LOCATION_CITY_ID,
          isLocationCity: true
        }
        db.cityDataDao.add(locationCity)
      }
      let currentCityId = PreferencesUtil.getStringSync(Constants.CURRENT_CITY_ID)
      if (StrUtil.isNotEmpty(locationCity?.cityid) || StrUtil.isNotEmpty(currentCityId)) {
        let currentCity = db.cityDataDao.firstOrNull(it => it.equalTo(TableCityData.key, currentCityId))
        Logger.e('currentCity = ' + currentCity)
        ZRouter.getInstance().replace(RouterConstants.WEATHER_MAIN_PAGE)
      } else {
        ZRouter.getInstance().replace(RouterConstants.SELECT_CITY_PAGE)
      }
    })
  }
}