import SwiftUI

struct SplitView<Master: View, Detail: View>: View {
    var master: Master
    var detail: Detail

    init(@ViewBuilder master: () -> Master, @ViewBuilder detail: () -> Detail) {
        self.master = master()
        self.detail = detail()
    }

    var body: some View {
        let viewControllers = [UIHostingController(rootView: master), UIHostingController(rootView: detail)]
        return SplitViewController(viewControllers: viewControllers)
    }
}

struct SplitViewController: UIViewControllerRepresentable {
    var viewControllers: [UIViewController]
    @Environment(\.splitViewPreferredDisplayMode) var preferredDisplayMode: UISplitViewController.DisplayMode

    func makeUIViewController(context: Context) -> UISplitViewController {
        return UISplitViewController()
    }

    func updateUIViewController(_ splitController: UISplitViewController, context: Context) {
        splitController.preferredDisplayMode = preferredDisplayMode
        splitController.viewControllers = viewControllers
    }
}

struct PreferredDisplayModeKey : EnvironmentKey {
    static var defaultValue: UISplitViewController.DisplayMode = .automatic
}

extension EnvironmentValues {
    var splitViewPreferredDisplayMode: UISplitViewController.DisplayMode {
        get { self[PreferredDisplayModeKey.self] }
        set { self[PreferredDisplayModeKey.self] = newValue }
    }
}

extension View {
    /// Sets the preferred display mode for SplitView within the environment of self.
    func splitViewPreferredDisplayMode(_ mode: UISplitViewController.DisplayMode) -> some View {
        self.environment(\.splitViewPreferredDisplayMode, mode)
    }
}
