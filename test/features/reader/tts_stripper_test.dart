import 'package:flutter_test/flutter_test.dart';
import 'package:cuentitos/features/reader/tts_stripper.dart';

void main() {
  test('strips inline TTS tags', () {
    expect(stripTtsTags('Hello [pause] world'), 'Hello  world');
    expect(stripTtsTags('Test [long-pause] text [breath] here'), 'Test  text  here');
    expect(stripTtsTags('A [laugh] moment'), 'A  moment');
  });

  test('strips wrap TTS tags', () {
    expect(stripTtsTags('<soft>gentle words</soft>'), 'gentle words');
    expect(stripTtsTags('<whisper>shhh</whisper>'), 'shhh');
    expect(stripTtsTags('<slow><soft>nested</soft></slow>'), 'nested');
  });

  test('strips mixed tags', () {
    expect(
      stripTtsTags('Once upon [pause] a <soft>time</soft> there [breath] was'),
      'Once upon  a time there  was',
    );
  });

  test('leaves plain text unchanged', () {
    expect(stripTtsTags('Just a normal sentence.'), 'Just a normal sentence.');
  });

  test('handles empty input', () {
    expect(stripTtsTags(''), '');
  });
}
