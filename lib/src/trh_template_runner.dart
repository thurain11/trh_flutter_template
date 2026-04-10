import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';

import 'template_contents.dart';

const _currentCliVersion = '0.1.4';
const _repoUrl = 'https://github.com/thurain11/trh_flutter_template.git';

final _logger = Logger();

const _folders = <String>[
  'lib/builders',
  'lib/builders/external_refresh_builder',
  'lib/builders/factory',
  'lib/builders/refresh_builder',
  'lib/builders/request_button',
  'lib/builders/single_ui_builder',
  'lib/builders/typedef',
  'lib/core',
  'lib/core/constants',
  'lib/core/database',
  'lib/core/network',
  'lib/core/models',
  'lib/core/providers',
  'lib/core/routes',
  'lib/core/services',
  'lib/core/theme',
  'lib/core/utils',
  'lib/pages',
  'lib/widgets',
  'lib/widgets/common',
  'lib/widgets/err_state_widget',
];

const _files = <String>[
  'lib/builders/external_refresh_builder/external_refresh_ui_bloc.dart',
  'lib/builders/external_refresh_builder/external_refresh_ui_builder.dart',
  'lib/builders/factory/factory_builder.dart',
  'lib/builders/refresh_builder/refresh_ui_bloc.dart',
  'lib/builders/refresh_builder/refresh_ui_builder.dart',
  'lib/builders/request_button/icon_request_button.dart',
  'lib/builders/request_button/request_button.dart',
  'lib/builders/request_button/request_button_bloc.dart',
  'lib/builders/single_ui_builder/single_ui_bloc.dart',
  'lib/builders/single_ui_builder/single_ui_builder.dart',
  'lib/builders/typedef/type_def.dart',
  'lib/core/constants/app_constant.dart',
  'lib/core/database/share_pref.dart',
  'lib/core/network/basenetwork.dart',
  'lib/core/models/pin_ob.dart',
  'lib/core/models/response_ob.dart',
  'lib/core/providers/theme_provider.dart',
  'lib/core/routes/routes.dart',
  'lib/core/services/service_locatior.dart',
  'lib/core/theme/app_theme.dart',
  'lib/core/utils/app_util.dart',
  'lib/core/utils/context_ext.dart',
  'lib/widgets/common/loading_widget.dart',
  'lib/widgets/err_state_widget/connection_timeout_widget.dart',
  'lib/widgets/err_state_widget/err_widget.dart',
  'lib/widgets/err_state_widget/more_widget.dart',
  'lib/widgets/err_state_widget/no_internet_widget.dart',
  'lib/widgets/err_state_widget/no_login_widget.dart',
  'lib/widgets/err_state_widget/not_found_widget.dart',
  'lib/widgets/err_state_widget/server_err_widget.dart',
  'lib/widgets/err_state_widget/server_maintenance_widget.dart',
  'lib/widgets/err_state_widget/simple_state_card.dart',
  'lib/widgets/err_state_widget/too_many_request_widget.dart',
  'lib/widgets/err_state_widget/unknown_err_widget.dart',
];

const _dependencies = <String, String>{
  'cupertino_icons': '^1.0.8',
  'dio': '^5.9.0',
  'rxdart': '^0.28.0',
  'shared_preferences': '^2.5.4',
  'path_provider': '^2.1.5',
  'permission_handler': '^12.0.1',
  'pretty_dio_logger': '^1.4.0',
  'pull_to_refresh': '^2.0.0',
  'lottie': '^3.3.2',
  'provider': '^6.1.5+1',
  'image_picker': '^1.2.1',
  'toastification': 'any',
  'get_it': 'any',
  'go_router': 'any',
};

