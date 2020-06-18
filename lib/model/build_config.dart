enum BuildMode {
  Normal,
  EditEnviromentOnly,
  FlutterBuildOnly,
  AndroidOnly,
  IosOnly,
  BuildFileOnly,
  UploadOnly
}

class BuildConfig {
  final String flavor;
  final String flutterModule;
  final String androidModule;
  final String iosModule;
  final bool debug;

  final BuildMode mode;

  final bool needClean;
  final bool needPackagesGet;
  final bool needRefreshNavtiveLibraries;

  final DevEnvironment devEnvironment;

  factory BuildConfig.defaultConfig() => BuildConfig(
      devEnvironment: DevEnvironment(),
      flavor: 'test',
      debug: false,
      mode: BuildMode.Normal,
      needClean: true,
      needPackagesGet: true,
      needRefreshNavtiveLibraries: true);

  const BuildConfig(
      {this.flavor,
      this.flutterModule,
      this.androidModule,
      this.iosModule,
      this.debug,
      this.mode,
      this.needClean,
      this.needPackagesGet,
      this.needRefreshNavtiveLibraries,
      this.devEnvironment});

  BuildConfig copyWith({
    String flavor,
    String flutterModule,
    String androidModule,
    String iosModule,
    bool debug,
    BuildMode mode,
    bool needClean,
    bool needPackagesGet,
    bool needRefreshNavtiveLibraries,
    DevEnvironment devEnvironment,
  }) {
    return new BuildConfig(
      flavor: flavor ?? this.flavor,
      flutterModule: flutterModule ?? this.flutterModule,
      androidModule: androidModule ?? this.androidModule,
      iosModule: iosModule ?? this.iosModule,
      debug: debug ?? this.debug,
      mode: mode ?? this.mode,
      needClean: needClean ?? this.needClean,
      needPackagesGet: needPackagesGet ?? this.needPackagesGet,
      needRefreshNavtiveLibraries:
          needRefreshNavtiveLibraries ?? this.needRefreshNavtiveLibraries,
      devEnvironment: devEnvironment ?? this.devEnvironment,
    );
  }
}

class DevEnvironment {
  static const FLUTTER_ROOT = "FLUTTER_ROOT";
  static const ANDROID_HOME = "ANDROID_HOME";
  static const JAVA_HOME = "JAVA_HOME";
  static const BUILD_FILE_PATH = "BUILD_FILE_PATH";

  final String flutterRoot;
  final String androidHome;
  final String javaHome;
  final String buildFilePath;

  const DevEnvironment(
      {this.flutterRoot, this.androidHome, this.javaHome, this.buildFilePath});
}
