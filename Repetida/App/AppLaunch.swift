import SwiftData
import SwiftUI

struct AppDependencies {
    let catalog: CatalogRepository
    let modelContainer: ModelContainer
    let collection: SwiftDataCollectionRepository
}

enum AppLaunch {
    @MainActor
    static func load() -> Result<AppDependencies, Error> {
        let catalog = CatalogRepository()

        do {
            let modelContainer = try ModelContainerFactory.make()
            let collection = SwiftDataCollectionRepository(
                modelContext: modelContainer.mainContext,
                catalog: catalog
            )
            return .success(
                AppDependencies(
                    catalog: catalog,
                    modelContainer: modelContainer,
                    collection: collection
                )
            )
        } catch {
            return .failure(error)
        }
    }
}

struct AppRootView: View {
    @State private var dependencies: AppDependencies?
    @State private var launchError: String?

    var body: some View {
        Group {
            if let dependencies {
                AppRouter()
                    .environment(dependencies.catalog)
                    .environment(\.collectionRepository, dependencies.collection)
            } else if let launchError {
                LaunchFailureView(
                    message: launchError,
                    onRetry: retryLaunch
                )
            } else {
                LaunchLoadingView()
            }
        }
        .environment(\.locale, Locale(identifier: "pt-BR"))
        .preferredColorScheme(.dark)
        .task {
            await bootstrapIfNeeded()
        }
    }

    @MainActor
    private func bootstrapIfNeeded() async {
        guard dependencies == nil, launchError == nil else { return }
        switch AppLaunch.load() {
        case .success(let loaded):
            dependencies = loaded
        case .failure(let error):
            launchError = error.localizedDescription
        }
    }

    @MainActor
    private func retryLaunch() {
        ModelContainerFactory.deleteAllStoreFiles()
        dependencies = nil
        launchError = nil
        Task {
            await bootstrapIfNeeded()
        }
    }
}

private struct LaunchLoadingView: View {
    var body: some View {
        ZStack {
            DSColors.background.ignoresSafeArea()
            ProgressView()
                .tint(DSColors.primary)
        }
    }
}

private struct LaunchFailureView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        ZStack {
            DSColors.background.ignoresSafeArea()

            VStack(spacing: DSSpacing.lg) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(DSColors.secondary)

                Text(L10n.launchFailureTitle)
                    .font(DSTypography.body(17))
                    .fontWeight(.semibold)
                    .foregroundStyle(DSColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(L10n.launchFailureMessage)
                    .font(DSTypography.caption())
                    .foregroundStyle(DSColors.textMuted)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(DSTypography.caption(10))
                    .foregroundStyle(DSColors.textMuted.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.md)

                Button(action: onRetry) {
                    Text(L10n.launchFailureRetry)
                        .font(DSTypography.body(15))
                        .fontWeight(.semibold)
                        .foregroundStyle(DSColors.textPrimary)
                        .padding(.horizontal, DSSpacing.xl)
                        .padding(.vertical, DSSpacing.md)
                        .background(
                            Capsule(style: .continuous)
                                .fill(DSColors.primary.opacity(0.25))
                                .overlay(
                                    Capsule(style: .continuous)
                                        .strokeBorder(DSColors.cardBorder, lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(DSSpacing.xl)
        }
    }
}