const _fileTemplates = <String, String>{
  'lib/builders/external_refresh_builder/external_refresh_ui_bloc.dart':
      externalRefreshUiBlocTemplate,
  'lib/builders/external_refresh_builder/external_refresh_ui_builder.dart':
      externalRefreshUiBuilderTemplate,
  'lib/builders/refresh_builder/refresh_ui_bloc.dart': refreshUiBlocTemplate,
  'lib/builders/refresh_builder/refresh_ui_builder.dart':
      refreshUiBuilderTemplate,
  'lib/builders/single_ui_builder/single_ui_bloc.dart': singleUiBlocTemplate,
  'lib/builders/single_ui_builder/single_ui_builder.dart':
      singleUiBuilderTemplate,
  'lib/builders/request_button/request_button_bloc.dart':
      requestButtonBlocTemplate,
  'lib/builders/request_button/request_button.dart': requestButtonTemplate,
  'lib/builders/factory/factory_builder.dart': factoryBuilderTemplate,
  'lib/builders/typedef/type_def.dart': typeDefTemplate,
  'lib/core/constants/app_constant.dart': appConstantTemplate,
  'lib/core/database/share_pref.dart': sharedPrefTemplate,
  'lib/core/network/basenetwork.dart': baseNetworkTemplate,
  'lib/core/routes/routes.dart': routesTemplate,
  'lib/core/services/service_locatior.dart': serviceLocatorTemplate,
  'lib/core/theme/app_theme.dart': appThemeTemplate,
  'lib/core/models/pin_ob.dart': pinObTemplate,
  'lib/core/models/response_ob.dart': responseObTemplate,
  'lib/core/utils/app_util.dart': appUtilTemplate,
  'lib/core/providers/theme_provider.dart': themeProviderTemplate,
  'lib/core/utils/context_ext.dart': contextExtTemplate,
  'lib/widgets/common/loading_widget.dart': loadingWidgetTemplate,
  'lib/widgets/err_state_widget/connection_timeout_widget.dart':
      connectionTimeoutWidgetTemplate,
  'lib/widgets/err_state_widget/err_widget.dart': errWidgetTemplate,
  'lib/widgets/err_state_widget/more_widget.dart': moreWidgetTemplate,
  'lib/widgets/err_state_widget/no_internet_widget.dart':
      noInternetWidgetTemplate,
  'lib/widgets/err_state_widget/no_login_widget.dart': noLoginWidgetTemplate,
  'lib/widgets/err_state_widget/not_found_widget.dart': notFoundWidgetTemplate,
  'lib/widgets/err_state_widget/server_err_widget.dart':
      serverErrWidgetTemplate,
  'lib/widgets/err_state_widget/server_maintenance_widget.dart':
      serverMaintenanceWidgetTemplate,
  'lib/widgets/err_state_widget/simple_state_card.dart':
      simpleStateCardTemplate,
  'lib/widgets/err_state_widget/too_many_request_widget.dart':
      tooManyRequestWidgetTemplate,
  'lib/widgets/err_state_widget/unknown_err_widget.dart':
      unknownErrWidgetTemplate,
};

Future<void> runTrhTemplate(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show usage information.',
    )
    ..addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Show CLI version.',
    )
    ..addOption(
      'path',
      abbr: 'p',
      help: 'Target Flutter project path. Defaults to current directory.',
    )
    ..addFlag(
      'dry-run',
      negatable: false,
      help: 'Preview changes without creating folders.',
    )
    ..addFlag(
      'force',
      abbr: 'f',
      negatable: false,
      help: 'Skip Flutter project validation.',
    )
    ..addCommand('init')
    ..addCommand('upgrade')
    ..addCommand('update')
    ..addCommand(
      'page',
      ArgParser()
        ..addOption(
          'name',
          abbr: 'n',
          help: 'Page name. Example: home, profile_setting.',
        )
        ..addFlag(
          'stateful',
          negatable: false,
          help: 'Generate StatefulWidget page.',
        ),
    );

  ArgResults results;
  try {
    results = parser.parse(arguments);
  } on FormatException catch (error) {
    _logger.err('Error: ${error.message}');
    _printUsage(parser);
    exitCode = 64;
    return;
  }

  if (results['help'] as bool) {
    _printUsage(parser);
    return;
  }

  if (results['version'] as bool) {
    _logger.info(
      '${lightCyan.wrap(styleBold.wrap('trh_template'))} '
      '${lightGreen.wrap(_currentCliVersion)}',
    );
    await _showUpdateBanner();
    return;
  }

  final command = results.command?.name;
  if (command == 'upgrade' || command == 'update') {
    await _runUpgrade();
    return;
  }

  await _showUpdateBanner();

  final pathInput = (results['path'] as String?)?.trim();
  final targetPath = pathInput == null || pathInput.isEmpty ? '.' : pathInput;
  final targetDir = Directory(targetPath);

  if (!targetDir.existsSync()) {
    _logger.err('Target path does not exist: ${targetDir.path}');
    exitCode = 66;
    return;
  }

  final isFlutterProject = _isFlutterProject(targetDir.path);
  final force = results['force'] as bool;
  if (!isFlutterProject && !force) {
    _logger.err(
      '`${targetDir.path}` is not a Flutter project. '
      'Run inside a Flutter project or use --force.',
    );
    exitCode = 65;
    return;
  }

  final dryRun = results['dry-run'] as bool;
  switch (command) {
    case null:
    case 'init':
      _runInit(targetDir.path, dryRun: dryRun);
      return;
    case 'page':
      _runPage(targetDir.path, results.command!, dryRun: dryRun);
      return;
    default:
      _logger.err('Unknown command: $command');
      _printUsage(parser);
      exitCode = 64;
      return;
  }
}

