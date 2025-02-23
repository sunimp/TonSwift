//
//  Serialization.swift
//  TONSwift
//
//  Created by Sun on 2024/10/22.
//

import Foundation

// MARK: - CellCodable

/// Types implementing both reading and writing
public protocol CellCodable {
    func storeTo(builder: Builder) throws
    static func loadFrom(slice: Slice) throws -> Self
}

// MARK: - StaticSize

/// Types implement KnownSize protocol when they have statically-known size in bits
public protocol StaticSize {
    /// Size of the type in bits
    static var bitWidth: Int { get }
}

// MARK: - TypeCoder

/// Every type that can be used as a dictionary value has an accompanying coder object configured to read that type.
/// This protocol allows implement dependent types because the exact instance would have runtime parameter such as
/// bitlength for the values of this type.
public protocol TypeCoder {
    associatedtype T
    func storeValue(_ src: T, to builder: Builder) throws
    func loadValue(from src: Slice) throws -> T
}

extension CellCodable {
    static func defaultCoder() -> some TypeCoder {
        DefaultCoder<Self>()
    }
}

// MARK: - DefaultCoder

public class DefaultCoder<X: CellCodable>: TypeCoder {
    // MARK: Nested Types

    public typealias T = X

    // MARK: Functions

    public func storeValue(_ src: T, to builder: Builder) throws {
        try src.storeTo(builder: builder)
    }

    public func loadValue(from src: Slice) throws -> T {
        return try T.loadFrom(slice: src)
    }
}

extension TypeCoder {
    /// Serializes type to Cell
    public func serializeToCell(_ src: T) throws -> Cell {
        let b = Builder()
        try storeValue(src, to: b)
        return try b.endCell()
    }
}

// MARK: - BytesCoder

public class BytesCoder: TypeCoder {
    // MARK: Nested Types

    public typealias T = Data

    // MARK: Properties

    let size: Int
    
    // MARK: Lifecycle

    init(size: Int) {
        self.size = size
    }
    
    // MARK: Functions

    public func storeValue(_ src: T, to builder: Builder) throws {
        try builder.store(data: src)
    }

    public func loadValue(from src: Slice) throws -> T {
        return try src.loadBytes(size)
    }
}

// MARK: - Cell + CellCodable

/// Cell is encoded as a separate ref
extension Cell: CellCodable {
    public func storeTo(builder: Builder) throws {
        try builder.store(ref: self)
    }
    
    public static func loadFrom(slice: Slice) throws -> Self {
        return try slice.loadRef()
    }
}

// MARK: - Slice + CellCodable

/// Slice is encoded inline
extension Slice: CellCodable {
    public func storeTo(builder: Builder) throws {
        try builder.store(slice: self)
    }
    
    public static func loadFrom(slice: Slice) throws -> Self {
        return slice.clone() as! Self
    }
}

// MARK: - Builder + CellCodable

/// Builder is encoded inline
extension Builder: CellCodable {
    public func storeTo(builder: Builder) throws {
        try builder.store(slice: endCell().beginParse())
    }
    
    public static func loadFrom(slice: Slice) throws -> Self {
        return try slice.clone().toBuilder() as! Self
    }
}

// MARK: - Empty

/// Empty struct to store empty leafs in the dictionaries to form sets.
public struct Empty: CellCodable {
    // MARK: Static Functions

    public static func loadFrom(slice _: Slice) throws -> Self {
        return Empty()
    }

    // MARK: Functions

    public func storeTo(builder _: Builder) throws {
        // store nothing
    }
}
