import 'dart:convert';
import 'dart:developer';

import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../core/constants/app_constants.dart';

class ProjectDiscussionRealtimeService {
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();

  bool _initialized = false;
  String? _currentChannel;

  Future<void> init({
    required void Function(bool connected) onConnectionChanged,
  }) async {
    if (_initialized) return;

    await _pusher.init(
      apiKey: AppConstants.pusherKey,
      cluster: AppConstants.pusherCluster,
      useTLS: true,
      onConnectionStateChange: (currentState, previousState) {
        log('PUSHER STATE: $previousState -> $currentState');

        final state = currentState.toString().toLowerCase();

        final connected = state == 'connected';

        onConnectionChanged(connected);
      },
      onError: (message, code, error) {
        log('PUSHER ERROR: $message | code: $code | error: $error');
        onConnectionChanged(false);
      },
      onSubscriptionSucceeded: (channelName, data) {
        log('PUSHER SUBSCRIBED: $channelName | $data');
        onConnectionChanged(true);
      },
      onEvent: (event) {
        log('PUSHER GLOBAL EVENT: ${event.channelName} | ${event.eventName} | ${event.data}');
      },
    );

    await _pusher.connect();
    _initialized = true;
  }

  Future<void> subscribeToDiscussion({
    required int projectId,
    required void Function(bool connected) onConnectionChanged,
    required void Function(Map<String, dynamic> data) onMessage,
  }) async {
    await init(onConnectionChanged: onConnectionChanged);

    final channelName = 'discussion.$projectId';

    if (_currentChannel == channelName) {
      log('PUSHER already subscribed to $channelName');
      return;
    }

    if (_currentChannel != null) {
      await unsubscribe();
    }

    _currentChannel = channelName;

    log('PUSHER subscribing to $channelName');

    await _pusher.subscribe(
      channelName: channelName,
      onEvent: (dynamic event) {
        log('PUSHER CHANNEL RAW EVENT: $event');

        try {
          final eventName = event.eventName?.toString() ?? '';
          final rawData = event.data;

          log('PUSHER CHANNEL EVENT: $eventName | $rawData');

          if (eventName != 'discussion.message' &&
              eventName != '.discussion.message') {
            return;
          }

          if (rawData == null) return;

          final decoded = rawData is String ? jsonDecode(rawData) : rawData;

          onMessage(Map<String, dynamic>.from(decoded));
        } catch (e) {
          log('PUSHER event handling error: $e');
        }
      },
    );
  }

  Future<void> unsubscribe() async {
    if (_currentChannel == null) return;

    await _pusher.unsubscribe(channelName: _currentChannel!);
    _currentChannel = null;
  }

  Future<void> disconnect() async {
    await unsubscribe();
    await _pusher.disconnect();
    _initialized = false;
  }
}
