// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.8

import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../painting/image_data.dart';

void main() {
  final MockHttpClient client = MockHttpClient();
  final MockHttpClientRequest request = MockHttpClientRequest();
  final MockHttpClientResponse response = MockHttpClientResponse();
  final MockHttpHeaders headers = MockHttpHeaders();

  testWidgets('Headers', (WidgetTester tester) async {
    HttpOverrides.runZoned<Future<void>>(() async {
      await tester.pumpWidget(Image.network(
        'https://www.example.com/images/frame.png',
        headers: const <String, String>{'flutter': 'flutter'},
      ));

      verify(headers.add('flutter', 'flutter')).called(1);

    }, createHttpClient: (SecurityContext _) {
      when(client.getUrl(any)).thenAnswer((_) => Future<HttpClientRequest>.value(request));
      when(request.headers).thenReturn(headers);
      when(request.close()).thenAnswer((_) => Future<HttpClientResponse>.value(response));
      when(response.contentLength).thenReturn(kTransparentImage.length);
      when(response.statusCode).thenReturn(HttpStatus.ok);
      when(response.listen(any)).thenAnswer((Invocation invocation) {
        final void Function(List<int>) onData = invocation.positionalArguments[0] as void Function(List<int>);
        final void Function() onDone = invocation.namedArguments[#onDone] as void Function();
        final void Function(Object, [ StackTrace ]) onError = invocation.namedArguments[#onError] as void Function(Object, [ StackTrace ]);
        final bool cancelOnError = invocation.namedArguments[#cancelOnError] as bool;
        return Stream<List<int>>.fromIterable(<List<int>>[kTransparentImage]).listen(onData, onDone: onDone, onError: onError, cancelOnError: cancelOnError);
      });
      return client;
    });
  }, skip: isBrowser); // https://github.com/flutter/flutter/issues/57187
}

class MockHttpClient extends Mock implements HttpClient {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {}

class MockHttpHeaders extends Mock implements HttpHeaders {}
