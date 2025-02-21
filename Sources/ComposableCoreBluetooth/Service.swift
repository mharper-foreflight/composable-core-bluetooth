//
//  Service.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 15.07.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth
import ComposableArchitecture

public struct Service: Sendable {

    @UncheckedSendable public private(set) var rawValue: CBService?
    public let identifier: UUID
    public let isPrimary: Bool
    public var characteristics: @Sendable () -> [Characteristic]
    public var includedServices: [Service]
    
    init(from service: CBService) {
        rawValue = service
        identifier = service.uuid.uuidValue
        isPrimary = service.isPrimary
        characteristics = { service.characteristics?.map(Characteristic.init) ?? [] }
        includedServices = service.includedServices?.map(Service.init) ?? []
    }
    
    init(
        identifier: CBUUID,
        isPrimary: Bool,
        characteristics: @escaping @Sendable () -> [Characteristic],
        includedServices: [Service]
    ) {
        rawValue = nil
        self.identifier = identifier.uuidValue
        self.isPrimary = isPrimary
        self.characteristics = characteristics
        self.includedServices = includedServices
    }
}

extension Service {
    
    init?(from service: CBService?) {
        guard let service else { return nil }
        self.init(from: service)
    }
}

extension Service {
    
    public enum Action: Equatable, Sendable {
        case didDiscoverIncludedServices(Result<[Service], BluetoothError>)
        case didDiscoverCharacteristics(Result<[Characteristic], BluetoothError>)
    }
}

extension Service {
    public static func mock(
        identifier: CBUUID,
        isPrimary: Bool,
        characteristics: @Sendable @escaping () -> [Characteristic],
        includedServices: [Service]
    ) -> Self {
        Self(
            identifier: identifier,
            isPrimary: isPrimary,
            characteristics: characteristics,
            includedServices: includedServices
        )
    }
}

extension Service: Identifiable {
    public var id: UUID {
        return identifier
    }
}

extension Service: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
        hasher.combine(identifier)
        hasher.combine(isPrimary)
        // including everything but characteristics
        // hasher.combine(characteristics)
        hasher.combine(includedServices)
    }
}

extension Service: Equatable {
    public static func == (lhs: Service, rhs: Service) -> Bool {
        lhs.rawValue == rhs.rawValue &&
            lhs.identifier == rhs.id &&
            lhs.isPrimary == rhs.isPrimary &&
            lhs.characteristics() == rhs.characteristics() &&
            lhs.includedServices == rhs.includedServices
    }
}
