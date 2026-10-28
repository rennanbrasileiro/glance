import SwiftUI
import AVFoundation
import Vision

struct ContentView: View {
    @StateObject private var scanner = FaceScanner()
    @State private var enrolled = false
    @State private var showingPrivacy = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Image(systemName: scanner.faceDetected ? "faceid" : "person.crop.circle")
                    .font(.system(size: 86))
                    .foregroundStyle(scanner.faceDetected ? .green : .secondary)
                    .accessibilityLabel(scanner.faceDetected ? "Rosto detectado" : "Aguardando rosto")
                Text("Glance para iPad").font(.largeTitle.bold())
                Text(scanner.status).multilineTextAlignment(.center)
                if scanner.running {
                    Button("Parar câmera") { scanner.stop() }
                        .buttonStyle(.borderedProminent)
                } else {
                    Button("Ativar câmera") { Task { await scanner.start() } }
                        .buttonStyle(.borderedProminent)
                }
                Text("Detecção facial local — não é identificação de pessoa nem substitui o Touch ID.")
                    .font(.footnote).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Privacidade e limitações") { showingPrivacy = true }
                    .font(.footnote)
            }
            .padding(24)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented: $showingPrivacy) {
                NavigationStack {
                    ScrollView {
                        Text("A câmera é processada no dispositivo para detectar a presença de um rosto. Esta primeira versão não identifica pessoas, não cadastra biometria e não desbloqueia o iPad. Nenhuma imagem é enviada a servidores ou armazenada pelo aplicativo.")
                            .padding()
                    }
                    .navigationTitle("Privacidade")
                    .toolbar { Button("Fechar") { showingPrivacy = false } }
                }
            }
            .onDisappear { scanner.stop() }
        }
    }
}

@MainActor
final class FaceScanner: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published private(set) var status = "Ative a câmera para iniciar."
    @Published private(set) var faceDetected = false
    @Published private(set) var running = false

    private let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "glance.ipad.frames")
    private var configured = false
    private var processing = false

    func start() async {
        guard !running else { return }
        let allowed: Bool
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: allowed = true
        case .notDetermined: allowed = await AVCaptureDevice.requestAccess(for: .video)
        default: allowed = false
        }
        guard allowed else {
            status = "Permita acesso à câmera em Ajustes para usar a detecção facial."
            return
        }
        guard configure() else { return }
        running = true
        status = "Procurando um rosto..."
        let capture = session
        queue.async { capture.startRunning() }
    }

    private func configure() -> Bool {
        if configured { return true }
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            status = "Câmera frontal indisponível."
            return false
        }
        session.beginConfiguration()
        session.sessionPreset = .medium
        session.addInput(input)
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: queue)
        guard session.canAddOutput(output) else {
            session.commitConfiguration()
            status = "Não foi possível configurar a captura."
            return false
        }
        session.addOutput(output)
        session.commitConfiguration()
        configured = true
        return true
    }

    func stop() {
        guard running else { return }
        running = false
        faceDetected = false
        status = "Câmera desligada."
        let capture = session
        queue.async { capture.stopRunning() }
    }

    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNDetectFaceRectanglesRequest()
        do {
            try VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .leftMirrored).perform([request])
            let detected = !(request.results?.isEmpty ?? true)
            Task { @MainActor [weak self] in
                guard let self, self.running else { return }
                self.faceDetected = detected
                self.status = detected ? "Rosto detectado pela câmera." : "Procurando um rosto..."
            }
        } catch {
            Task { @MainActor [weak self] in
                guard let self, self.running else { return }
                self.status = "Não foi possível analisar o vídeo."
            }
        }
    }
}
