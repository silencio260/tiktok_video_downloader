import 'package:flutter/material.dart';
import '../domain/models/settings_models.dart';

enum SettingsTemplateType { list, grouped }

/// Reusable Settings View Template
class SettingsView extends StatelessWidget {
  final List<SettingsSection> sections;
  final SettingsTemplateType templateType;
  final String? pageTitle;

  // Customization
  final Color? backgroundColor;
  final Color? sectionHeaderColor;

  const SettingsView({
    Key? key,
    required this.sections,
    this.templateType = SettingsTemplateType.list,
    this.pageTitle = 'Settings',
    this.backgroundColor,
    this.sectionHeaderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(pageTitle!),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (templateType == SettingsTemplateType.grouped) {
      return ListView.builder(
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (section.title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    section.title!.toUpperCase(),
                    style: TextStyle(
                      color:
                          sectionHeaderColor ?? Theme.of(context).primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: List.generate(section.tiles.length, (tileIndex) {
                    final tile = section.tiles[tileIndex];
                    final isLast = tileIndex == section.tiles.length - 1;
                    return Column(
                      children: [
                        _buildTile(context, tile),
                        if (!isLast) const Divider(height: 1, indent: 56),
                      ],
                    );
                  }),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Flat List Implementation
      return ListView(
        children: [
          for (final section in sections) ...[
            if (section.title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  section.title!,
                  style: TextStyle(
                    color: sectionHeaderColor ?? Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            for (final tile in section.tiles) _buildTile(context, tile),
            const Divider(),
          ],
        ],
      );
    }
  }

  Widget _buildTile(BuildContext context, SettingsTile tile) {
    return ListTile(
      leading:
          tile.customLeading ??
          (tile.icon != null ? Icon(tile.icon, color: tile.iconColor) : null),
      title: Text(tile.title),
      subtitle: tile.subtitle != null ? Text(tile.subtitle!) : null,
      trailing:
          tile.trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: tile.onTap,
    );
  }
}
