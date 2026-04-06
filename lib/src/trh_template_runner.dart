import 'dart:io';

import 'package:args/args.dart';

import 'template_contents.dart';

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
  'lib/core/ob',
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
  'lib/core/ob/pin_ob.dart',
  'lib/core/ob/response_ob.dart',
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
  'lib/core/ob/pin_ob.dart': pinObTemplate,
  'lib/core/ob/response_ob.dart': responseObTemplate,
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

void runTrhTemplate(List<String> arguments) {
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show usage information.',
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
    stderr.writeln('Error: ${error.message}');
    _printUsage(parser);
    exitCode = 64;
    return;
  }

  if (results['help'] as bool) {
    _printUsage(parser);
    return;
  }

  final pathInput = (results['path'] as String?)?.trim();
  final targetPath = pathInput == null || pathInput.isEmpty ? '.' : pathInput;
  final targetDir = Directory(targetPath);

  if (!targetDir.existsSync()) {
    stderr.writeln('Error: target path does not exist: ${targetDir.path}');
    exitCode = 66;
    return;
  }

  final isFlutterProject = _isFlutterProject(targetDir.path);
  final force = results['force'] as bool;
  if (!isFlutterProject && !force) {
    stderr.writeln(
      'Error: `${targetDir.path}` is not a Flutter project. '
      'Run inside a Flutter project or use --force.',
    );
    exitCode = 65;
    return;
  }

  final dryRun = results['dry-run'] as bool;
  final command = results.command?.name;

  switch (command) {
    case null:
    case 'init':
      _runInit(targetDir.path, dryRun: dryRun);
      return;
    case 'page':
      _runPage(targetDir.path, results.command!, dryRun: dryRun);
      return;
    default:
      stderr.writeln('Unknown command: $command');
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

  stdout.writeln('TRH template scaffold finished for: $targetPath');
  if (created.isNotEmpty) {
    stdout.writeln('Created:');
    for (final folder in created) {
      stdout.writeln('  - $folder');
    }
  } else {
    stdout.writeln('Created: none');
  }

  if (alreadyExists.isNotEmpty) {
    stdout.writeln('Already existed:');
    for (final folder in alreadyExists) {
      stdout.writeln('  - $folder');
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
    stderr.writeln('Error: page name is required. Use --name <value>.');
    exitCode = 64;
    return;
  }

  final pageName = _toSnakeCase(inputName);
  if (pageName.isEmpty) {
    stderr.writeln('Error: page name must include letters or numbers.');
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

  stdout.writeln('Page generation finished: $pageName');
  if (created.isNotEmpty) {
    stdout.writeln('Created:');
    for (final item in created) {
      stdout.writeln('  - $item');
    }
  }
  if (alreadyExists.isNotEmpty) {
    stdout.writeln('Already existed:');
    for (final item in alreadyExists) {
      stdout.writeln('  - $item');
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
  stdout.writeln('Usage: trh_template [options] [command]');
  stdout.writeln(parser.usage);
  stdout.writeln('');
  stdout.writeln('Commands:');
  stdout.writeln('  init                   Create base lib folders');
  stdout.writeln('  page --name <name>     Create page folder and page file');
}

bool _isFlutterProject(String path) {
  final pubspec = File('$path/pubspec.yaml');
  if (!pubspec.existsSync()) {
    return false;
  }

  final content = pubspec.readAsStringSync();
  return RegExp(r'^\s*flutter\s*:', multiLine: true).hasMatch(content);
}
