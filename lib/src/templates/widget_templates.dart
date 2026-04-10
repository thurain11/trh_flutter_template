
const loadingWidgetTemplate = '''
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final double? size;

  const LoadingWidget({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    final double indicatorSize = size ?? 36;
    return SizedBox(
      width: indicatorSize,
      height: indicatorSize,
      child: const CircularProgressIndicator(strokeWidth: 3),
    );
  }
}
''';

const connectionTimeoutWidgetTemplate = '''
import 'package:flutter/material.dart';

import 'simple_state_card.dart';

class ConnectionTimeoutWidget extends StatelessWidget {
  final VoidCallback? fun;
  final double? widgetSize;

  const ConnectionTimeoutWidget({super.key, this.fun, this.widgetSize});

  @override
  Widget build(BuildContext context) {
    return SimpleStateCard(
      icon: Icons.timer_off_outlined,
      title: 'Connection timeout',
      actionText: 'Retry',
      onPressed: fun,
      size: widgetSize,
    );
  }
}
''';

const errWidgetTemplate = '''
import 'package:flutter/material.dart';

import '../../core/models/response_ob.dart';
import 'connection_timeout_widget.dart';
import 'no_internet_widget.dart';
import 'no_login_widget.dart';
import 'not_found_widget.dart';
import 'server_err_widget.dart';
import 'server_maintenance_widget.dart';
import 'too_many_request_widget.dart';
import 'unknown_err_widget.dart';

class ErrWidget extends StatelessWidget {
  final ErrState? errState;
  final VoidCallback? fun;
  final double? widgetSize;

  const ErrWidget(this.errState, this.fun, {super.key, this.widgetSize});

  @override
  Widget build(BuildContext context) {
    switch (errState) {
      case ErrState.no_internet:
        return NoInternetWidget(fun: fun, widgetSize: widgetSize);
      case ErrState.connection_timeout:
        return ConnectionTimeoutWidget(fun: fun, widgetSize: widgetSize);
      case ErrState.not_found:
        return NotFoundWidget(fun: fun, widgetSize: widgetSize);
      case ErrState.server_error:
        return ServerErrWidget(fun: fun, widgetSize: widgetSize);
      case ErrState.too_many_request:
        return TooManyRequestWidget(fun: fun, widgetSize: widgetSize);
      case ErrState.no_login:
        return const NoLoginWidget();
      case ErrState.server_maintain:
        return ServerMaintenanceWidget(fun: fun, widgetSize: widgetSize);
      case ErrState.unknown_err:
      case ErrState.validate_err:
      case ErrState.not_supported:
      case null:
        return UnknownErrWidget(fun: fun, widgetSize: widgetSize);
    }
  }
}
''';

const moreWidgetTemplate = '''
import 'package:flutter/material.dart';

import 'simple_state_card.dart';

class MoreWidget extends StatelessWidget {
  final dynamic data;

  const MoreWidget(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    final String message = _messageFrom(data);
    return SimpleStateCard(icon: Icons.info_outline, title: message);
  }

  String _messageFrom(dynamic value) {
    if (value is Map<String, dynamic>) {
      final dynamic msg = value['message'] ?? value['msg'] ?? value['error'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString();
      }
    } else if (value != null) {
      final String txt = value.toString().trim();
      if (txt.isNotEmpty) return txt;
    }
    return 'Something went wrong';
  }
}
''';

const noInternetWidgetTemplate = '''
import 'package:flutter/material.dart';

import 'simple_state_card.dart';

class NoInternetWidget extends StatelessWidget {
  final VoidCallback? fun;
  final double? widgetSize;

  const NoInternetWidget({super.key, this.fun, this.widgetSize});

  @override
  Widget build(BuildContext context) {
    return SimpleStateCard(
      icon: Icons.wifi_off_outlined,
      title: 'No internet connection',
      actionText: 'Retry',
      onPressed: fun,
      size: widgetSize,
    );
  }
}
''';

