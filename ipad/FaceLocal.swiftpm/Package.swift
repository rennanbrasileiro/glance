// swift-tools-version: 5.9
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "FaceLocal",
    platforms: [.iOS("16.0")],
    products: [
        .iOSApplication(
            name: "FaceLocal",
            targets: ["AppModule"],
            bundleIdentifier: "br.com.rennanbrasileiro.facelocal",
            teamIdentifier: "",
            displayVersion: "0.1",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .personCropCircle, accentColor: .indigo),
            accentColor: .presetColor(.indigo),
            supportedDeviceFamilies: [.pad],
            supportedInterfaceOrientations: [.portrait, .landscapeLeft, .landscapeRight],
            capabilities: [.camera(purposeString: "A câmera frontal permite cadastrar e comparar imagens do seu rosto localmente.")]
        )
    ],
    targets: [.executableTarget(name: "AppModule", path: "Sources")]
)
