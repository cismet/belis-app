
import Foundation



class GeoBaseEntity {
    var id=random()
    
}


var searchResults=[String: [GeoBaseEntity]]()

var e1=GeoBaseEntity()
var e2=GeoBaseEntity()



searchResults.updateValue([e1], forKey: "aa")
searchResults.updateValue([e1], forKey: "ab")
searchResults.updateValue([e1], forKey: "xb")

searchResults


if let arr=searchResults["aa"] {
    var xx=searchResults["aa"]!
    xx.append(e2)
}

searchResults["aa"]


if let arr=searchResults["aa"] {
    searchResults["aa"]!.append(e2)
}

searchResults["aa"]
