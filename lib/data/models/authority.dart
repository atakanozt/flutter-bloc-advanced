import 'package:dart_json_mapper/dart_json_mapper.dart';

@jsonSerializable
class Authority {
  @JsonProperty(name: 'name')
  final String? name;

  const Authority({this.name});
}


