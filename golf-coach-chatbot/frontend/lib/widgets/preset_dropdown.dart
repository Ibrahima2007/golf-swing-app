import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PresetDropdown extends StatefulWidget {
  const PresetDropdown({
    super.key,
    required this.presets,
    required this.onSelect,
  });

  final List<String> presets;
  final ValueChanged<String> onSelect;

  @override
  State<PresetDropdown> createState() => _PresetDropdownState();
}

class _PresetDropdownState extends State<PresetDropdown> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: _expanded,
          onExpansionChanged: (expanded) => setState(() {
            _expanded = expanded;
          }),
          title: const Text(
            'Preset Questions',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: Icon(
            _expanded
                ? CupertinoIcons.chevron_up
                : CupertinoIcons.chevron_down,
          ),
          children: widget.presets
              .map(
                (question) => ListTile(
                  title: Text(question),
                  onTap: () => widget.onSelect(question),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

