//
//  Error+ Extension.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

struct EquatableError: Error, Equatable, CustomStringConvertible {
    
    private let equals: (Error) -> Bool
    let base: Error

    init<Base: Error>(_ base: Base) {
        self.base = base
        self.equals = { String(reflecting: $0) == String(reflecting: base) }
    }

    init<Base: Error & Equatable>(_ base: Base) {
        self.base = base
        self.equals = { ($0 as? Base) == base }
    }

    static func ==(lhs: EquatableError, rhs: EquatableError) -> Bool {
        return lhs.equals(rhs.base)
    }

    var description: String {
        return "\(self.base)"
    }

    func asError<Base: Error>(type: Base.Type) -> Base? {
        return self.base as? Base
    }

    var localizedDescription: String {
        return self.base.localizedDescription
    }
}

extension Error where Self: Equatable {
    
    func toEquatableError() -> EquatableError {
        return EquatableError(self)
    }
}

extension Error {
    
    func toEquatableError() -> EquatableError {
        return EquatableError(self)
    }
}
