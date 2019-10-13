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

  factory BuildConfig.defaultConfig() => BuildConfig(
      flavor: 'test',
      branch: '',
      debug: false,
      mode: BuildMode.Normal,
      needClean: true,
      needPackagesGet: true,
      needRefreshNavtiveLibraries: true);

  const BuildConfig({
    this.flavor,
    this.branch,
    this.debug,
    this.mode,
    this.needClean,
    this.needPackagesGet,
    this.needRefreshNavtiveLibraries,
  });

  BuildConfig copyWith({
    String flavor,
    String branch,
    bool debug,
    BuildMode mode,
    bool needClean,
    bool needPackagesGet,
    bool needRefreshNavtiveLibraries,
  }) {
    return BuildConfig(
      flavor: flavor ?? this.flavor,
      branch: branch ?? this.branch,
      debug: debug ?? this.debug,
      mode: mode ?? this.mode,
      needClean: needClean ?? this.needClean,
      needPackagesGet: needPackagesGet ?? this.needPackagesGet,
      needRefreshNavtiveLibraries:
          needRefreshNavtiveLibraries ?? this.needRefreshNavtiveLibraries,
    );
  }
}
