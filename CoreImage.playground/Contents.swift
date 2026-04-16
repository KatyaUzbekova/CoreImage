import UIKit
import CoreImage
// тестирую асинхронный код вне полноценного приложения
import PlaygroundSupport


let image = UIImage(named: "68.jpg")!
let ciImage = CIImage(image: image)!

let color = CIImage(color: .red)
    .cropped(to: .init(x: 0, y: 0, width: 100, height: 100)
    )


let filter = CIFilter(name: "CISepiaTone")!
filter.setValue(ciImage, forKey: kCIInputImageKey)
filter.setValue(0.8, forKey: kCIInputIntensityKey)
var filteredImage = filter.outputImage


let bloomFilter = CIFilter(name: "CIBloom")!
bloomFilter.setValue(8, forKey: kCIInputRadiusKey)
bloomFilter.setValue(1.0, forKey: kCIInputIntensityKey)
bloomFilter.setValue(ciImage, forKey: kCIInputImageKey)
// тут необходи crop, так как CIBloom convolutional filter и он добавляет цвета
var filteredImage2 = bloomFilter.outputImage?.cropped(to: ciImage.extent)

let noirFilter = CIFilter(name: "CIPhotoEffectNoir")
noirFilter?.setValue(filteredImage, forKey: kCIInputImageKey)
filteredImage2 = noirFilter?.outputImage!

let negativeImage = filteredImage2?.applyingFilter("CIColorInvert")

let checkboardFilter = CIFilter(name: "CICheckerboardGenerator")!
// extent - границы изображение в CiIMage
let center = CIVector(
    x: filteredImage2!.extent.width,
    y: filteredImage2!.extent.height/2
)
checkboardFilter.setValue(center, forKey: kCIInputCenterKey)
checkboardFilter.setValue(CIColor.green, forKey: kCIInputColor0Key)
checkboardFilter.setValue(CIColor.blue, forKey: kCIInputColor1Key)

let checkBoardImage = checkboardFilter.outputImage!
    .cropped(to: filteredImage2!.extent)


let compositeFilter = CIFilter(name: "CIBlendWithMask")!
compositeFilter.setValue(filteredImage2!, forKey: kCIInputImageKey)
compositeFilter.setValue(negativeImage!, forKey: kCIInputBackgroundImageKey)
compositeFilter.setValue(checkBoardImage, forKey: kCIInputMaskImageKey)


filteredImage = compositeFilter.outputImage!

// в этом случае отрендерится где то потом
let uiImage = UIImage(ciImage: filteredImage!)
let imageView = UIImageView(image: uiImage)

imageView.contentMode = .scaleAspectFit
imageView.frame = CGRect(
    x: .zero,
    y: .zero,
    width: uiImage.size.width,
    height: uiImage.size.height
)

PlaygroundPage.current.liveView = imageView


let ciContext = CIContext(options: [
    .useSoftwareRenderer: true, // делать работу на GPU и на CPU; true - CPU; true только при дебаге
    .cacheIntermediates: true, //
    .highQualityDownsample: false // если нужно побыстрее выставляем false
])

// core graphics image
let cgImage = ciContext.createCGImage(filteredImage!, from: filteredImage!.extent)!
let uiIMageWithContext = UIImage(cgImage: cgImage)

let imageView2 = UIImageView(image: uiIMageWithContext)

imageView2.contentMode = .scaleAspectFit
imageView2.frame = CGRect(
    x: .zero,
    y: .zero,
    width: uiImage.size.width,
    height: uiImage.size.height
)
