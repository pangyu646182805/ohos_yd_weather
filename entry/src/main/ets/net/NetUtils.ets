import axios, {
  AxiosHeaders,
  AxiosInstance,
  AxiosRequestConfig,
  AxiosResponse,
  InternalAxiosRequestConfig
} from "@ohos/axios";
import { ResultData } from "./ResultData";

export type NetParamType = string | number | boolean

export default class NetUtils {
  private axiosInstance: AxiosInstance = axios.create({
    // 设置超时时间
    timeout: 15000,
    readTimeout: 15000,
    connectTimeout: 15000,
    headers: {
      'Content-Type': 'application/json;charset=utf-8',
      'Content-Language': 'zh_CN'
    },
  });

  constructor() {
    this.axiosInstance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
      return config
    })
    this.axiosInstance.interceptors.response.use((response: AxiosResponse) => {
      return response
    })
  }

  private axiosGet<T>(url: string, axiosConfig: AxiosRequestConfig): Promise<T> {
    return this.axiosInstance.get<T, AxiosResponse<T>, null>(url, axiosConfig).then((response: AxiosResponse<T>) => {
      const data = response.data
      if (!data) {
        Promise.reject(new Error('response data is null'))
      }
      return data
    }).catch((error: Error) => {
      return Promise.reject(error)
    })
  }

  netGetT<T>(url: string, params?: Map<string, NetParamType>,
    headers?: Map<string, string>): Promise<T> {
    // 请求参数
    const axiosParams = new Map<string, NetParamType>()
    if (params && params.size > 0) {
      params.forEach((value, key, _) => {
        axiosParams[key] = value
      })
    }
    // 请求头
    const axiosHeaders = new AxiosHeaders()
    if (headers && headers.size > 0) {
      headers.forEach((value, key, _) => {
        axiosHeaders.set(key, value)
      })
    }
    const axiosRequestConfig: AxiosRequestConfig = {
      headers: axiosHeaders,
      params: axiosParams
    }
    return this.axiosGet<T>(url, axiosRequestConfig)
  }

  netGet<T>(url: string, params?: Map<string, NetParamType>,
    headers?: Map<string, string>): Promise<ResultData<T>> {
    return this.netGetT<ResultData<T>>(url, params, headers)
  }

  private axiosPost<T>(url: string, params: string, axiosConfig: AxiosRequestConfig): Promise<T> {
    return this.axiosInstance.post<T, AxiosResponse<T>, string>(url, params,
      axiosConfig).then((response: AxiosResponse<T>) => {
      const data = response.data
      if (!data) {
        Promise.reject(new Error('response data is null'))
      }
      return data
    }).catch((error: Error) => {
      return Promise.reject(error)
    })
  }

  netPost<T>(url: string, params?: Map<string, NetParamType>, headers?: Map<string, string>): Promise<ResultData<T>> {
    let formParams = ''
    if (params && params.size > 0) {
      const formArray: string[] = []
      params.forEach((value, key, _) => {
        const encodedKey = encodeURIComponent(key)
        const encodeValue = encodeURIComponent(value)
        formArray.push(`${encodedKey}=${encodeValue}`)
      })
      formParams = formArray.join('&')
    }
    const axiosHeaders = new AxiosHeaders().set('Content-Type', 'application/x-www-form-urlencoded')
    if (headers && headers.size > 0) {
      headers.forEach((value, key, _) => {
        axiosHeaders.set(key, value)
      })
    }
    const axiosRequestConfig: AxiosRequestConfig = {
      headers: axiosHeaders
    }
    return this.axiosPost<ResultData<T>>(url, formParams, axiosRequestConfig)
  }
}

export const netUtils = new NetUtils()