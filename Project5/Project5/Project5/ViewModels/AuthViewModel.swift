import Foundation
import Combine
import FirebaseAuth

enum AuthState {
    case loading
    case signedOut
    case signedIn(User)
}

enum AuthFormMode {
    case login
    case signUp

    var title: String {
        switch self {
        case .login:  return "Sign In"
        case .signUp: return "Create Account"
        }
    }

    var buttonLabel: String {
        switch self {
        case .login:  return "Sign In"
        case .signUp: return "Create Account"
        }
    }

    var togglePrompt: String {
        switch self {
        case .login:  return "Don't have an account?"
        case .signUp: return "Already have an account?"
        }
    }

    var toggleLabel: String {
        switch self {
        case .login:  return "Sign Up"
        case .signUp: return "Sign In"
        }
    }
}

final class AuthViewModel: ObservableObject {

    @Published private(set) var authState: AuthState = .loading
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let service: AuthServiceProtocol
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init(service: AuthServiceProtocol = AuthService()) {
        self.service = service
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.authState = .signedIn(user)
                } else {
                    self?.authState = .signedOut
                }
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signIn(email: String, password: String) async {
        guard validate(email: email, password: password) else { return }
        await MainActor.run { isLoading = true; errorMessage = nil }
        do {
            try await service.signIn(email: email, password: password)
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
        await MainActor.run { isLoading = false }
    }

    func signUp(email: String, password: String) async {
        guard validate(email: email, password: password) else { return }
        await MainActor.run { isLoading = true; errorMessage = nil }
        do {
            try await service.signUp(email: email, password: password)
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
        await MainActor.run { isLoading = false }
    }

    func signOut() {
        errorMessage = nil
        do {
            try service.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }

    var currentUserEmail: String? {
        if case .signedIn(let user) = authState {
            return user.email
        }
        return nil
    }

    private func validate(email: String, password: String) -> Bool {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            DispatchQueue.main.async { self.errorMessage = "Please enter your email." }
            return false
        }
        guard !password.isEmpty else {
            DispatchQueue.main.async { self.errorMessage = "Please enter your password." }
            return false
        }
        guard password.count >= 6 else {
            DispatchQueue.main.async { self.errorMessage = "Password must be at least 6 characters." }
            return false
        }
        return true
    }
}
