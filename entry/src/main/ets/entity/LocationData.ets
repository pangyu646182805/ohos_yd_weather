export interface LocationData {
  address?: string
  address_component?: AddressComponentData
}

export interface AddressComponentData {
  nation?: string
  province?: string
  city?: string
  district?: string
  street?: string
  street_number?: string
}