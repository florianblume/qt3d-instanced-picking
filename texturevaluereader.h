#ifndef TEXTUREVALUEREADER_H
#define TEXTUREVALUEREADER_H

#include <QObject>

#include <Qt3DRender/QTexture>
#include <Qt3DRender/QAbstractTextureImage>
#include <QQmlListProperty>

class TextureValueReader : public QObject
{
    Q_OBJECT
public:
    explicit TextureValueReader() : QObject() {

    }

    Q_INVOKABLE uint getPixel(Qt3DRender::QTexture2D *texture, int x, int y) {
        qDebug() << texture;
        QVariant textureImages = texture->property("textureImages");
        QQmlListProperty<Qt3DRender::QAbstractTextureImage>* list = (QQmlListProperty<Qt3DRender::QAbstractTextureImage>*) textureImages.data();
        return 0;
    }

signals:

};

#endif // TEXTUREVALUEREADER_H
