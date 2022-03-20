import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;

class View3D extends StatefulWidget {
  double width;
  double height;
  double dpr;
  String url;

  View3D(
      {Key? key,
      required this.width,
      required this.height,
      required this.dpr,
      required this.url})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return View3DState();
  }
}

class View3DState extends State<View3D> {
  late FlutterGlPlugin flutterGlPlugin;
  bool contextInited = false;
  bool disposed = false;
  late THREE.WebGLRenderer renderer;
  late THREE.WebGLRenderTarget renderTarget;
  late int sourceTexture;

  late THREE.Camera camera;
  late THREE.Scene scene;

  final GlobalKey<THREE_JSM.DomLikeListenableState> _globalKey =
      GlobalKey<THREE_JSM.DomLikeListenableState>();

  get width => widget.width;
  get height => widget.height;
  get dpr => widget.dpr;

  @override
  void initState() {
    super.initState();
    initPlugin();
  }

  loadModel() async {
    var loader = THREE_JSM.GLTFLoader(null);

    var result = await loader.loadAsync(widget.url);

    print(" gltf load sucess result: ${result}  ");

    var object = result["scene"];

    // object.traverse( ( child ) {
    //   if ( child.isMesh ) {
    // child.material.map = texture;
    //   }
    // } );

    scene.add(object);

    var controller = THREE_JSM.OrbitControls(camera, _globalKey);

    animate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildView3D(context),
        TextButton(
            onPressed: () {
              print("render ................ ");
              render();
            },
            child: Text(" render "))
      ],
    );
  }

  Widget _buildView3D(BuildContext context) {
    double width = widget.width;
    double height = widget.height;

    return THREE_JSM.DomLikeListenable(
        key: _globalKey,
        builder: (BuildContext context) {
          return Container(
              width: width,
              height: height,
              child: Builder(builder: (BuildContext context) {
                if (!flutterGlPlugin.isInitialized) {
                  return Container(
                    color: Colors.black,
                  );
                }

                WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                  initContext();
                });

                if (kIsWeb) {
                  return HtmlElementView(
                      viewType: flutterGlPlugin.textureId!.toString());
                } else {
                  return Texture(textureId: flutterGlPlugin.textureId!);
                }
              }));
        });
  }

  initPlugin() async {
    flutterGlPlugin = FlutterGlPlugin();

    Map<String, dynamic> _options = {
      "antialias": true,
      "alpha": false,
      "width": width,
      "height": height,
      "dpr": dpr
    };

    await flutterGlPlugin.initialize(options: _options);
    setState(() {});
  }

  initContext() async {
    if (contextInited) return;
    contextInited = true;
    await flutterGlPlugin.prepareContext();

    initThreeRenderer();
    initScene();
    loadModel();
  }

  initThreeRenderer() {
    Map<String, dynamic> _options = {
      "width": width,
      "height": height,
      "gl": flutterGlPlugin.gl,
      "antialias": true,
      "canvas": flutterGlPlugin.element
    };
    renderer = THREE.WebGLRenderer(_options);
    renderer.setPixelRatio(dpr);
    renderer.setSize(width, height, false);
    renderer.shadowMap.enabled = false;

    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1;
    renderer.outputEncoding = THREE.sRGBEncoding;

    if (!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({"format": THREE.RGBAFormat});
      renderTarget = THREE.WebGLRenderTarget(
          (width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderTarget.samples = 4;
      renderer.setRenderTarget(renderTarget);
      sourceTexture = renderer.getRenderTargetGLTexture(renderTarget);
    }
  }

  initScene() {
    camera = THREE.PerspectiveCamera(45, width / height, 0.25, 2000);
    camera.position.set(-1.8, 0.6, 2000);

    scene = THREE.Scene();
    scene.background = THREE.Color(1.0, 0.0, 0.0);

    var ambientLight = THREE.AmbientLight(0xcccccc, 0.4);
    scene.add(ambientLight);

    var pointLight = THREE.PointLight(0xffffff, 0.8);

    pointLight.position.set(0, 0, 18);

    scene.add(pointLight);
    scene.add(camera);

    camera.lookAt(scene.position);
  }

  animate() {
    if (!mounted || disposed) {
      return;
    }

    render();

    Future.delayed(const Duration(milliseconds: 40), () {
      animate();
    });
  }

  render() {
    final _gl = flutterGlPlugin.gl;
    renderer.render(scene, camera);
    _gl.flush();

    if (!kIsWeb) {
      flutterGlPlugin.updateTexture(sourceTexture);
    }
  }

  @override
  void dispose() {
    disposed = true;
    flutterGlPlugin.dispose();

    super.dispose();
  }
}
