import UIKit

extension UIColor {
  /// A curated set of flat colors (matching ChameleonFramework's palette).
  private static let flatColors: [UIColor] = [
    UIColor(red: 0.17, green: 0.24, blue: 0.31, alpha: 1.0),  // midnight blue
    UIColor(red: 0.91, green: 0.30, blue: 0.24, alpha: 1.0),  // alizarin
    UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.0),  // emerald
    UIColor(red: 0.20, green: 0.60, blue: 0.86, alpha: 1.0),  // peter river
    UIColor(red: 0.56, green: 0.27, blue: 0.68, alpha: 1.0),  // amethyst
    UIColor(red: 0.95, green: 0.77, blue: 0.06, alpha: 1.0),  // sunflower
    UIColor(red: 0.90, green: 0.49, blue: 0.13, alpha: 1.0),  // carrot
    UIColor(red: 0.10, green: 0.74, blue: 0.61, alpha: 1.0),  // turquoise
    UIColor(red: 0.58, green: 0.65, blue: 0.65, alpha: 1.0),  // concrete
    UIColor(red: 0.94, green: 0.76, blue: 0.06, alpha: 1.0),  // orange
    UIColor(red: 0.61, green: 0.35, blue: 0.71, alpha: 1.0),  // wisteria
    UIColor(red: 0.16, green: 0.50, blue: 0.73, alpha: 1.0),  // belize hole
    UIColor(red: 0.85, green: 0.21, blue: 0.27, alpha: 1.0),  // pomegranate
    UIColor(red: 0.15, green: 0.68, blue: 0.38, alpha: 1.0),  // nephritis
    UIColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1.0),  // clouds
  ]

  /// Returns a random flat color.
  static func randomFlatColor() -> UIColor {
    return flatColors[Int.random(in: 0..<flatColors.count)]
  }

  /// Returns black or white depending on which contrasts better with the given color.
  static func contrastingColor(on backgroundColor: UIColor) -> UIColor {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    backgroundColor.getRed(&r, green: &g, blue: &b, alpha: &a)
    // Luminance formula (ITU-R BT.709)
    let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
    return luminance > 0.5 ? .black : .white
  }

  /// Returns the average color of a UIImage.
  static func averageColor(from image: UIImage) -> UIColor {
    guard let cgImage = image.cgImage else { return .gray }
    let width = 1
    let height = 1
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    var pixelData: [UInt8] = [0, 0, 0, 0]
    let context = CGContext(
      data: &pixelData,
      width: width,
      height: height,
      bitsPerComponent: 8,
      bytesPerRow: 4,
      space: colorSpace,
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )
    context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    let r = CGFloat(pixelData[0]) / 255.0
    let g = CGFloat(pixelData[1]) / 255.0
    let b = CGFloat(pixelData[2]) / 255.0
    let a = CGFloat(pixelData[3]) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }
}
