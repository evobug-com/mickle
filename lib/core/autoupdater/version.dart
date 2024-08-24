class SemVer {
  final int major;
  final int minor;
  final int patch;

  SemVer(this.major, this.minor, this.patch);

  factory SemVer.fromString(String version) {
    final parts = version.split('.');
    if (parts.length != 3) {
      throw FormatException('Invalid version format');
    }
    return SemVer(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  @override
  String toString() {
    return '$major.$minor.$patch';
  }

  @override
  bool operator ==(Object other) {
    if (other is SemVer) {
      return major == other.major && minor == other.minor && patch == other.patch;
    }
    return false;
  }

  @override
  int get hashCode => major.hashCode ^ minor.hashCode ^ patch.hashCode;

  bool operator >(SemVer other) {
    if (major > other.major) {
      return true;
    } else if (major == other.major) {
      if (minor > other.minor) {
        return true;
      } else if (minor == other.minor) {
        return patch > other.patch;
      }
    }
    return false;
  }

  bool operator <(SemVer other) {
    if (major < other.major) {
      return true;
    } else if (major == other.major) {
      if (minor < other.minor) {
        return true;
      } else if (minor == other.minor) {
        return patch < other.patch;
      }
    }
    return false;
  }

  bool operator >=(SemVer other) {
    return this == other || this > other;
  }

  bool operator <=(SemVer other) {
    return this == other || this < other;
  }
}