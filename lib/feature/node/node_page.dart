import 'package:async_redux/async_redux.dart';
import 'package:cloudnet_v3_flutter/apis/cloudnetv3spec/model/menu_node.dart';
import 'package:cloudnet_v3_flutter/feature/dashboard/dashboard_page.dart';
import 'package:cloudnet_v3_flutter/feature/login/login_handler.dart';
import 'package:cloudnet_v3_flutter/feature/node/node_handler.dart';
import 'package:cloudnet_v3_flutter/state/app_state.dart';
import 'package:cloudnet_v3_flutter/utils/const.dart';
import 'package:cloudnet_v3_flutter/utils/i18n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NodePage extends StatefulWidget {
  const NodePage({Key? key}) : super(key: key);
  static const String route = '/node';
  static const String name = 'node';

  @override
  State<StatefulWidget> createState() => _NodePageState();
}

class _NodePageState extends State<NodePage> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _portController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  final _loginFormKey = GlobalKey<FormState>();
  late bool ssl = false;

  @override
  Widget build(BuildContext context) {
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _portController =
        TextEditingController.fromValue(const TextEditingValue(text: '2812'));
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();

    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        nodeHandler.load();
        final nodes = nodeHandler.nodeUrls.map(
          (e) => ListTile(
            selected: nodeHandler.currentBaseUrl() == e.url,
            title: Text(e.name!),
            onTap: () {
              nodeHandler.selectCurrentUrl(e);
              nodeHandler.load();
              _showLoginMask();
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                nodeHandler.deleteUrl(e);
              },
            ),
          ),
        );
        final menu = List<Widget>.empty(growable: true);
        menu.add(
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Nodes'),
          ),
        );
        menu.addAll(nodes);
        menu.add(
          ListTile(
            title: const Text('Add node'),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddNodeMask(),
            ),
          ),
        );
        return Scaffold(
          appBar: AppBar(title: const Text(appTitle)),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: menu,
            ),
          ),
          body: Center(
            child: Container(
              child: loginHandler.accessToken() != null
                  ? TextButton(
                      onPressed: () => {
                        context.go(DashboardPage.route),
                      },
                      child: const Text('Dashboard'),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  void _clearInputField(TextEditingController controller) {
    controller.clear();
  }

  void _showAddNodeMask() {
    showDialog<AlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(4),
                      child: TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          errorBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          hintText: 'Name',
                          labelText: 'Node Name',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _clearInputField(_nameController),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(4),
                      child: TextFormField(
                        controller: _addressController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          errorBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          labelText: 'Network Name',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                _clearInputField(_addressController),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(4),
                      child: TextFormField(
                        controller: _portController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          errorBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          labelText: 'Port',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                _clearInputField(_addressController),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          const Text('SSL'),
                          Switch(
                            value: ssl,
                            onChanged: (value) => {
                              setState(
                                () {
                                  ssl = value;
                                },
                              )
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(2.0),
                ),
              ),
              title: const Text('Add node'),
              actions: [
                TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      this.setState(
                        () {
                          final menuNode = MenuNode(
                            url:
                                '${ssl ? 'https' : 'http'}://${_addressController.value.text}:${_portController.text}',
                            name: _nameController.value.text,
                          );
                          nodeHandler.saveUrl(menuNode);
                          _formKey.currentState!.reset();
                          Navigator.pop(context);
                        },
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showLoginMask() {
    showDialog<AlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              content: Form(
                key: _loginFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(4),
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          errorBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          hintText: 'Username'.i18n,
                          labelText: 'Username'.i18n,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                _clearInputField(_usernameController),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(4),
                      child: TextFormField(
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          errorBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          labelText: 'Password'.i18n,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                _clearInputField(_passwordController),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(2.0),
                ),
              ),
              title: const Text('Login'),
              actions: [
                TextButton(
                  onPressed: () {
                    if (_loginFormKey.currentState!.validate()) {
                      loginHandler
                          .handleLogin(
                            _passwordController.text,
                            _usernameController.text,
                          )
                          .whenComplete(
                            () => {
                              this.setState(
                                () => Navigator.pop(context),
                              )
                            },
                          );
                    }
                  },
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                )
              ],
            );
          },
        );
      },
    );
  }

  void submitValue() {
    _formKey.currentState!.validate();
  }
}
