#ifndef PIXELVALUEREADER_H
#define PIXELVALUEREADER_H

#include <QObject>

#include <Qt3DRender/QRenderCaptureReply>

class PixelValueReader : public QObject
{
    Q_OBJECT
public:
    explicit PixelValueReader() : QObject() {

    }

    Q_INVOKABLE uint getID(Qt3DRender::QRenderCaptureReply *reply, int x, int y) {
         QRgb pixel = reply->image().pixel(x, y);
         int red = qRed(pixel);
         int blue = qBlue(pixel);
         int green = qGreen(pixel);
         int alpha = qAlpha(pixel);
         // RGBA captures the ID but since we masked and right shifted the respective values in the shader
         // (e.g. (red & 0xFF000000) >> 24 for red) to prevent overflow in the color values we have to
         // undo the shift here again.
         return red * 0xFF000000 + green * 0xFF0000 + blue * 0xFF00 + alpha;
    }

private:
    QImage m_image;

};

#endif // PIXELVALUEREADER_H