void _runInit(
  String targetPath, {
  required bool dryRun,
}) {
  final created = <String>[];
  final alreadyExists = <String>[];

  for (final folder in _folders) {
    final dir = Directory('$targetPath/$folder');
    if (dir.existsSync()) {
      alreadyExists.add(folder);
      continue;
    }

    if (dryRun) {
      created.add('$folder (preview)');
      continue;
    }

    dir.createSync(recursive: true);
    created.add(folder);
  }

  for (final filePath in _files) {
    final file = File('$targetPath/$filePath');
    if (file.existsSync()) {
      alreadyExists.add(filePath);
      continue;
    }

    if (dryRun) {
      created.add('$filePath (preview)');
      continue;
    }

    file.parent.createSync(recursive: true);
    final content = _fileTemplates[filePath] ?? '';
    file.writeAsStringSync(content);
    created.add(filePath);
  }

  _ensureDependencies(
    targetPath: targetPath,
    dryRun: dryRun,
    created: created,
    alreadyExists: alreadyExists,
  );

  _logger.success('TRH template scaffold finished for: $targetPath');
  if (created.isNotEmpty) {
    _logger.info('');
    _logger.info(styleBold.wrap('Created:')!);
    for (final folder in created) {
      _logger.info('  ${lightGreen.wrap('✓')} $folder');
    }
  } else {
    _logger.info('Created: none');
  }

  if (alreadyExists.isNotEmpty) {
    _logger.info('');
    _logger.info(styleBold.wrap('Already existed:')!);
    for (final folder in alreadyExists) {
      _logger.info('  ${darkGray.wrap('●')} ${darkGray.wrap(folder)!}');
    }
  }
}

void _ensureDependencies({
  required String targetPath,
  required bool dryRun,
  required List<String> created,
  required List<String> alreadyExists,
}) {
  final pubspecFile = File('$targetPath/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    return;
  }

  var content = pubspecFile.readAsStringSync();
  final newline = content.contains('\r\n') ? '\r\n' : '\n';
  var lines = content.split(RegExp(r'\r?\n'));

  var depHeaderIndex = lines.indexWhere(
    (line) => line.trimLeft().startsWith('dependencies:'),
  );

  if (depHeaderIndex == -1) {
    if (dryRun) {
      for (final dep in _dependencies.entries) {
        created.add('pubspec.yaml -> ${dep.key}: ${dep.value} (preview)');
      }
      return;
    }

    if (content.isNotEmpty &&
        !content.endsWith('\n') &&
        !content.endsWith('\r\n')) {
      content = '$content$newline';
    }

    final buffer = StringBuffer(content);
    buffer.writeln('dependencies:');
    for (final dep in _dependencies.entries) {
      buffer.writeln('  ${dep.key}: ${dep.value}');
      created.add('pubspec.yaml -> ${dep.key}: ${dep.value}');
    }
    pubspecFile.writeAsStringSync(buffer.toString());
    return;
  }

  var depEndIndex = lines.length;
  for (var i = depHeaderIndex + 1; i < lines.length; i++) {
    final line = lines[i];
    if (line.trim().isEmpty || line.trimLeft().startsWith('#')) {
      continue;
    }
    if (!line.startsWith(' ')) {
      depEndIndex = i;
      break;
    }
  }

  final depLineRegex = RegExp(r'^\s{2}([a-zA-Z0-9_]+)\s*:');
  final existingDeps = <String>{};
  for (var i = depHeaderIndex + 1; i < depEndIndex; i++) {
    final match = depLineRegex.firstMatch(lines[i]);
    if (match != null) {
      existingDeps.add(match.group(1)!);
    }
  }

  final depLinesToInsert = <String>[];
  for (final dep in _dependencies.entries) {
    if (existingDeps.contains(dep.key)) {
      alreadyExists.add('pubspec.yaml -> ${dep.key}');
      continue;
    }
    depLinesToInsert.add('  ${dep.key}: ${dep.value}');
    created.add(
      dryRun
          ? 'pubspec.yaml -> ${dep.key}: ${dep.value} (preview)'
          : 'pubspec.yaml -> ${dep.key}: ${dep.value}',
    );
  }

  if (depLinesToInsert.isEmpty || dryRun) {
    return;
  }

  lines.insertAll(depEndIndex, depLinesToInsert);
  final updated = lines.join(newline);
  pubspecFile.writeAsStringSync(updated);
}

