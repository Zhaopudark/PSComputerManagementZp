import packaging.version
import re
import pathlib
import sys
if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python check_release_version.py <version> <release_note_path>")
        sys.exit(1)
    version = sys.argv[1]
    release_note_path = sys.argv[2]
    try:
        version = packaging.version.parse(version)
        release_note_path = pathlib.Path(release_note_path)
        assert release_note_path.exists(), f"Release note file does not exist: {release_note_path}"
        # max_version = packaging.version.parse('0.0.0')
        max_version = None
        # print(release_note_path.read_text())
        with open(release_note_path, 'r',encoding='utf-8') as file:
            for line in file:
                if re.match(r'^##', line):
                    matched = re.match(r'^#{1,2}\s*\w*\s*(?P<version_number>[.\w]*)$', line)
                    assert matched is not None
                    version_number = matched.groupdict()['version_number']
                    current_version = packaging.version.parse(version_number)
                    if max_version is None :
                        max_version = current_version
                    else:
                        assert max_version > current_version, f"Version number is not in a descending order in file: {release_note_path}"
        assert version.base_version == max_version.base_version, f"Version number {version} is not equal to the latest version {max_version} in file: {release_note_path}"
    except Exception as e:
        print(e)
        sys.exit(1) 