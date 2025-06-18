import { ZRouter } from "@hzw/zrouter"
import { AbilityStage } from "@kit.AbilityKit"
import { ImageKnife } from "@ohos/imageknife"
import BuildProfile from "BuildProfile"
import { appDatabase } from "../db/AppDatabase"

export class AppAbilityStage extends AbilityStage {
  async onCreate(): Promise<void> {
    // 应用HAP首次加载时触发，可以在此执行该Module的初始化操作（例如资源预加载、线程创建等）。
    // 在module.json5配置文件中，通过配置 srcEntry 参数来指定模块对应的代码路径，以作为HAP加载的入口。
    // 初始化路由
    ZRouter.initialize((config) => {
      config.isLoggingEnabled = BuildProfile.DEBUG
      config.isHSPModuleDependent = true
      // 服务路由初始化配置，如果没有使用服务路由，可不设置
      // config.loadDynamicModule = ['@hzw/hara', 'harb', 'hspc']
      config.onDynamicLoadComplete = () => {
        console.log("已完成所有模块的加载")
      }
    })

    await appDatabase.init(this.context)
    await ImageKnife.getInstance().initFileCache(this.context, 256, 256 * 1024 * 1024)
  }
}