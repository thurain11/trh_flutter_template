# trh_template CLI

`trh_template` is a Dart CLI command for Flutter projects.

## Prerequisites

- Git
- Dart SDK 3.3+ (or Flutter SDK with bundled Dart)

It creates:

- `lib/builders`
- `lib/builders/external_refresh_builder`
- `lib/builders/factory`
- `lib/builders/refresh_builder`
- `lib/builders/request_button`
- `lib/builders/single_ui_builder`
- `lib/builders/typedef`
- `lib/core`
- `lib/core/constants`
- `lib/core/database`
- `lib/core/network`
- `lib/core/ob`
- `lib/core/providers`
- `lib/core/routes`
- `lib/core/services`
- `lib/core/theme`
- `lib/core/utils`
- `lib/pages`
- `lib/widgets`

And also creates core files:

- `lib/core/constants/app_constant.dart`
- `lib/core/database/share_pref.dart`
- `lib/core/network/basenetwork.dart`
- `lib/core/ob/response_ob.dart`
- `lib/core/providers/theme_provider.dart`
- `lib/core/routes/routes.dart`
- `lib/core/services/service_locatior.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/utils/app_util.dart`
- `lib/core/utils/context_ext.dart`

It also creates builder files:

- `lib/builders/external_refresh_builder/external_refresh_ui_bloc.dart`
- `lib/builders/external_refresh_builder/external_refresh_ui_builder.dart`
- `lib/builders/factory/factory_builder.dart`
- `lib/builders/refresh_builder/refresh_ui_bloc.dart`
- `lib/builders/refresh_builder/refresh_ui_builder.dart`
- `lib/builders/request_button/icon_request_button.dart`
- `lib/builders/request_button/request_button.dart`
- `lib/builders/request_button/request_button_bloc.dart`
- `lib/builders/single_ui_builder/single_ui_bloc.dart`
- `lib/builders/single_ui_builder/single_ui_builder.dart`
- `lib/builders/typedef/type_def.dart`

It also auto-adds these dependencies in target `pubspec.yaml` (only if missing):

- `dio: ^5.9.0`
- `rxdart: ^0.28.0`
- `shared_preferences: ^2.5.4`
- `path_provider: ^2.1.5`
- `permission_handler: ^12.0.1`
- `pretty_dio_logger: ^1.4.0`
- `pull_to_refresh: ^2.0.0`
- `provider: ^6.1.5+1`
- `image_picker: ^1.2.1`
- `toastification: any`
- `get_it: any`
- `go_router: any`

## Install globally (local path)

From this package directory:

```bash
dart pub global activate --source path .
```

## Install globally (GitHub)

```bash
dart pub global activate --source git https://github.com/thurain11/trh_flutter_template.git
```

## Update to latest

```bash
dart pub global activate --source git https://github.com/thurain11/trh_flutter_template.git
```

## If command not found

If `trh_template: command not found`, add pub cache bin to your `PATH`:

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

Then restart terminal and run:

```bash
trh_template --help
```

Then inside any Flutter project:

```bash
trh_template
```

Create a page:

```bash
trh_template page --name home
```

## Quick output example

After running:

```bash
trh_template
```

You will get folders like:

- `lib/builders/...`
- `lib/core/...`
- `lib/pages`
- `lib/widgets`

And starter files such as:

- `lib/core/network/basenetwork.dart`
- `lib/core/ob/pin_ob.dart`
- `lib/core/ob/response_ob.dart`
- `lib/builders/refresh_builder/refresh_ui_builder.dart`

## Options

```bash
trh_template --help
```

- `-p, --path` target project path (default: current directory)
- `--dry-run` preview without writing folders
- `-f, --force` skip Flutter project validation

## Commands

- `trh_template` or `trh_template init` creates base folders + `core` subfolders
- `trh_template page --name <name>` creates:
  - `lib/pages/<name>/`
  - `lib/pages/<name>/<name>_page.dart`
- `trh_template page --name <name> --stateful` creates StatefulWidget page
