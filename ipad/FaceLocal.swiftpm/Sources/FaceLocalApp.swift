import SwiftUI
import UIKit
import Vision
import CryptoKit
import Security

@main
struct FaceLocalApp: App {
    var body: some Scene { WindowGroup { FaceLocalView() } }
}

struct FaceLocalView: View {
    @State private var showCamera = false
    @State private var action: Action = .enroll
    @State private var status = "Cadastre uma referência facial para começar."
    @State private var enrolled = Vault.hasReference
    @State private var busy = false

    enum Action { case enroll, compare }

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Image(systemName: "faceid")
                    .font(.system(size: 88))
                    .foregroundStyle(.indigo)
                Text("FaceLocal").font(.largeTitle.bold())
                Text("Reconhecimento facial experimental e local")
                    .foregroundStyle(.secondary)
                Text(status).multilineTextAlignment(.center)
                if busy { ProgressView() }
                Button("Cadastrar meu rosto") {
                    action = .enroll
                    showCamera = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(busy)
                Button("Comparar meu rosto") {
                    action = .compare
                    showCamera = true
                }
                .buttonStyle(.bordered)
                .disabled(busy || !enrolled)
                Button("Excluir referência", role: .destructive) {
                    do {
                        try Vault.erase()
                        enrolled = false
                        status = "Referência removida deste iPad."
                    } catch {
                        status = "Erro ao excluir: \(error.localizedDescription)"
                    }
                }
                .disabled(busy || !enrolled)
                Text("Protótipo: o resultado NÃO autoriza acesso a dados sensíveis, pagamentos ou ao iPad. Não substitui o Touch ID. Fotos e vídeos podem enganar a comparação.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Identidade local")
            .sheet(isPresented: $showCamera) {
                CameraPicker { image in
                    showCamera = false
                    guard let image else {
                        status = "Captura cancelada."
                        return
                    }
                    busy = true
                    Task { @MainActor in
                        defer { busy = false }
                        do {
                            let descriptor = try FaceDescriptor.extract(from: image)
                            switch action {
                            case .enroll:
                                try Vault.save(descriptor)
                                enrolled = true
                                status = "Referência salva com criptografia local. Agora você pode comparar outra captura."
                            case .compare:
                                let stored = try Vault.load()
                                var distance: Float = 0
                                try stored.computeDistance(&distance, to: descriptor)
                                status = String(format: "Distância visual: %.3f. Menor significa maior semelhança. Isto NÃO comprova identidade.", distance)
                            }
                        } catch {
                            status = "Não foi possível processar: \(error.localizedDescription)"
                        }
                    }
                }
            }
        }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    let completion: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.cameraDevice = .front
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(completion: completion) }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let completion: (UIImage?) -> Void
        init(completion: @escaping (UIImage?) -> Void) { self.completion = completion }
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            completion(info[.originalImage] as? UIImage)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completion(nil)
        }
    }
}

enum FaceProblem: LocalizedError {
    case image, none, multiple, reference, keychain
    var errorDescription: String? {
        switch self {
        case .image: "Imagem inválida."
        case .none: "Nenhum rosto detectado."
        case .multiple: "A imagem contém mais de um rosto."
        case .reference: "Referência ausente ou incompatível."
        case .keychain: "Não foi possível acessar o armazenamento protegido."
        }
    }
}

enum FaceDescriptor {
    static func extract(from image: UIImage) throws -> VNFeaturePrintObservation {
        let normalized = image.normalized()
        guard let cg = normalized.cgImage else { throw FaceProblem.image }
        let faces = VNDetectFaceRectanglesRequest()
        try VNImageRequestHandler(cgImage: cg).perform([faces])
        guard let found = faces.results, !found.isEmpty else { throw FaceProblem.none }
        guard found.count == 1 else { throw FaceProblem.multiple }
        let b = found[0].boundingBox
        let rect = CGRect(x: b.minX * CGFloat(cg.width),
                          y: (1 - b.maxY) * CGFloat(cg.height),
                          width: b.width * CGFloat(cg.width),
                          height: b.height * CGFloat(cg.height)).integral
        guard let cropped = cg.cropping(to: rect) else { throw FaceProblem.image }
        let request = VNGenerateImageFeaturePrintRequest()
        try VNImageRequestHandler(cgImage: cropped).perform([request])
        guard let result = request.results?.first else { throw FaceProblem.image }
        return result
    }
}

extension UIImage {
    func normalized() -> UIImage {
        if imageOrientation == .up { return self }
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in draw(in: CGRect(origin: .zero, size: size)) }
    }
}

enum Vault {
    private static let service = "br.com.rennanbrasileiro.facelocal"
    private static let account = "reference-key"
    private static var file: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("face-reference.aesgcm")
    }
    static var hasReference: Bool { FileManager.default.fileExists(atPath: file.path) }

    private static func key() throws -> SymmetricKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let result = SecItemCopyMatching(query as CFDictionary, &item)
        if result == errSecSuccess, let bytes = item as? Data {
            return SymmetricKey(data: bytes)
        }
        guard result == errSecItemNotFound else { throw FaceProblem.keychain }
        let bytes = SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
        let insert: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: bytes,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        guard SecItemAdd(insert as CFDictionary, nil) == errSecSuccess else { throw FaceProblem.keychain }
        return SymmetricKey(data: bytes)
    }

    static func save(_ descriptor: VNFeaturePrintObservation) throws {
        let archived = try NSKeyedArchiver.archivedData(withRootObject: descriptor, requiringSecureCoding: true)
        let sealed = try AES.GCM.seal(archived, using: key())
        guard let data = sealed.combined else { throw FaceProblem.reference }
        try FileManager.default.createDirectory(at: file.deletingLastPathComponent(),
                                                withIntermediateDirectories: true)
        try data.write(to: file, options: .atomic)
    }

    static func load() throws -> VNFeaturePrintObservation {
        guard hasReference else { throw FaceProblem.reference }
        let box = try AES.GCM.SealedBox(combined: Data(contentsOf: file))
        let data = try AES.GCM.open(box, using: key())
        guard let result = try NSKeyedUnarchiver.unarchivedObject(ofClass: VNFeaturePrintObservation.self,
                                                                 from: data) else {
            throw FaceProblem.reference
        }
        return result
    }

    static func erase() throws {
        if hasReference { try FileManager.default.removeItem(at: file) }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let result = SecItemDelete(query as CFDictionary)
        guard result == errSecSuccess || result == errSecItemNotFound else { throw FaceProblem.keychain }
    }
}
