# EFoundation

A small set of tools that I use in my pet projects to simplify the routine

# EFNetwork
A set of classes for working with the network. Small, lightweight networking library. It covers the tasks that I need. The main requirements I had:
- Working with async/await
- Possibility to have a fallback
- Ability to decode different DTOs to different response codes
  
## Creating Network Manager

```swift
func makeManager() -> EFNetworkManager {
    return EFNetworkManager(
        session: URLSession.shared,
        requestInterceptors: [],
        responseInterceptors: []
    )
}
```
or just

```swift
return EFNetworkManager.default
```

## Making Network request
```swift
struct NetworkRequest: Encodable {
    let username: String
    let password: String
}

struct NetworkResponse: Decodable {
    let greetingText: String
}

struct NetworkRequestExample {
    let networkManager: EFNetworkManager

    func authorize(
        username: String,
        password: String
    ) async -> Bool {
        let body = NetworkRequest(
            username: username,
            password: password
        )

        return await networkManager
            .get(url: )
            .postAsync(url: "https://yourdomain.com/api/v1/authrize", body: body)
            .handle(statusCode: 200, of: NetworkResponse.self) { response in
                print(response.greetingText)
                return true
            }
            .fallback {
                return false
            }
    }
}
```

or if you dont need to decode any response DTO

```swift
func status(for id: Int) async -> String {
        return await networkManager
            .get(url: "https://yourdomain.com/api/v1/status/\(id)")
            .handleCode(200) {
                return "Completed!"
            }
            .handleCode(200) {
                return "Not found"
            }
            .fallback {
                return "Something went wrong"
            }
    }
```

## Inteceptors

You could create intecepters, if you need it

Basic interceptor for authenticating requests:

```swift
struct AuthInterceptor: EFRequestInterceptor {
    let token: String
    
    public func intercept(request: URLRequest) -> URLRequest {
        var copy = request
        copy.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return copy
    }
}

// And pass this intercepter to Network Manager (see Creating Network Manager)
func makeManager() -> EFNetworkManager {
    return EFNetworkManager(
        session: URLSession.shared,
        requestInterceptors: [AuthInterceptor("some token")],
        responseInterceptors: []
    )
}
```

## EFStorage

A set of classes for working with persistent storage. What was needed:
- Be able to save any Codable structures (or classes 🤔) in different ways
- Three basic storages: UserDefaults, Keychain and write to file
- Work with them in the same way

In all examples, we will work with the following structure:
```swift
struct User {
    let name: String
    let age: Int
}
```

## Storages

We have 2 type of storages: `EFSingleValueStorage` and `EFMultiValueStorage`.
- `EFSingleValueStorage` saves only one instance, instead giving you access to it without an Id (handy for storing information that is the same throughout the application, for example, Credentials for network requests)
- `EFMultiValueStorage` saves any amount of instances you want, but separates access to them by id

## Types of Storages
- `.userDefaults` - writes to UserDefaults...
- `.file` - wirtes all data to file
- `.security` - writes to keychain

All these storage can be obtained through the factory EFStorageFactory

Creating single-value Storages
- `EFStorageFactory<User>.singleValueStorage.userDefaults` - stores single user in UserDefaults
- `EFStorageFactory<User>.singleValueStorage.file` - stores single user in single file
- `EFStorageFactory<User>.singleValueStorage.security` - stores single user in keychain

Creating multi-value Storages
- `EFStorageFactory<User>.singleValueStorage.userDefaults` - stores multiply users in UserDefaults
- `EFStorageFactory<User>.singleValueStorage.file` - stores multiply users in multiply files
- `EFStorageFactory<User>.singleValueStorage.security` - stores multiply users in keychain

## It is also important to note that the same User can be in both single-value storage and multi-value storage. In other words - single-value storage and multi-value storage spaces do not intersect
  
## Saving item
```swift
func save(user: User) {
    let storage = EFStorageFactory<EFStorageTestStruct>.singleValueStorage.file
    storage.save(user)
}
```
or
```swift
func save(user: User) {
    let storage = EFStorageFactory<EFStorageTestStruct>.multiValueStorage.file
    storage.save(user, id: "some-id")
}
```
simple, right? 🥺👉👈

## Restoring item
```swift
func greetUser() -> String {
    guard let user = EFStorageFactory<EFStorageTestStruct>.singleValueStorage.file.restore() else {
        assertionFailure()("User not found")
        return "Hello, unknown user!"
    }
    return "Hello, \(user.name)"
}
```
or
```swift
func greetUser(with id: String) -> String {
    guard let user = EFStorageFactory<EFStorageTestStruct>.multiValueStorage.file.restore(id: id)
    else {
        assertionFailure()("User not found")
        return "Hello, unknown user!"
    }
    return "Hello, \(user.name)"
}
```

## Type Erasure

If we need example of Storage in our class, I wrote a type-erasure for specializing Storage Type

```swift
struct UserProvider {
    let storage: AnyEFSingleValueStorage<User>

    func updateUser(_ user: User) {
        storage.save(user)
    }

    func isUserExists() -> Bool {
        return user = storage.restore() != nil
    }
}

// usage
let storage = EFStorageFactory<User>.singleValueStorage.security
let provider = UserProvider(
    storage: AnyEFSingleValueStorage(storage)
)
```
