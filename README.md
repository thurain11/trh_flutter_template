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
- `lib/core/models`
- `lib/core/providers`
- `lib/core/routes`
- `lib/core/services`
- `lib/core/theme`
- `lib/core/utils`
- `lib/pages`
- `lib/widgets`
- `lib/widgets/common`
- `lib/widgets/err_state_widget`

And also creates core files:

- `lib/core/constants/app_constant.dart`
- `lib/core/database/share_pref.dart`
- `lib/core/network/basenetwork.dart`
- `lib/core/models/response_ob.dart`
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

It also creates widget files:

- `lib/widgets/common/loading_widget.dart`
- `lib/widgets/err_state_widget/connection_timeout_widget.dart`
- `lib/widgets/err_state_widget/err_widget.dart`
- `lib/widgets/err_state_widget/more_widget.dart`
- `lib/widgets/err_state_widget/no_internet_widget.dart`
- `lib/widgets/err_state_widget/no_login_widget.dart`
- `lib/widgets/err_state_widget/not_found_widget.dart`
- `lib/widgets/err_state_widget/server_err_widget.dart`
- `lib/widgets/err_state_widget/server_maintenance_widget.dart`
- `lib/widgets/err_state_widget/simple_state_card.dart`
- `lib/widgets/err_state_widget/too_many_request_widget.dart`
- `lib/widgets/err_state_widget/unknown_err_widget.dart`

It also auto-adds these dependencies in target `pubspec.yaml` (only if missing):

- `cupertino_icons: ^1.0.8`
- `dio: ^5.9.0`
- `rxdart: ^0.28.0`
- `shared_preferences: ^2.5.4`
- `path_provider: ^2.1.5`
- `permission_handler: ^12.0.1`
- `pretty_dio_logger: ^1.4.0`
- `pull_to_refresh: ^2.0.0`
- `lottie: ^3.3.2`
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

or use built-in command:

```bash
trh_template upgrade
```

`trh_template` command run တိုင်း (12 hours cache နဲ့) GitHub latest version စစ်ပေးပြီး update ရှိရင် command hint ပြပါမယ်။

Check current installed version:

```bash
trh_template --version
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

## Optional: avoid GitHub API rate limits

If update-check hits GitHub rate limit, set a token:

```bash
export GITHUB_TOKEN=your_github_personal_access_token
```

(`GH_TOKEN` is also supported.)

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
- `lib/core/models/pin_ob.dart`
- `lib/core/models/response_ob.dart`
- `lib/builders/refresh_builder/refresh_ui_builder.dart`

## Options

```bash
trh_template --help
```

- `-p, --path` target project path (default: current directory)
- `--dry-run` preview without writing folders
- `-f, --force` skip Flutter project validation
- `-v, --version` show installed CLI version

## Commands

- `trh_template` or `trh_template init` creates base folders + `core` subfolders
- `trh_template upgrade` (or `trh_template update`) upgrades CLI to latest from GitHub
- `trh_template page --name <name>` creates:
  - `lib/pages/<name>/`
  - `lib/pages/<name>/<name>_page.dart`
- `trh_template page --name <name> --stateful` creates StatefulWidget page
