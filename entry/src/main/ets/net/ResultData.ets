@ObservedV2
export class ResultData<T> {
  code = 0
  msg = ''
  @Trace data?: T
  @Trace result?: T

  constructor(code: number, msg: string, data?: T, result?: T) {
    this.code = code
    this.msg = msg
    this.result = result
  }
}