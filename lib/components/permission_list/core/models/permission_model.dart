class Permission {
  final String id;
  final String name;
  final String description;
  final String category;
  final bool implemented;

  const Permission(this.category, this.id, this.name, this.description, this.implemented);
}