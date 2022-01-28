class Contact {
  String id;
  String name;
  String phone;

  Contact({this.id, this.name, this.phone});

  Map toJson() => {'id': id, 'name': name, 'phone': phone};
}
