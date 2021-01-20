import 'package:flutter/material.dart';

import 'choice_item.dart';

/// 单选、多选数组
///
/// [isCheckBox] 是否选中, 默认为 [false]
/// [selectedWidget] 选中的样式
/// [unselectedWidget] 未选中的样式
/// [items] 所有的选项组件[ChoiceItem]
///
@immutable
class ChoiceConfig {
  final bool isCheckBox;
  final Widget selectedWidget;
  final Widget unselectedWidget;

  final List<ChoiceItem> items;

  const ChoiceConfig(
      {this.isCheckBox = false,
      this.selectedWidget,
      this.unselectedWidget,
      @required this.items})
      : assert(items != null);
}
