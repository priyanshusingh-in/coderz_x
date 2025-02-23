enum JobType {
  fullTime,
  partTime,
  contract,
  remote,
  internship,
}

extension JobTypeExtension on JobType {
  String get displayName {
    switch (this) {
      case JobType.fullTime:
        return 'Full Time';
      case JobType.partTime:
        return 'Part Time';
      case JobType.contract:
        return 'Contract';
      case JobType.remote:
        return 'Remote';
      case JobType.internship:
        return 'Internship';
    }
  }
}
