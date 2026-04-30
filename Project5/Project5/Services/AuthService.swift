import Foundation
import Combine
import FirebaseAuth

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case wrongPassword
    case userNotFound
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail:       return "Please enter a valid email address."
        case .weakPassword:       return "Password must be at least 6 characters."
        case .emailAlreadyInUse:  return "An account with this email already exists."
        case .wrongPassword:      return "Incorrect password. Please try again."
        case .userNotFound:       return "No account found with this email."
        case .unknown(let msg):   return msg
        }
    }

    static func from(_ error: Error) -> AuthError {
        let code = AuthErrorCode(rawValue: (error as NSError).code)
        switch code {
        case .invalidEmail:        return .invalidEmail
        case .weakPassword:        return .weakPassword
        case .emailAlreadyInUse:   return .emailAlreadyInUse
        case .wrongPassword:       return .wrongPassword
        case .userNotFound:        return .userNotFound
        default:                   return .unknown(error.localizedDescription)
        }
    }
}

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() throws
}

final class AuthService: AuthServiceProtocol {

    var currentUser: User? {
        Auth.auth().currentUser
    }

    func signIn(email: String, password: String) async throws {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw AuthError.from(error)
        }
    }

    func signUp(email: String, password: String) async throws {
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            throw AuthError.from(error)
        }
    }

    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw AuthError.from(error)
        }
    }
}
