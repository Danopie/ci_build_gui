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
  final String branch;
  final bool debug;

  final BuildMode mode;

  final bool needClean;
  final bool needPackagesGet;
  final bool needRefreshNavtiveLibraries;

  final String buildFilePath;

  final DevEnvironment devEnvironment;

  factory BuildConfig.defaultConfig() => BuildConfig(
      buildFilePath: "/Workspace/dc3/stable/clean-build-deloy.sh",
      devEnvironment: DevEnvironment(),
      flavor: 'test',
      branch: '',
      debug: false,
      mode: BuildMode.Normal,
      needClean: true,
      needPackagesGet: true,
      needRefreshNavtiveLibraries: true);

  const BuildConfig(
      {this.flavor,
      this.branch,
      this.debug,
      this.mode,
      this.needClean,
      this.needPackagesGet,
      this.needRefreshNavtiveLibraries,
      this.devEnvironment,
      this.buildFilePath});

  BuildConfig copyWith({
    String flavor,
    String branch,
    bool debug,
    BuildMode mode,
    bool needClean,
    bool needPackagesGet,
    bool needRefreshNavtiveLibraries,
    DevEnvironment devEnvironment,
    String buildFilePath,
  }) {
    return BuildConfig(
      flavor: flavor ?? this.flavor,
      branch: branch ?? this.branch,
      debug: debug ?? this.debug,
      mode: mode ?? this.mode,
      needClean: needClean ?? this.needClean,
      needPackagesGet: needPackagesGet ?? this.needPackagesGet,
      buildFilePath: buildFilePath ?? this.buildFilePath,
      devEnvironment: devEnvironment ?? this.devEnvironment,
      needRefreshNavtiveLibraries:
          needRefreshNavtiveLibraries ?? this.needRefreshNavtiveLibraries,
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
