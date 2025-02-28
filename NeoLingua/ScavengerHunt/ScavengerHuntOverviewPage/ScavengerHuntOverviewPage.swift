import SwiftUI

struct ScavengerHuntOverviewPage<ViewModel>: View where ViewModel: ScavengerHuntOverviewPageViewModel {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ViewModel
    @State var initialAppearance = false
    
    var body: some View {
        VStack {
            ScrollView {
                if viewModel.scavengerHuntType == .competitiveMode && viewModel.currentScavengerHunt == nil  {
                    Text("ⓘ Choose a scavenger hunt near your location")
                    Text("CompetitiveScavengerHunt List")
                    ForEach(Array(viewModel.competitiveScavengerHunts.enumerated()), id: \.element.id ) { index, scavengerHunt in
                        HStack {
                            Text("\(index + 1).")
                            Button(scavengerHunt.title) {
                                viewModel.currentScavengerHunt = scavengerHunt
                                Task {
                                    await viewModel.setupscavengerHunt()
                                }
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    if let currentScavengerHunt = viewModel.currentScavengerHunt {
                        PageHeader(
                            title: currentScavengerHunt.title,
                            subtitle: currentScavengerHunt.introduction,
                            textAlignment: .leading
                        ).padding(.bottom, Styleguide.Margin.medium)
                        
                        Text("Location").font(.headline)
                        VStack(alignment: .leading, spacing: Styleguide.Margin.small) {
                            if let scavengerHunt = viewModel.currentScavengerHunt {
                                ForEach(scavengerHunt.taskLocations) { location in
                                    Text("📍\(location.name)").multilineTextAlignment(.leading)
                                }
                            }
                        }.padding(.bottom, Styleguide.Margin.medium)
                        
                        HStack {
                            Spacer()
                            Button {
                                if let scavengerHunt = viewModel.currentScavengerHunt {
                                    router.scavengerHunt = scavengerHunt
                                }
                                router.push(.learningTask(.map))
                            } label: {
                                Text("Show playing field")
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.accentColor)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.accentColor, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                .padding()
                .onAppear {
                    Task {
                        if initialAppearance == false {
                            initialAppearance = true
                            await viewModel.fetchScavengerHunt()
                        } else {
                            await viewModel.updateScavengerHuntState()
                        }
                    }
                }
                .sheet(isPresented: $viewModel.isPresented, onDismiss: {
                    router.navigateToRoot()
                }) {
                    ScavengerHuntResultPage(viewModel: viewModel)
                }
            }
            if viewModel.currentScavengerHunt?.isHuntComplete() == true {
                Spacer()
                PrimaryButton(
                    title: "Show final result",
                    color: .blue,
                    action: {
                        Task {
                            await viewModel.showFinalResult()
                        }
                    }
                ).padding(.horizontal, Styleguide.Margin.medium)
            }
        }
        .navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Need help?") {
                    viewModel.showHelpSheet = true
                }.sheet(isPresented: $viewModel.showHelpSheet) {
                    ScavengerHuntHelpView()
                        .presentationDetents([.fraction(0.8)])
                        .presentationCornerRadius(40)
                }
            }
        }
    }
}
