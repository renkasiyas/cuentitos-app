final _inlineTagPattern = RegExp(r'\[(pause|long-pause|breath|laugh|sigh|gasp)\]');
final _wrapTagPattern = RegExp(r'</?(?:soft|whisper|loud|slow|fast|emphasis|excited|sad|happy)>');

String stripTtsTags(String text) {
  return text
      .replaceAll(_inlineTagPattern, '')
      .replaceAll(_wrapTagPattern, '');
}
