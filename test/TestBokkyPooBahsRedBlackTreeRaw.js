var testRawOutput={
  "contracts":
  {
    "BokkyPooBahsRedBlackTreeLibrary.sol:BokkyPooBahsRedBlackTreeLibrary":
    {
      "abi": "[]",
      "bin": "60566023600b82828239805160001a607314601657fe5b30600052607381538281f3fe73000000000000000000000000000000000000000030146080604052600080fdfea264697066735822122098ee152869d6b1cb2dd7c0ab450b9b9e0a5a794be046d2bf6caf813754ccabc964736f6c63430006000033"
    },
    "TestBokkyPooBahsRedBlackTreeRaw.sol:TestBokkyPooBahsRedBlackTreeRaw":
    {
      "abi": "[{\"inputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"string\",\"name\":\"where\",\"type\":\"string\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"key\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"Log\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"key\",\"type\":\"uint256\"}],\"name\":\"exists\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"_exists\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"first\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"_key\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"_key\",\"type\":\"uint256\"}],\"name\":\"getNode\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"key\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"parent\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"left\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"right\",\"type\":\"uint256\"},{\"internalType\":\"bool\",\"name\":\"red\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"_key\",\"type\":\"uint256\"}],\"name\":\"insert\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"last\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"_key\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"key\",\"type\":\"uint256\"}],\"name\":\"next\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"_key\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"key\",\"type\":\"uint256\"}],\"name\":\"prev\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"_key\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"_key\",\"type\":\"uint256\"}],\"name\":\"remove\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"root\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"_key\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"}]",
      "bin": "608060405234801561001057600080fd5b5061112b806100206000396000f3fe608060405234801561001057600080fd5b50600436106100935760003560e01c80634f0f4aa9116100665780634f0f4aa9146100f65780634f558e791461014057806390b5561d14610171578063ebf0c7171461018e578063edd004e51461019657610093565b806335671214146100985780633df4ddf4146100c757806347799da8146100cf5780634cc82215146100d7575b600080fd5b6100b5600480360360208110156100ae57600080fd5b50356101b3565b60408051918252519081900360200190f35b6100b56101cb565b6100b56101dc565b6100f4600480360360208110156100ed57600080fd5b50356101e8565b005b6101136004803603602081101561010c57600080fd5b50356101fc565b60408051958652602086019490945284840192909252606084015215156080830152519081900360a00190f35b61015d6004803603602081101561015657600080fd5b5035610224565b604080519115158252519081900360200190f35b6100f46004803603602081101561018757600080fd5b5035610236565b6100b5610247565b6100b5600480360360208110156101ac57600080fd5b503561024d565b60006101c5818363ffffffff61025f16565b92915050565b60006101d760006102fc565b905090565b60006101d7600061033c565b6101f960008263ffffffff61037716565b50565b600080808080610212818763ffffffff6105a516565b939a9299509097509550909350915050565b60006101c5818363ffffffff6105f516565b6101f960008263ffffffff61062616565b60005490565b60006101c5818363ffffffff61074016565b60008161026b57600080fd5b6000828152600180850160205260409091200154156102aa5760008281526001808501602052604090912001546102a39084906107d6565b90506101c5565b5060008181526001830160205260409020545b80158015906102de5750600081815260018085016020526040909120015482145b156101c55760008181526001840160205260409020549091506102bd565b80548015610337575b600081815260018084016020526040909120015415610337576000908152600180830160205260409091200154610305565b919050565b80548015610337575b600081815260018301602052604090206002015415610337576000908152600182016020526040902060020154610345565b8061038157600080fd5b61038b82826105f5565b61039457600080fd5b60008181526001808401602052604082200154819015806103c657506000838152600185016020526040902060020154155b156103d257508161041a565b5060008281526001840160205260409020600201545b60008181526001808601602052604090912001541561041a5760009081526001808501602052604090912001546103e8565b60008181526001808601602052604090912001541561044e5760008181526001808601602052604090912001549150610465565b600081815260018501602052604090206002015491505b600081815260018501602052604080822054848352912081905580156104d75760008181526001808701602052604090912001548214156104bb57600081815260018087016020526040909120018390556104d2565b600081815260018601602052604090206002018390555b6104db565b8285555b600082815260018601602052604090206003015460ff161584831461056557610505868487610813565b60008581526001878101602052604080832080830154878552828520938401819055845281842087905560028082015490840181905584529083208690556003908101549286905201805460ff191660ff90921615159190911790559193915b801561057557610575868561088a565b5050600090815260019384016020526040812081815593840181905560028401555050600301805460ff19169055565b60008060008060006105b787876105f5565b6105c057600080fd5b505050600083815260019485016020526040902080549481015460028201546003909201549496909491935060ff9091169150565b6000811580159061061f5750825482148061061f5750600082815260018401602052604090205415155b9392505050565b8061063057600080fd5b61063a82826105f5565b1561064457600080fd5b81546000905b801561068e5780915080831015610674576000908152600180850160205260409091200154610689565b60009081526001840160205260409020600201545b61064a565b60408051608081018252838152600060208083018281528385018381526001606086018181528a86528b82019094529590932093518455519383019390935551600282015590516003909101805460ff1916911515919091179055816106f657828455610730565b818310156107195760008281526001808601602052604090912001839055610730565b600082815260018501602052604090206002018390555b61073a8484610ca5565b50505050565b60008161074c57600080fd5b6000828152600184016020526040902060020154156107845760008281526001840160205260409020600201546102a3908490610f10565b5060008181526001830160205260409020545b80158015906107b85750600081815260018401602052604090206002015482145b156101c5576000818152600184016020526040902054909150610797565b60005b60008281526001840160205260409020600201541561080d57600091825260018301602052604090912060020154906107d9565b50919050565b60008181526001840160205260408082205484835291208190558061083a5782845561073a565b6000818152600180860160205260409091200154821415610870576000818152600180860160205260409091200183905561073a565b600090815260019390930160205250604090912060020155565b60005b825482148015906108b25750600082815260018401602052604090206003015460ff16155b15610c86576000828152600180850160205260408083205480845292200154831415610aaf5760008181526001850160205260408082206002015480835291206003015490925060ff1615610956576000828152600180860160205260408083206003908101805460ff1990811690915585855291909320909201805490921617905561093f8482610f48565b600081815260018501602052604090206002015491505b60008281526001808601602052604080832090910154825290206003015460ff161580156109a15750600082815260018501602052604080822060020154825290206003015460ff16155b156109ce57600082815260018581016020526040909120600301805460ff19169091179055915081610aaa565b600082815260018501602052604080822060020154825290206003015460ff16610a4b576000828152600180860160205260408083208083015484529083206003908101805460ff1990811690915593869052018054909216179055610a348483611020565b600081815260018501602052604090206002015491505b600081815260018501602052604080822060039081018054868552838520808401805460ff909316151560ff199384161790558254821690925560029091015484529190922090910180549091169055610aa58482610f48565b835492505b610c80565b6000818152600180860160205260408083209091015480835291206003015490925060ff1615610b2e576000828152600180860160205260408083206003908101805460ff19908116909155858552919093209092018054909216179055610b178482611020565b600081815260018086016020526040909120015491505b600082815260018501602052604080822060020154825290206003015460ff16158015610b79575060008281526001808601602052604080832090910154825290206003015460ff16155b15610ba657600082815260018581016020526040909120600301805460ff19169091179055915081610c80565b60008281526001808601602052604080832090910154825290206003015460ff16610c2557600082815260018086016020526040808320600281015484529083206003908101805460ff1990811690915593869052018054909216179055610c0e8483610f48565b600081815260018086016020526040909120015491505b60008181526001808601602052604080832060039081018054878652838620808401805460ff909316151560ff19938416179055825482169092559301548452922090910180549091169055610c7b8482611020565b835492505b5061088d565b506000908152600190910160205260409020600301805460ff19169055565b60005b82548214801590610cd25750600082815260018401602052604080822054825290206003015460ff165b15610eee576000828152600180850160205260408083205480845281842054845292200154811415610df55760008181526001850160205260408082205482528082206002015480835291206003015490925060ff1615610d7b576000818152600180860160205260408083206003808201805460ff19908116909155878652838620820180548216905582548652928520018054909216909217905590829052549250610df0565b6000818152600185016020526040902060020154831415610da357809250610da38484610f48565b50600082815260018085016020526040808320548084528184206003808201805460ff19908116909155825487529386200180549093169093179091559182905254610df0908590611020565b610ee8565b6000818152600180860160205260408083205483528083209091015480835291206003015490925060ff1615610e73576000818152600180860160205260408083206003808201805460ff19908116909155878652838620820180548216905582548652928520018054909216909217905590829052549250610ee8565b6000818152600180860160205260409091200154831415610e9b57809250610e9b8484611020565b50600082815260018085016020526040808320548084528184206003808201805460ff19908116909155825487529386200180549093169093179091559182905254610ee8908590610f48565b50610ca8565b505080546000908152600190910160205260409020600301805460ff19169055565b60005b60008281526001808501602052604090912001541561080d576000918252600180840160205260409092209091015490610f13565b600081815260018084016020526040808320600281018054915482865292852090930154938590529183905590918015610f9057600081815260018601602052604090208490555b6000838152600186016020526040902082905581610fb057828555610ffd565b6000828152600180870160205260409091200154841415610fe65760008281526001808701602052604090912001839055610ffd565b600082815260018601602052604090206002018390555b505060008181526001938401602052604080822090940183905591825291902055565b6000818152600180840160205260408083209182018054925483855291842060020154938590528390559091801561106657600081815260018601602052604090208490555b6000838152600186016020526040902082905581611086578285556110d3565b60008281526001860160205260409020600201548414156110bc57600082815260018601602052604090206002018390556110d3565b600082815260018087016020526040909120018390555b505060008181526001909301602052604080842060020183905591835291205556fea2646970667358221220e572d526f2258b67c3cca465417b834661cd11f04670165f19454d72595df53364736f6c63430006000033"
    }
  },
  "version": "0.6.0+commit.26b70077.Darwin.appleclang"
};
