import SwiftUI

struct LoginView: View {

    @EnvironmentObject private var authVM: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var mode: AuthFormMode = .login
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                    .padding(.bottom, 40)

                formCard
                    .padding(.horizontal, 24)

                toggleMode
                    .padding(.top, 20)
            }
            .padding(.top, 60)
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea()
        .onTapGesture { focusedField = nil }
        .alert("Error", isPresented: .constant(authVM.errorMessage != nil)) {
            Button("OK") { authVM.clearError() }
        } message: {
            Text(authVM.errorMessage ?? "")
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 56))
                .foregroundStyle(.red)

            Text("DC Crime Watch")
                .font(.largeTitle.bold())

            Text("Real-time crime data for Washington D.C.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var formCard: some View {
        VStack(spacing: 16) {
            Text(mode.title)
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)

                TextField("you@example.com", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
                    .padding(12)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)

                SecureField("At least 6 characters", text: $password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.done)
                    .onSubmit { submitForm() }
                    .padding(12)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
            }

            Button {
                submitForm()
            } label: {
                Group {
                    if authVM.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(mode.buttonLabel)
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(.red, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
            }
            .disabled(authVM.isLoading)
            .padding(.top, 4)
        }
        .padding(20)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }

    private var toggleMode: some View {
        HStack(spacing: 4) {
            Text(mode.togglePrompt)
                .foregroundStyle(.secondary)
            Button(mode.toggleLabel) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    mode = mode == .login ? .signUp : .login
                    authVM.clearError()
                    password = ""
                }
            }
            .fontWeight(.semibold)
            .foregroundStyle(.red)
        }
        .font(.subheadline)
    }

    private func submitForm() {
        focusedField = nil
        Task {
            switch mode {
            case .login:  await authVM.signIn(email: email, password: password)
            case .signUp: await authVM.signUp(email: email, password: password)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
