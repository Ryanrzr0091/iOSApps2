import Foundation
import CoreLocation
import MapKit

struct CrimeResponse: Decodable {
    let features: [CrimeFeature]
}

struct CrimeFeature: Decodable {
    let attributes: CrimeAttributes
    let geometry: CrimeGeometry?
}

struct CrimeGeometry: Decodable {
    let x: Double
    let y: Double
}

struct CrimeAttributes: Decodable {
    let ccn: String?
    let reportDat: Double?
    let shift: String?
    let method: String?
    let offense: String?
    let block: String?
    let ward: String?
    let neighborhoodCluster: String?
    let latitude: Double?
    let longitude: Double?

    enum CodingKeys: String, CodingKey {
        case ccn             = "CCN"
        case reportDat       = "REPORT_DAT"
        case shift           = "SHIFT"
        case method          = "METHOD"
        case offense         = "OFFENSE"
        case block           = "BLOCK"
        case ward            = "WARD"
        case neighborhoodCluster = "NEIGHBORHOOD_CLUSTER"
        case latitude        = "LATITUDE"
        case longitude       = "LONGITUDE"
    }
}

struct CrimeIncident: Identifiable, Hashable {
    let id: String
    let reportDate: Date
    let shift: Shift
    let method: Method
    let offense: OffenseType
    let block: String
    let ward: Int
    let neighborhoodCluster: String
    let coordinate: CLLocationCoordinate2D

    enum Shift: String, CaseIterable, Hashable {
        case day      = "DAY"
        case evening  = "EVENING"
        case midnight = "MIDNIGHT"
        case unknown  = "UNKNOWN"

        var displayName: String {
            switch self {
            case .day:      return "Day"
            case .evening:  return "Evening"
            case .midnight: return "Midnight"
            case .unknown:  return "Unknown"
            }
        }

        var icon: String {
            switch self {
            case .day:      return "sun.max.fill"
            case .evening:  return "sunset.fill"
            case .midnight: return "moon.stars.fill"
            case .unknown:  return "questionmark.circle"
            }
        }
    }

    enum Method: String, CaseIterable, Hashable {
        case gun    = "GUN"
        case knife  = "KNIFE"
        case others = "OTHERS"
        case unknown = "UNKNOWN"

        var displayName: String {
            switch self {
            case .gun:     return "Gun"
            case .knife:   return "Knife"
            case .others:  return "Other"
            case .unknown: return "Unknown"
            }
        }
    }

    enum OffenseType: String, CaseIterable, Hashable {
        case theft          = "THEFT/OTHER"
        case theftFromAuto  = "THEFT F/AUTO"
        case motorVehicle   = "MOTOR VEHICLE THEFT"
        case assault        = "ASSAULT W/DANGEROUS WEAPON"
        case burglary       = "BURGLARY"
        case robbery        = "ROBBERY"
        case arson          = "ARSON"
        case homicide       = "HOMICIDE"
        case sexAbuse       = "SEX ABUSE"
        case unknown        = "UNKNOWN"

        var displayName: String {
            switch self {
            case .theft:         return "Theft"
            case .theftFromAuto: return "Theft from Auto"
            case .motorVehicle:  return "Motor Vehicle Theft"
            case .assault:       return "Assault"
            case .burglary:      return "Burglary"
            case .robbery:       return "Robbery"
            case .arson:         return "Arson"
            case .homicide:      return "Homicide"
            case .sexAbuse:      return "Sex Abuse"
            case .unknown:       return "Unknown"
            }
        }

        var color: String {
            switch self {
            case .theft, .theftFromAuto: return "blue"
            case .motorVehicle:          return "cyan"
            case .assault:               return "orange"
            case .burglary:              return "yellow"
            case .robbery:               return "red"
            case .arson:                 return "purple"
            case .homicide:              return "black"
            case .sexAbuse:              return "pink"
            case .unknown:               return "gray"
            }
        }

        var icon: String {
            switch self {
            case .theft, .theftFromAuto: return "bag.fill"
            case .motorVehicle:          return "car.fill"
            case .assault:               return "figure.walk"
            case .burglary:              return "house.fill"
            case .robbery:               return "exclamationmark.triangle.fill"
            case .arson:                 return "flame.fill"
            case .homicide:              return "cross.fill"
            case .sexAbuse:              return "person.fill.xmark"
            case .unknown:               return "questionmark.circle.fill"
            }
        }
    }

    static func == (lhs: CrimeIncident, rhs: CrimeIncident) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension CrimeIncident {
    static func from(feature: CrimeFeature) -> CrimeIncident? {
        let attrs = feature.attributes

        guard
            let ccn = attrs.ccn,
            let lat = attrs.latitude,
            let lon = attrs.longitude
        else { return nil }

        let date: Date
        if let ms = attrs.reportDat {
            date = Date(timeIntervalSince1970: ms / 1000.0)
        } else {
            date = Date()
        }

        let ward = Int(attrs.ward ?? "0") ?? 0

        return CrimeIncident(
            id: ccn,
            reportDate: date,
            shift: Shift(rawValue: attrs.shift ?? "") ?? .unknown,
            method: Method(rawValue: attrs.method ?? "") ?? .unknown,
            offense: OffenseType(rawValue: attrs.offense ?? "") ?? .unknown,
            block: attrs.block ?? "Unknown Block",
            ward: ward,
            neighborhoodCluster: attrs.neighborhoodCluster ?? "Unknown",
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
        )
    }
}
