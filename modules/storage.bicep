param namePrefix string

module coreStorage 'br/public:avm/res/storage/storage-account:0.32.1' = {
  params: {
    name: '${namePrefix}-storage-account'
    allowBlobPublicAccess: false
  }
}
