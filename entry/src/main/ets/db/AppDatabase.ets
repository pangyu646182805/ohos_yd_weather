import { Database, Storm, AutoMigration } from '@zxhhyj/storm';
import { relationalStore } from '@kit.ArkData';
import { TableCityData } from './model/CityData';

class AppDatabase extends Database {
  initDb(context: Context): Promise<relationalStore.RdbStore> {
    return relationalStore.getRdbStore(context, { name: "app.db", securityLevel: relationalStore.SecurityLevel.S1 })
  }

  readonly cityDataDao = TableCityData
}

export const myDatabase = Storm
  .databaseBuilder(AppDatabase)
  .setVersion(1)// 设置数据库的版本
  .addMigrations(AutoMigration)// 设置当数据库未初始化时自动初始化，初始化后的版本号为 setVersion 设置版本号，即 1
  .build()