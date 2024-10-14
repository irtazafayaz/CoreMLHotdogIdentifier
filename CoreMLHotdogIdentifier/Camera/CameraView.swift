//
//  CameraView.swift
//  CoreMLHotdogIdentifier
//
//  Created by Irtaza Fiaz on 09/10/2024.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @ObservedObject var camera: CameraModel
    
    var body: some View {
        ZStack {
            CameraPreview(camera: camera).ignoresSafeArea()
            
            VStack {
                HStack {
                    if camera.isTaken {
                        HStack {
                            Spacer()
                            Button(action: {}) {
                               Image(systemName: "camera.fill")
                                    .foregroundStyle(.black)
                                    .padding()
                                    .background(.white)
                                    .clipShape(Circle())
                            }.padding(.trailing)
                        }
                    }
                }
                Spacer()
                HStack {
                    if camera.isTaken {
                        Button(action: {}) {
                            Text("Save")
                                .foregroundStyle(.black)
                                .fontWeight(.semibold)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(.white)
                                .clipShape(Capsule())
                        }.padding(.leading)
                        Spacer()
                    } else {
                        Button {
                            camera.takePicture()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 65, height: 65)
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                                    .frame(width: 75, height: 75)
                            }
                        }
                    }
                    
                }.frame(height: 75)
            }
            
        }
        .onAppear {
            camera.configureCamera()
        }
    }
}

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var isTaken: Bool = false
    @Published var alert = false

    @Published var session = AVCaptureSession()
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    func configureCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setup()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    self.setup()
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    func setup() {
        do {
            self.session.beginConfiguration()
            let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) ??
                         AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            let input = try AVCaptureDeviceInput(device: device!)
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            if self.session.canAddOutput(output) {
                self.session.addOutput(output)
            }
            self.session.commitConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func takePicture() {
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            self.session.stopRunning()
            
            DispatchQueue.main.async {
                self.isTaken.toggle()
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        if error != nil {
            
        }
    }
    
}

#Preview {
    CameraView(camera: CameraModel())
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        DispatchQueue.global(qos: .background).async {
            camera.session.startRunning()
        }
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            camera.preview.frame = uiView.bounds
        }
    }
}