void _runPage(
  String targetPath,
  ArgResults results, {
  required bool dryRun,
}) {
  final inputName = (results['name'] as String?)?.trim() ?? '';
  if (inputName.isEmpty) {
    _logger.err('Page name is required. Use --name <value>.');
    exitCode = 64;
    return;
  }

  final pageName = _toSnakeCase(inputName);
  if (pageName.isEmpty) {
    _logger.err('Page name must include letters or numbers.');
    exitCode = 64;
    return;
  }

  final className = _toPascalCase(pageName);
  final stateful = results['stateful'] as bool;
  final pageDir = Directory('$targetPath/lib/pages/$pageName');
  final pageFile = File('${pageDir.path}/${pageName}_page.dart');

  _runInit(targetPath, dryRun: dryRun);

  final created = <String>[];
  final alreadyExists = <String>[];

  if (!pageDir.existsSync()) {
    if (dryRun) {
      created.add('lib/pages/$pageName (preview)');
    } else {
      pageDir.createSync(recursive: true);
      created.add('lib/pages/$pageName');
    }
  } else {
    alreadyExists.add('lib/pages/$pageName');
  }

  if (!pageFile.existsSync()) {
    if (dryRun) {
      created.add('lib/pages/$pageName/${pageName}_page.dart (preview)');
    } else {
      pageFile.writeAsStringSync(
        stateful
            ? _statefulPageTemplate(className, pageName)
            : _statelessPageTemplate(className, pageName),
      );
      created.add('lib/pages/$pageName/${pageName}_page.dart');
    }
  } else {
    alreadyExists.add('lib/pages/$pageName/${pageName}_page.dart');
  }

  _logger.success('Page generation finished: $pageName');
  if (created.isNotEmpty) {
    _logger.info('');
    _logger.info(styleBold.wrap('Created:')!);
    for (final item in created) {
      _logger.info('  ${lightGreen.wrap('✓')} $item');
    }
  }
  if (alreadyExists.isNotEmpty) {
    _logger.info('');
    _logger.info(styleBold.wrap('Already existed:')!);
    for (final item in alreadyExists) {
      _logger.info('  ${darkGray.wrap('●')} ${darkGray.wrap(item)!}');
    }
  }
}

String _toSnakeCase(String input) {
  final trimmed = input.trim();
  final words = trimmed
      .replaceAll(RegExp(r'[^A-Za-z0-9]+'), ' ')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .map((word) => word.toLowerCase())
      .toList();
  return words.join('_');
}

String _toPascalCase(String input) {
  final words = input.split('_').where((word) => word.isNotEmpty);
  return words
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join();
}

String _statelessPageTemplate(String className, String pageName) {
  return '''
import 'package:flutter/material.dart';

class ${className}Page extends StatelessWidget {
  const ${className}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('$pageName page'),
      ),
    );
  }
}
''';
}

String _statefulPageTemplate(String className, String pageName) {
  return '''
import 'package:flutter/material.dart';

class ${className}Page extends StatefulWidget {
  const ${className}Page({super.key});

  @override
  State<${className}Page> createState() => _${className}PageState();
}

class _${className}PageState extends State<${className}Page> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('$pageName page'),
      ),
    );
  }
}
''';
}

void _printUsage(ArgParser parser) {
  _logger.info('');
  _logger.info(
    '${styleBold.wrap(lightCyan.wrap('trh_template'))} — '
    'TRH Flutter Template Scaffolder',
  );
  _logger.info('');
  _logger.info(styleBold.wrap('Usage:')!);
  _logger.info('  trh_template [options] [command]');
  _logger.info('');
  _logger.info(parser.usage);
  _logger.info('');
  _logger.info(styleBold.wrap('Commands:')!);
  _logger.info('  ${lightGreen.wrap('init')}                   Create base lib folders');
  _logger.info('  ${lightGreen.wrap('upgrade | update')}       Upgrade CLI from GitHub');
  _logger.info('  ${lightGreen.wrap('page')} --name <name>     Create page folder and page file');
  _logger.info('');
}

