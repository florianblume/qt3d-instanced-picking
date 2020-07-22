import QtQuick 2.1 as QQ2
import Qt3D.Core 2.0
import Qt3D.Render 2.10
import Qt3D.Input 2.0
import Qt3D.Extras 2.0

Entity {

    components: [
        rendSettings,
        inputSettings
    ]

    InputSettings { id: inputSettings }

    RenderSettings {
        id: rendSettings
        activeFrameGraph: RenderSurfaceSelector {
            id: surfaceSelector
            Viewport {
                normalizedRect: Qt.rect(0, 0, 1, 1)
                CameraSelector {
                    camera: camera
                    ClearBuffers {
                        buffers: ClearBuffers.ColorDepthBuffer
                        clearColor: "transparent"
                        FrustumCulling {
                            DepthTest {
                                depthFunction: DepthTest.LessOrEqual

                                RenderPassFilter {
                                    matchAny: [drawFilterKey]
                                }
                                RenderPassFilter {
                                    matchAny: [pickingFilterKey]
                                    RenderTargetSelector {
                                        target: rt
                                        TextureRenderTarget {
                                            id: rt
                                            width: surfaceSelector.surface ? surfaceSelector.surface.width : 512
                                            height: surfaceSelector.surface ? surfaceSelector.surface.height : 256
                                        }
                                        RenderCapture {
                                            id: renderCapture
                                        }
                                    }
                                }
                            }

                        }
                    }
                }
            }
        }

    }

    MouseDevice {
        id: mouseDevice
    }

    MouseHandler {
        sourceDevice: mouseDevice

        property var reply
        property var x
        property var y

        onReleased: {
            x = mouse.x
            y = mouse.y
            doRenderCapture()
        }

        function doRenderCapture() {
            reply = renderCapture.requestCapture()
            reply.completeChanged.connect(onRenderCaptureCompleted)
        }

        function onRenderCaptureCompleted() {
            var color = pixelValueReader.getID(reply, x, y)
            console.log('ID: ' + color)
        }

    }

    Camera {
        id: camera
        projectionType: CameraLens.PerspectiveProjection
        fieldOfView: 45
        aspectRatio: _window.width / _window.height
        nearPlane: 0.1
        farPlane: 100.0
        position: Qt.vector3d(0.0, 10.0, 20.0)
        viewCenter: Qt.vector3d(0.0, 0.0, 0.0)
        upVector: Qt.vector3d(0.0, 1.0, 0.0)
    }

    FirstPersonCameraController { camera: camera }

    Entity {
        PlaneMesh {
            id: pm
            width: 20
            height: 20
        }
        PhongMaterial {
            id: pmm
            ambient: Qt.rgba(0.0,0.0,0.7,1)
        }
        components: [ pm, pmm ]
    }


    Entity {

        id: myEntity
        property matrix4x4 instTransform: Qt.matrix4x4(   // identity matrix
                                               1,0,0,0,
                                               0,1,0,0,
                                               0,0,1,0,
                                               0,0,0,1)

        GeometryRenderer {
            id: gr
            geometry: _instg
            instanceCount: _instg.count
        }

        Transform {
            id: trr
            translation: Qt.vector3d(0,1.5,0)
        }

        Material {
            id: grm

            parameters: [
                Parameter { name: "ka"; value: Qt.rgba(0.05, 0.05, 0.05, 1.0) },
                Parameter { name: "kd"; value: Qt.rgba(0.7, 0.7, 0.7, 1.0) },
                Parameter { name: "ks"; value: Qt.rgba(0.01, 0.01, 0.01, 1.0) },
                Parameter { name: "shininess"; value: 150. },

                Parameter { name: "inst"; value: myEntity.instTransform },
                Parameter { name: "instNormal"; value: _instg.normalMatrix( myEntity.instTransform ) }  // normal matrix (actually just 3x3)
            ]

            effect: Effect {
                techniques: Technique {
                    FilterKey {id: drawFilterKey; name: "pass"; value: "draw"}
                    FilterKey {id: pickingFilterKey; name: "pass"; value: "picking"}

                    graphicsApiFilter { api: GraphicsApiFilter.OpenGL; profile: GraphicsApiFilter.CoreProfile; majorVersion: 3; minorVersion: 1 }
                    renderPasses: [
                        RenderPass {
                            filterKeys: [drawFilterKey]
                            shaderProgram: ShaderProgram {
                                vertexShaderCode: loadSource("qrc:/shaders/instanced.vert")
                                fragmentShaderCode: loadSource("qrc:/shaders/instanced_draw.frag")
                            }
                        },
                        RenderPass {
                            filterKeys: [pickingFilterKey]
                            shaderProgram: ShaderProgram {
                                vertexShaderCode: loadSource("qrc:/shaders/instanced.vert")
                                fragmentShaderCode: loadSource("qrc:/shaders/instanced_picking.frag")
                            }
                        }
                    ]
                }
            }
        }

        components:  [ gr, grm, trr ]
    }


    // reference sphere (for shading)
    Entity {
        PhongMaterial {
            id: redMat
            ambient: "red"
        }
        SphereMesh {
            id: sphereMesh
        }
        Transform {
            id: sphereTransform
            translation: Qt.vector3d(0,5,0)
        }

        components: [ redMat, sphereMesh, sphereTransform ]
    }

}
