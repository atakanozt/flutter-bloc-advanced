import 'package:dart_json_mapper/dart_json_mapper.dart';

@jsonSerializable
class Menu {
  @JsonProperty(name: 'id')
  final String id;
  @JsonProperty(name: 'name')
  final String name;
  @JsonProperty(name: 'description')
  final String description;
  @JsonProperty(name: 'url')
  final String url;
  @JsonProperty(name: 'icon')
  final String icon;
  @JsonProperty(name: 'orderPriority')
  final int orderPriority;
  @JsonProperty(name: 'active')
  final bool active;
  @JsonProperty(name: 'parent')
  final Menu? parent;
  @JsonProperty(name: 'level')
  final int level;
  @JsonProperty(name: 'leaf')
  final bool leaf;
  @JsonProperty(name: 'authorities')
  final List<String> authorities;

  const Menu({
    this.id = '',
    this.name = '',
    this.description = '',
    this.url = '',
    this.icon = '',
    this.orderPriority = 0,
    this.active = false,
    this.parent,
    this.level = 0,
    this.leaf = false,
    this.authorities = const [],
  });
}