bool _isFlutterProject(String path) {
  final pubspec = File('$path/pubspec.yaml');
  if (!pubspec.existsSync()) {
    return false;
  }

  final content = pubspec.readAsStringSync();
  return RegExp(r'^\s*flutter\s*:', multiLine: true).hasMatch(content);
}

Future<void> _showUpdateBanner() async {
  try {
    final cacheFile = _updateCacheFile();
    final cache = _readUpdateCache(cacheFile);
    final now = DateTime.now().toUtc();

    if (cache != null) {
      final checkedAtRaw = cache['checkedAt'] as String?;
      final latestRaw = cache['latestVersion'] as String?;
      final checkedAt =
          checkedAtRaw == null ? null : DateTime.tryParse(checkedAtRaw);
      if (checkedAt != null && latestRaw != null) {
        final age = now.difference(checkedAt);
        if (age.inHours < 12) {
          _printUpdateBanner(latestRaw);
          return;
        }
      }
    }

    final latest =
        await _fetchLatestVersion().timeout(const Duration(seconds: 5));
    if (latest == null) {
      if (cache != null) {
        _printUpdateBanner(cache['latestVersion'] as String?);
      }
      return;
    }

    _writeUpdateCache(cacheFile, latestVersion: latest, checkedAtUtc: now);
    _printUpdateBanner(latest);
  } catch (_) {}
}

void _printUpdateBanner(String? latestRaw) {
  if (latestRaw == null || latestRaw.trim().isEmpty) {
    return;
  }
  final latest = _normalizeVersion(latestRaw);
  if (_compareVersions(_currentCliVersion, latest) >= 0) {
    return;
  }

  // Build the content lines (plain text for width calculation).
  final lines = <({String plain, String styled})>[
    (
      plain: '⚡ UPDATE AVAILABLE',
      styled: lightYellow.wrap(styleBold.wrap('⚡ UPDATE AVAILABLE'))!,
    ),
    (
      plain: '',
      styled: '',
    ),
    (
      plain: 'Version: $_currentCliVersion → $latest',
      styled: 'Version: ${yellow.wrap(_currentCliVersion)} '
          '${lightYellow.wrap('→')} '
          '${lightGreen.wrap(styleBold.wrap(latest))}',
    ),
    (
      plain: 'Run: trh_template upgrade',
      styled: 'Run: ${lightCyan.wrap(styleBold.wrap('trh_template upgrade'))}',
    ),
  ];

  // Calculate box width.
  final maxWidth = lines.fold<int>(
    0,
    (prev, line) => line.plain.length > prev ? line.plain.length : prev,
  );
  final innerWidth = maxWidth + 2; // 1 space padding each side

  // Build borders.
  final borderColor = yellow;
  final top = borderColor.wrap('╔${'═' * innerWidth}╗')!;
  final bottom = borderColor.wrap('╚${'═' * innerWidth}╝')!;
  final emptyRow = '${borderColor.wrap('║')} ${' ' * maxWidth} ${borderColor.wrap('║')}';

  // Build body rows.
  final bodyRows = <String>[];
  for (final line in lines) {
    final pad = ' ' * (maxWidth - line.plain.length);
    bodyRows.add(
      '${borderColor.wrap('║')} ${line.styled}$pad ${borderColor.wrap('║')}',
    );
  }

  _logger.info('');
  _logger.info(top);
  _logger.info(emptyRow);
  for (final row in bodyRows) {
    _logger.info(row);
  }
  _logger.info(emptyRow);
  _logger.info(bottom);
  _logger.info('');
}

File _updateCacheFile() {
  final home = Platform.environment['HOME'];
  if (home == null || home.isEmpty) {
    return File('${Directory.systemTemp.path}/trh_template_update_cache.json');
  }
  final dir = Directory('$home/.trh_template_cli');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  return File('${dir.path}/update_cache.json');
}

Map<String, dynamic>? _readUpdateCache(File file) {
  if (!file.existsSync()) {
    return null;
  }
  try {
    final content = file.readAsStringSync();
    final decoded = jsonDecode(content);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } catch (_) {}
  return null;
}

void _writeUpdateCache(
  File file, {
  required String latestVersion,
  required DateTime checkedAtUtc,
}) {
  try {
    file.writeAsStringSync(
      jsonEncode({
        'latestVersion': latestVersion,
        'checkedAt': checkedAtUtc.toIso8601String(),
      }),
    );
  } catch (_) {}
}

