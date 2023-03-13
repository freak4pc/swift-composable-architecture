@_spi(Reflection) import CasePaths

extension DependencyValues {
  @usableFromInline
  var navigationID: NavigationID {
    get { self[NavigationIDKey.self] }
    set { self[NavigationIDKey.self] = newValue }
  }
}

private enum NavigationIDKey: DependencyKey {
  static let liveValue = NavigationID()
  static let testValue = NavigationID()
}

public struct NavigationID: Hashable, Identifiable, Sendable {
  var path: [AnyID]

  init(path: [AnyID]) {
    self.path = path
  }

  public init() {
    self.path = []
  }

  var prefixes: [NavigationID] {
    (0...self.path.count).map { index in
      NavigationID(path: Array(self.path.dropFirst(index)))
    }
  }

  @usableFromInline
  func appending(_ element: AnyID) -> Self {
    .init(path: self.path + [element])
  }

  public var id: Self { self }
}

public struct AnyID: Hashable, Identifiable, @unchecked Sendable {
  private let keyPath: AnyKeyPath?
  private let identifier: AnyHashableSendable?
  private let tag: UInt32?

  @usableFromInline
  init<Base>(
    base: Base,
    keyPath: AnyKeyPath?
  ) {
    self.keyPath = keyPath
    self.tag = EnumMetadata(Base.self)?.tag(of: base)
    if let id = _identifiableID(base) ?? EnumMetadata.project(base).flatMap(_identifiableID) {
      self.identifier = AnyHashableSendable(id)
    } else {
      self.identifier = nil
    }
  }

  public var id: Self { self }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.keyPath == rhs.keyPath
      && lhs.identifier == rhs.identifier
      && lhs.tag == rhs.tag
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.keyPath)
    hasher.combine(self.identifier)
    hasher.combine(self.tag)
  }
}

@usableFromInline
struct AnyHashableSendable: Hashable, @unchecked Sendable {
  @usableFromInline
  let base: AnyHashable

  @usableFromInline
  init<Base: Hashable & Sendable>(_ base: Base) {
    self.base = base
  }
}