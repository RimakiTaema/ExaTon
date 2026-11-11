import 'package:exaton/features/settings/updates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('versions', () {
    test('tags with or without v and suffixes parse to x.y.z', () {
      expect(parseVersion('v1.7.2'), [1, 7, 2]);
      expect(parseVersion('1.10.0-beta.1'), [1, 10, 0]);
      expect(parseVersion('nightly'), isNull);
    });

    test('newer compares each part as a number', () {
      expect(isNewerVersion('1.7.3', '1.7.2'), isTrue);
      expect(isNewerVersion('1.10.0', '1.9.9'), isTrue);
      expect(isNewerVersion('v2.0.0', '1.99.99'), isTrue);
      expect(isNewerVersion('1.7.2', '1.7.2'), isFalse);
      expect(isNewerVersion('1.7.1', '1.7.2'), isFalse);
      expect(isNewerVersion('junk', '1.7.2'), isFalse);
    });
  });

  group('release JSON', () {
    Map<String, dynamic> json({String tag = 'v1.8.0', bool pre = false, bool draft = false}) => {
      'tag_name': tag,
      'html_url': 'https://github.com/RimakiTaema/ExaTon/releases/tag/$tag',
      'prerelease': pre,
      'draft': draft,
    };

    test('a published release', () {
      final r = releaseFromJson(json())!;
      expect(r.version, '1.8.0');
      expect(r.tag, 'v1.8.0');
      expect(r.url.path, '/RimakiTaema/ExaTon/releases/tag/v1.8.0');
    });

    test('pre-releases, drafts and unversioned tags are ignored', () {
      expect(releaseFromJson(json(pre: true)), isNull);
      expect(releaseFromJson(json(draft: true)), isNull);
      expect(releaseFromJson(json(tag: 'latest')), isNull);
      expect(releaseFromJson(const {}), isNull);
    });
  });
}
