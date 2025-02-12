@ObservedV2
export class ResultData<T> {
  code = 0
  msg = ''
  @Trace data?: T

  constructor(code: number, msg: string, data?: T) {
    this.code = code
    this.msg = msg
    this.data = data
  }
}