import SwiftUI
import Lottie

struct SignupSuccessPage: View {
    @EnvironmentObject private var router: Router

    var body: some View {
        VStack {
            LottieView(animation: .named("checkAnimation"))
                .playing()
                .frame(width: 300, height: 300)
                .padding(-50)
            Text("Registrierung Erfolgreich!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text("Sie haben sich erfolgreich registriert.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            PrimaryButton(
                title: "Zur Startseite",
                color: Styleguide.PrimaryColor.purple,
                action: {
                    router.push(.homePage)
                }
            )
        }
        .padding()
        .navigationBarHidden(true)
    }
}
