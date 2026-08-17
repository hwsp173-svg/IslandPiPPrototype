import AVFoundation
import CoreGraphics

enum PiPVideoAssetFactory {
    static func makeTinyBlackMovie() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("island-pip-surface.mp4")
        // The asset is only two frames and is created once per app process. Replacing a
        // stale temporary file avoids handing AVPlayer a partial file after an interrupted run.
        if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
        let writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
        let settings: [String: Any] = [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 160, AVVideoHeightKey: 90]
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        input.expectsMediaDataInRealTime = false
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey as String: 90])
        guard writer.canAdd(input) else { throw PiPVideoError.cannotAddInput }
        writer.add(input)
        guard writer.startWriting() else { throw writer.error ?? PiPVideoError.cannotStart }
        writer.startSession(atSourceTime: .zero)
        for second in 0...1 {
            guard input.isReadyForMoreMediaData, let pixelBufferPool = adaptor.pixelBufferPool else { throw PiPVideoError.cannotAppend }
            var pixelBuffer: CVPixelBuffer?
            let status = CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &pixelBuffer)
            guard status == kCVReturnSuccess else { throw PiPVideoError.bufferCreation }
            guard let pixelBuffer else { throw PiPVideoError.bufferCreation }
            drawPill(into: pixelBuffer)
            guard adaptor.append(pixelBuffer, withPresentationTime: CMTime(seconds: Double(second), preferredTimescale: 600)) else { throw PiPVideoError.cannotAppend }
        }
        input.markAsFinished()
        let semaphore = DispatchSemaphore(value: 0)
        writer.finishWriting { semaphore.signal() }
        semaphore.wait()
        guard writer.status == .completed else { throw writer.error ?? PiPVideoError.cannotFinish }
        return url
    }
    private static func drawPill(into pixelBuffer: CVPixelBuffer) {
        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
        guard let base = CVPixelBufferGetBaseAddress(pixelBuffer), let context = CGContext(
            data: base, width: 160, height: 90, bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        ) else { return }
        context.setFillColor(CGColor(red: 0.08, green: 0.08, blue: 0.09, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: 160, height: 90))
        context.setFillColor(CGColor(gray: 0, alpha: 1))
        context.fill(CGPath(roundedRect: CGRect(x: 18, y: 29, width: 124, height: 32), cornerWidth: 16, cornerHeight: 16, transform: nil))
        context.setFillColor(CGColor(red: 0.56, green: 0.32, blue: 0.95, alpha: 1))
        context.fillEllipse(in: CGRect(x: 32, y: 41, width: 8, height: 8))
        context.setFillColor(CGColor(gray: 0.78, alpha: 1))
        context.fill(CGRect(x: 48, y: 43, width: 54, height: 3))
    }
    enum PiPVideoError: Error { case cannotAddInput, cannotStart, bufferCreation, cannotAppend, cannotFinish }
}
