#!/usr/bin/env swift
//
// Legacy SF Symbol renderer — NOT the source of truth for the app icon.
//
// The premium icon (two overlapping sticker cards on emerald + gold) lives in:
//   Repetida/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png
//
// Regenerate that PNG with the GenerateImage tool / design workflow, then crop to
// 1024×1024 before committing. This script remains for optional AppMark fallback
// only; running it will overwrite AppMark.png but will NOT touch AppIcon-1024.png.
//
import AppKit

enum IconPalette {
    static let pitchDeep = NSColor(red: 13 / 255, green: 18 / 255, blue: 16 / 255, alpha: 1)
    static let goldFoil = NSColor(red: 237 / 255, green: 184 / 255, blue: 54 / 255, alpha: 1)
}

struct RenderOptions {
    let size: CGFloat
    let background: NSColor?
    let symbolName: String
    let symbolScale: CGFloat
    let weight: NSFont.Weight
}

func renderSymbol(_ options: RenderOptions) -> NSImage {
    let pixelSize = Int(options.size)
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        fputs("Failed to create bitmap context\n", stderr)
        exit(1)
    }

    NSGraphicsContext.saveGraphicsState()
    defer { NSGraphicsContext.restoreGraphicsState() }
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let canvas = NSRect(x: 0, y: 0, width: options.size, height: options.size)

    if let background = options.background {
        background.setFill()
        canvas.fill()
    }

    let drawSide = options.size * options.symbolScale
    let drawRect = NSRect(
        x: (options.size - drawSide) / 2,
        y: (options.size - drawSide) / 2,
        width: drawSide,
        height: drawSide
    )

    let config = NSImage.SymbolConfiguration(pointSize: drawSide * 0.72, weight: options.weight)
        .applying(NSImage.SymbolConfiguration(hierarchicalColor: IconPalette.goldFoil))

    guard
        let symbol = NSImage(systemSymbolName: options.symbolName, accessibilityDescription: nil)?
            .withSymbolConfiguration(config)
    else {
        fputs("Failed to load SF Symbol: \(options.symbolName)\n", stderr)
        exit(1)
    }

    symbol.draw(in: drawRect)

    let image = NSImage(size: NSSize(width: options.size, height: options.size))
    image.addRepresentation(rep)
    return image
}

func savePNG(_ image: NSImage, to path: String) throws {
    guard
        let rep = image.representations.compactMap({ $0 as? NSBitmapImageRep }).first,
        let png = rep.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "RenderAppIcon", code: 1, userInfo: [NSLocalizedDescriptionKey: "PNG export failed"])
    }
    try png.write(to: URL(fileURLWithPath: path))
}

let repoRoot = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : FileManager.default.currentDirectoryPath

let appMarkPath = "\(repoRoot)/Repetida/Assets.xcassets/AppMark.imageset/AppMark.png"

let appMark = renderSymbol(
    RenderOptions(
        size: 512,
        background: NSColor.clear,
        symbolName: "soccerball",
        symbolScale: 0.78,
        weight: .medium
    )
)

do {
    try savePNG(appMark, to: appMarkPath)
    print("Wrote \(appMarkPath)")
    print("AppIcon-1024.png is managed manually — see header comment.")
} catch {
    fputs("Error: \(error.localizedDescription)\n", stderr)
    exit(1)
}
