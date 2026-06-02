param namePrefix string
param storageSku string

module coreStorage 'br/public:avm/res/storage/storage-account:0.32.1' = {
  params: {
    name: '${namePrefix}CoreStorage'
    allowBlobPublicAccess: false
    kind: 'StorageV2'
    skuName: storageSku
  }
}
