#!/usr/bin/env swift
// Generates RouteReplay/Assets.xcassets/AppIcon.appiconset/AppIcon.png
// Run from the project root: swift Scripts/make_icon.swift

import AppKit

let size = 1024.0
guard let ctx = CGContext(
    data: nil,
    width: Int(size),
    height: Int(size),
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    fatalError("Could not create context")
}

// Background: vertical gradient, deep navy → blue.
let colors = [
    CGColor(red: 0.02, green: 0.09, blue: 0.22, alpha: 1),
    CGColor(red: 0.05, green: 0.20, blue: 0.42, alpha: 1),
    CGColor(red: 0.10, green: 0.32, blue: 0.62, alpha: 1),
] as CFArray
let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.55, 1])!
ctx.drawLinearGradient(
    gradient,
    start: CGPoint(x: size / 2, y: size),
    end: CGPoint(x: size / 2, y: 0),
    options: []
)

// Route polyline: an orange-red swoosh with a white play triangle.
let red = CGColor(red: 0.99, green: 0.32, blue: 0.18, alpha: 1)
ctx.setStrokeColor(red)
ctx.setLineWidth(64)
ctx.setLineCap(.round)
ctx.setLineJoin(.round)
ctx.beginPath()
ctx.move(to: CGPoint(x: 210, y: 300))
ctx.addCurve(to: CGPoint(x: 500, y: 470),
             control1: CGPoint(x: 310, y: 460),
             control2: CGPoint(x: 420, y: 320))
ctx.addCurve(to: CGPoint(x: 820, y: 720),
             control1: CGPoint(x: 600, y: 640),
             control2: CGPoint(x: 700, y: 780))
ctx.strokePath()

// Play triangle (white).
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
ctx.beginPath()
ctx.move(to: CGPoint(x: 660, y: 640))
ctx.addLine(to: CGPoint(x: 660, y: 800))
ctx.addLine(to: CGPoint(x: 800, y: 720))
ctx.closePath()
ctx.fillPath()

let image = ctx.makeImage()!
let url = URL(fileURLWithPath: "RouteReplay/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil)!
CGImageDestinationAddImage(dest, image, nil)
CGImageDestinationFinalize(dest)
print("Icon written to \(url.path)")
