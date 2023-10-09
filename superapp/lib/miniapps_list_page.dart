import 'package:flutter/material.dart';
import 'package:superapp/miniapp_web_page.dart';

class MiniappsListPage extends StatelessWidget {
  const MiniappsListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Miniapps'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Miniapp'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MiniappWebPage(
                    url: 'https://miniapps-bucket.website.yandexcloud.net',
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