Future<String?> _fetchLatestVersion() async {
  final ownerRepo = _parseOwnerRepo(_repoUrl);
  if (ownerRepo == null) {
    return null;
  }

  final releaseVersion = await _fetchVersionFromUrl(
    'https://api.github.com/repos/${ownerRepo.$1}/${ownerRepo.$2}/releases/latest',
    key: 'tag_name',
  );
  if (releaseVersion != null) {
    return _normalizeVersion(releaseVersion);
  }

  final tagVersion = await _fetchVersionFromUrl(
    'https://api.github.com/repos/${ownerRepo.$1}/${ownerRepo.$2}/tags?per_page=1',
    key: 'name',
    isArray: true,
  );
  return tagVersion == null ? null : _normalizeVersion(tagVersion);
}

(String, String)? _parseOwnerRepo(String gitUrl) {
  final uri = Uri.tryParse(gitUrl);
  if (uri == null || uri.host != 'github.com') {
    return null;
  }
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.length < 2) {
    return null;
  }
  final owner = segments[0];
  final repo = segments[1].replaceAll('.git', '');
  if (owner.isEmpty || repo.isEmpty) {
    return null;
  }
  return (owner, repo);
}

Future<String?> _fetchVersionFromUrl(
  String url, {
  required String key,
  bool isArray = false,
}) async {
  final httpClient = HttpClient();
  try {
    final request = await httpClient.getUrl(Uri.parse(url));
    request.headers.set(
        HttpHeaders.userAgentHeader, 'trh_template_cli/$_currentCliVersion');
    request.headers
        .set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
    final githubToken = _readGithubToken();
    if (githubToken != null) {
      request.headers
          .set(HttpHeaders.authorizationHeader, 'Bearer $githubToken');
    }
    final response = await request.close();
    if (response.statusCode != 200) {
      return null;
    }
    final payload = await response.transform(utf8.decoder).join();
    final decoded = jsonDecode(payload);

    if (isArray) {
      if (decoded is List &&
          decoded.isNotEmpty &&
          decoded.first is Map<String, dynamic>) {
        return (decoded.first as Map<String, dynamic>)[key]?.toString();
      }
      return null;
    }

    if (decoded is Map<String, dynamic>) {
      return decoded[key]?.toString();
    }
    return null;
  } catch (_) {
    return null;
  } finally {
    httpClient.close(force: true);
  }
}

String? _readGithubToken() {
  final token = Platform.environment['GITHUB_TOKEN']?.trim();
  if (token != null && token.isNotEmpty) {
    return token;
  }
  final ghToken = Platform.environment['GH_TOKEN']?.trim();
  if (ghToken != null && ghToken.isNotEmpty) {
    return ghToken;
  }
  return null;
}

String _normalizeVersion(String raw) =>
    raw.trim().replaceFirst(RegExp(r'^[vV]'), '');

int _compareVersions(String a, String b) {
  final pa = _parseVersionParts(a);
  final pb = _parseVersionParts(b);
  final maxLen = pa.length > pb.length ? pa.length : pb.length;

  for (var i = 0; i < maxLen; i++) {
    final ai = i < pa.length ? pa[i] : 0;
    final bi = i < pb.length ? pb[i] : 0;
    if (ai != bi) {
      return ai.compareTo(bi);
    }
  }
  return 0;
}

List<int> _parseVersionParts(String version) {
  final normalized = _normalizeVersion(version);
  final main = normalized.split('-').first;
  return main.split('.').map((part) => int.tryParse(part) ?? 0).toList();
}

Future<void> _runUpgrade() async {
  final progress = _logger.progress('Upgrading trh_template from GitHub');
  try {
    final process = await Process.start(
      'dart',
      <String>['pub', 'global', 'activate', '--source', 'git', _repoUrl],
      mode: ProcessStartMode.inheritStdio,
    );
    final code = await process.exitCode;
    if (code == 0) {
      progress.complete('Upgrade complete!');
      _logger.info('');
      _logger.success(
        '  Verify: ${lightCyan.wrap('trh_template --version')}',
      );
    } else {
      progress.fail('Upgrade failed with exit code $code.');
      exitCode = code;
    }
  } catch (e) {
    progress.fail('Upgrade failed: $e');
    _logger.info('');
    _logger.info(
      '  Try manually: '
      '${lightCyan.wrap('dart pub global activate --source git $_repoUrl')}',
    );
    exitCode = 1;
  }
}

