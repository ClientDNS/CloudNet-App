import 'package:cloudnet/apis/cloudnetv3spec/model/group_configuration.dart';
import 'package:cloudnet/apis/cloudnetv3spec/model/node_info.dart';
import 'package:cloudnet/apis/cloudnetv3spec/model/service_task.dart';
import 'package:cloudnet/apis/cloudnetv3spec/model/service_version_type.dart';
import 'package:cloudnet/apis/cloudnetv3spec/model/templatestorage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cloudnet_node.freezed.dart';
part 'cloudnet_node.g.dart';


@freezed
class CloudNetNode with _$CloudNetNode {

  const factory CloudNetNode({
    @JsonKey(name: 'ssl') @Default(false) bool ssl,
    @JsonKey(name: 'connected') @Default(false) bool connected,
    @JsonKey(name: 'loggedin') @Default(false) bool loggedin,
    @JsonKey(name: 'host') String? host,
    @JsonKey(name: 'port') int? port,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'token') String? token,
    @JsonKey(name: 'node_info') NodeInfo? nodeInfo,
    @JsonKey(name: 'tasks') @Default(<ServiceTask>[]) List<ServiceTask> tasks,
    @JsonKey(name: 'groups') @Default(<GroupConfiguration>[]) List<GroupConfiguration> groups,
    @JsonKey(name: 'versions') @Default(<ServiceVersionType>[]) List<ServiceVersionType> versions,
    @JsonKey(name: 'template_storage') TemplateStorage? templateStorage,
}) = _CloudNetNode;


  factory CloudNetNode.fromJson(Map<String, dynamic> json) =>
      _$CloudNetNodeFromJson(json);
}