import 'package:cloudnet/apis/cloudnetv3spec/model/cloudnet_node.dart';
import 'package:cloudnet/feature/dashboard/dashboard_page.dart';
import 'package:cloudnet/feature/feature/groups_page.dart';
import 'package:cloudnet/feature/login/login_handler.dart';
import 'package:cloudnet/feature/login/login_page.dart';
import 'package:cloudnet/feature/node/menu_node_page.dart';
import 'package:cloudnet/feature/node/node_handler.dart';
import 'package:cloudnet/feature/tasks/task_setup_page.dart';
import 'package:cloudnet/feature/tasks/tasks_page.dart';
import 'package:cloudnet/state/actions/node_actions.dart';
import 'package:cloudnet/state/app_state.dart';
import 'package:cloudnet/state/node_state.dart';
import 'package:cloudnet/utils/app_config.dart';
import 'package:cloudnet/utils/dialogs.dart';
import 'package:cloudnet/utils/router.dart';
import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showNodeDetails = false;

  @override
  void initState() {
    router.addListener(updateAppBar);
    super.initState();
  }

  @override
  void dispose() {
    router.removeListener(updateAppBar);
    super.dispose();
  }

  void updateAppBar() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, NodeState>(
      converter: (store) => store.state.nodeState,
      builder: (context, state) => Scaffold(
        body: widget.child,
        appBar: _appBar(),
        drawer: buildDrawer(state),
      ),
    );
  }

  bool isSetupPage() {
    final router = GoRouter.of(context);
    switch (router.location) {
      case TaskSetupPage.route:
        {
          return true;
        }
      default:
        {
          return false;
        }
    }
  }

  Widget _buildDetailsList(NodeState state) {
    final detailsNodes = state.nodes
        .map(
          (e) => ListTile(
            title: Text(
              e.name ?? '',
            ),
            leading: const Icon(
              Icons.cloud,
            ),
            selected: _isSelectedNode(e),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Navigator.pop(context);
                showDialog<AlertDialog>(
                  context: context,
                  builder: (context) {
                    return deleteDialog(
                      context,
                      onCancel: () {
                        Navigator.pop(context);
                      },
                      onDelete: () {
                        StoreProvider.dispatch(context, RemoveCloudNetNode(e));
                        Navigator.pop(context);
                      },
                      item: e.name ?? '',
                    );
                  },
                );
              },
            ),
            onLongPress: () => router.push(MenuNodePage.route, extra: e),
            onTap: () {
              setState(() {
                StoreProvider.dispatch(
                  context,
                  SelectCloudNetNode(e),
                );
                context.go(LoginPage.route);
                Navigator.pop(context);
              });
            },
          ),
        )
        .toSet()
        .toList();
    detailsNodes.add(
      ListTile(
        title: const Text('Add node'),
        onTap: () => router.push(MenuNodePage.route, extra: null),
        leading: const Icon(
          Icons.add,
        ),
      ),
    );
    return ListView(
      children: detailsNodes,
    );
  }

  bool _isSelectedNode(CloudNetNode e) {
    return nodeHandler.currentNode() != null &&
        (nodeHandler.currentNode()?.name == (e.name ?? ''));
  }

  Widget _buildDrawerList() {
    final enabled =
        !loginHandler.isExpired() && router.location != LoginPage.route;
    return ListView(
      children: [
        ListTile(
          title: const Text('Node'),
          selected: router.location == DashboardPage.route,
          onTap: () => {
            context.go(DashboardPage.route),
            Navigator.pop(context),
          },
          enabled: enabled,
        ),
        const ListTile(
          title: Text('Cluster'),
          enabled: false,
        ),
        const ListTile(
          title: Text('Database'),
          enabled: false,
        ),
        ListTile(
          title: const Text('Groups'),
          selected: router.location == GroupsPage.route,
          onTap: () => {
            context.go(GroupsPage.route),
            Navigator.pop(context),
          },
          enabled: enabled,
        ),
        ListTile(
          title: const Text('Tasks'),
          selected: router.location == TasksPage.route,
          onTap: () => {
            context.go(TasksPage.route),
            Navigator.pop(context),
          },
          enabled: enabled,
        ),
        const ListTile(
          title: Text('Services'),
          enabled: false,
          onTap: null,
        ),
        const ListTile(
          title: Text('Template Storage'),
          enabled: false,
        ),
        const ListTile(
          title: Text('Templates'),
          enabled: false,
        ),
        const ListTile(
          title: Text('Service Versions'),
          enabled: false,
        ),
        const ListTile(
          title: Text('Modules'),
          enabled: false,
        ),
      ],
    );
  }

  Drawer buildDrawer(NodeState state) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: Image(
              image: _getProfileIcon(),
            ),
            accountName:
                Text(nodeHandler.currentNode()?.toUrl() ?? 'No url provided'),
            accountEmail:
                Text(nodeHandler.currentNode()?.name ?? 'No node provided'),
            onDetailsPressed: () {
              setState(() {
                showNodeDetails = !showNodeDetails;
              });
            },
          ),
          Expanded(
              child: showNodeDetails
                  ? _buildDetailsList(state)
                  : _buildDrawerList())
        ],
      ),
    );
  }

  AppBar? _appBar() {
    return AppBar(
      title: Text(
        AppConfig().appName,
      ),
      centerTitle: true,
      actions: !loginHandler.isExpired() && loginHandler.accessToken() != null ? [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.exit_to_app),
        )
      ] : [],
    );
  }

  AssetImage _getProfileIcon() {
    if (AppConfig().isAlpha) {
      return const AssetImage('.github/assets/img/TeamDiscord-Icon.png');
    }
    if (AppConfig().isBeta) {
      return const AssetImage('.github/assets/img/Discord-Icon.png');
    }
    return const AssetImage('.github/assets/img/Logo.png');
  }
}