const noLoginWidgetTemplate = '''
import 'package:flutter/material.dart';

import 'simple_state_card.dart';

class NoLoginWidget extends StatelessWidget {
  final String? message;

  const NoLoginWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return SimpleStateCard(
      icon: Icons.lock_outline,
      title: message ?? 'You need to login',
    );
  }
}
''';

const notFoundWidgetTemplate = '''
import 'package:flutter/material.dart';

import 'simple_state_card.dart';

class NotFoundWidget extends StatelessWidget {
  final VoidCallback? fun;
  final double? widgetSize;

  const NotFoundWidget({super.key, this.fun, this.widgetSize});

  @override
  Widget build(BuildContext context) {
    return SimpleStateCard(
      icon: Icons.search_off_outlined,
      title: 'Data not found',
      actionText: 'Retry',
      onPressed: fun,
      size: widgetSize,
    );
  }
}
''';

const serverErrWidgetTemplate = '''
import 'package:flutter/material.dart';

import 'simple_state_card.dart';

class ServerErrWidget extends StatelessWidget {
  final VoidCallback? fun;
  final double? widgetSize;

  const ServerErrWidget({super.key, this.fun, this.widgetSize});

  @override
  Widget build(BuildContext context) {
    return SimpleStateCard(
      icon: Icons.cloud_off_outlined,
      title: 'Internal server error',
      actionText: 'Retry',
      onPressed: fun,
      size: widgetSize,
    );
  }
}
''';

const serverMaintenanceWidgetTemplate = '''
import 'package:flutter/material.dart';

import 'simple_state_card.dart';

class ServerMaintenanceWidget extends StatelessWidget {
  final VoidCallback? fun;
  final double? widgetSize;

  const ServerMaintenanceWidget({super.key, this.fun, this.widgetSize});

  @override
  Widget build(BuildContext context) {
    return SimpleStateCard(
      icon: Icons.settings_suggest_outlined,
      title: 'Server is under maintenance',
      actionText: 'Retry',
      onPressed: fun,
      size: widgetSize,
    );
  }
}
''';

const simpleStateCardTemplate = '''
import 'package:flutter/material.dart';

class SimpleStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? actionText;
  final VoidCallback? onPressed;
  final double? size;

  const SimpleStateCard({
    super.key,
    required this.icon,
    required this.title,
    this.actionText,
    this.onPressed,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double iconSize = size ?? 44;
    final bool hasAction =
        (actionText?.isNotEmpty ?? false) && onPressed != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: iconSize, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                if (hasAction) ...<Widget>[
                  const SizedBox(height: 16),
                  FilledButton(onPressed: onPressed, child: Text(actionText!)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
''';

const tooManyRequestWidgetTemplate = '''
import 'package:flutter/material.dart';

import 'simple_state_card.dart';

class TooManyRequestWidget extends StatelessWidget {
  final VoidCallback? fun;
  final double? widgetSize;

  const TooManyRequestWidget({super.key, this.fun, this.widgetSize});

  @override
  Widget build(BuildContext context) {
    return SimpleStateCard(
      icon: Icons.hourglass_top_outlined,
      title: 'Too many requests',
      actionText: 'Retry',
      onPressed: fun,
      size: widgetSize,
    );
  }
}
''';

const unknownErrWidgetTemplate = '''
import 'package:flutter/material.dart';

import 'simple_state_card.dart';

class UnknownErrWidget extends StatelessWidget {
  final VoidCallback? fun;
  final double? widgetSize;

  const UnknownErrWidget({super.key, this.fun, this.widgetSize});

  @override
  Widget build(BuildContext context) {
    return SimpleStateCard(
      icon: Icons.error_outline,
      title: 'Unknown error',
      actionText: 'Retry',
      onPressed: fun,
      size: widgetSize,
    );
  }
}
''';
