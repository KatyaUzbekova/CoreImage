//  CustomKernels.ci.metal
//  Created by Katya on 16/04/2026.

#include <CoreImage/CoreImage.h>
using namespace metal;


extern "C" {
    namespace coreimage {
        // эффект свечения
        /// pixel - float4, содержит цвет пикселя
        float4 lumaThreshold(coreimage::sample_t pixel,
                             float threshold) {
            /// найти яркость пикселя для свечения через скалярное произведение 2 векторов
            /// дефолтное значение
            float luma = dot(pixel.rgb, float3(0.2126, 0.7152, 0.0722));
            /// step делает операцию примерно:
            /// if luma < threshold {
            ///  return float(0.0,0.0,0.0, 1.0);
            ///} else { return float(1.0,1.0,1.0, 1.0) }
            float mask = step(threshold, luma);
            return float4(mask, mask, mask, 1.0);
        }

        // искажения волнами
        // геометрический шейдер
        /// destination из coreImage, отвечает за доступ к output image, будем доставать координату пикселя, будем возвращать новую
        float2 carnivalMirror(float xAmplitude,
                              float yAmplitude,
                              float xWavelength,
                              float yWavelength,
                              coreimage::destination dest) {
            float2 pos = dest.coord(); // достаем координату
            float x = pos.x + sin(pos.x / xWavelength) * 2 * xAmplitude; // меняем с помощью эффекта синусоиды для эффекта волны
            float y = pos.y + sin(pos.y / yWavelength) * 2 * yAmplitude;
            return float2(x, y);
        }

        // возвращает float4
        // sampler src можем достать xy и цвет
        float4 boxBlur(coreimage::sampler src,
                       float radius,
                       coreimage::destination dest) {
            float2 pos = dest.coord();
            int r = int(radius);
            float4 sum = float4(0.0);
            float count = 0.0;
            
            for (int y = -r; y <= r; y++) {
                for (int x = -r; x <= r; x++) {
                    float2 offset = float2(float(x), float(y));
                    // достаем пиксель нужный нам
                    sum += src.sample(src.transform(pos + offset));
                    count += 1.0;
                }
            }
            // делим цвета
            return sum / count;
        }
    }
}
