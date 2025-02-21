import { Database, DatabaseDao, RdbStoreWrapper, SQL } from '@zxhhyj/storm';
import { relationalStore } from '@kit.ArkData';
import { cityDataTable } from './model/CityData';
import { simpleWeatherDataTable } from './model/SimpleWeatherData';

class AppDatabase extends Database {
  readonly cityDataDao = DatabaseDao.form(this).select(cityDataTable)
  readonly simpleWeatherDataDao = DatabaseDao.form(this).select(simpleWeatherDataTable)

  protected initDb(context: Context): Promise<relationalStore.RdbStore> {
    return relationalStore.getRdbStore(context, { name: "app.db", securityLevel: relationalStore.SecurityLevel.S1 })
  }

  protected onCreate(): void {
  }

  protected onDatabaseCreate(rdbStore: RdbStoreWrapper): void {
    rdbStore.executeSync(SQL.createTableAndIndex(cityDataTable))
    rdbStore.executeSync(SQL.createTableAndIndex(simpleWeatherDataTable))
  }
}

export const appDatabase = new AppDatabase(1)