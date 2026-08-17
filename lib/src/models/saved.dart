import 'package:landpage/src/ui/screens/company.dart';

class SavedRoles {
  SavedRoles._();

  static final List<SelectedRole> roles = [];

  // NEW
  static final Set<String> appliedRoles = {};
}

class SelectedRole {
  final CompanyData company;
  final RoleData role;

  SelectedRole({
    required this.company,
    required this.role,
  });

  String get key => "${company.name}::${role.title}";
}