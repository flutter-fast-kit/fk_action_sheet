import 'dart:async';

import 'package:flutter/material.dart';

import 'action_item.dart';
import 'bottom_action_item.dart';
import 'choice_config.dart';
import 'choice_item.dart';
import 'top_action_item.dart';

/// 通用ActionSheet
///
/// [topActionItem] 头部组件, 如果为null则不显示
/// [actions] 中间的按钮组件
/// [content] 自定义中间区域
/// [choiceConfig] 选择框
/// [bottomActionItem] 底部取消按钮, 如果为null则不显示
/// [barrierColor] 遮罩颜色, 不能为透明色
/// [actionSheetColor] 组件的背景颜色
/// [isScrollControlled] 是否时全屏还是半屏
/// [isDismissible] 点击背景是否可以关闭
/// [enableDrag] 是否允许拖拽
///
Future<T?> showActionSheet<T>({
  required BuildContext context,
  List<ActionItem>? actions,
  Widget? content,
  ChoiceConfig? choiceConfig,
  TopActionItem? topActionItem,
  BottomActionItem? bottomActionItem,
  Color? barrierColor,
  Color? actionSheetColor,
  bool isScrollControlled = false,
  bool isDismissible = true,
  bool enableDrag = true,
}) async {
  assert(barrierColor != Colors.transparent, 'The barrier color cannot be transparent.');
  // 当有头部并且有标题的时候, 设置顶部圆角
  final roundedRectangleBorder = topActionItem == null
      ? null
      : const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ));

  return showModalBottomSheet<T>(
      context: context,
      elevation: 0,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: actionSheetColor ?? Theme.of(context).dialogBackgroundColor,
      barrierColor: barrierColor,
      shape: roundedRectangleBorder,
      builder: (ctx) {
        return _ActionSheet(
            actions: actions,
            content: content,
            choiceConfig: choiceConfig,
            topActionItem: topActionItem,
            bottomActionItem: bottomActionItem);
      });
}

/// 顶部组件
class _TopActionItemWidget extends StatelessWidget {
  final TopActionItem topActionItem;
  final VoidCallback? onDonePress;

  const _TopActionItemWidget({required this.topActionItem, this.onDonePress});

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];
    widgets.addAll([
      IconButton(
          splashColor: Colors.transparent,
          icon: const Icon(
            Icons.close,
            // size: 18,
          ),
          onPressed: () {
            if (topActionItem.cancelAction != null) {
              topActionItem.cancelAction!();
            } else {
              Navigator.pop(context);
            }
          }),
      Expanded(
          child: Text(
        topActionItem.title,
        style: const TextStyle().merge(topActionItem.titleTextStyle),
        textAlign: TextAlign.center,
        // style: topActionItem.titleTextStyle.copyWith({}),
      )),
      IconButton(
          splashColor: Colors.transparent,
          icon: const Icon(
            Icons.done,
            // size: 18,
          ),
          onPressed: onDonePress),
    ]);

    if (topActionItem.desc != null) {
      widgets.add(Expanded(
          child: Container(
              height: 50,
              alignment: Alignment.center,
              child: Text(
                topActionItem.desc!,
                style: const TextStyle(color: Colors.black45, fontSize: 12).merge(topActionItem.titleTextStyle),
                textAlign: TextAlign.center,
              ))));
    }

    return Container(
        child: Column(
      children: [
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgets,
        ),
        if (topActionItem.showBottomLine)
          const Divider(
            height: 0,
          )
        else
          const SizedBox(height: 0, width: 0)
      ],
    ));
  }
}

/// 底部组件
class _BottomActionItemWidget extends StatelessWidget {
  final BottomActionItem bottomActionItem;

  const _BottomActionItemWidget(this.bottomActionItem);

  @override
  Widget build(BuildContext context) {
    if (bottomActionItem == null) {
      return const SizedBox(height: 0, width: 0);
    }
    return Column(children: [
      Container(
        height: 10,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromRGBO(247, 248, 250, 1)
            : const Color.fromRGBO(247, 248, 250, 1),
      ),
      InkWell(
        onTap: bottomActionItem.onPressed ?? () => Navigator.of(context).pop(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              bottomActionItem.title,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
      )
    ]);
  }
}

/// ActionSheet
class _ActionSheet extends StatefulWidget {
  final List<ActionItem>? actions;
  final Widget? content;
  final ChoiceConfig? choiceConfig;
  final TopActionItem? topActionItem;
  final BottomActionItem? bottomActionItem;

  @override
  _ActionSheetState createState() => _ActionSheetState();

  const _ActionSheet({this.actions, this.content, this.choiceConfig, this.topActionItem, this.bottomActionItem});
}

class _ActionSheetState extends State<_ActionSheet> {
  List<Widget> widgets = [];
  late int _groupValue;
  Set<int> _checkBoxValue = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (widget.choiceConfig != null) {
        final List<ChoiceItem> selectedItems =
            widget.choiceConfig!.items.where((element) => element.isSelected == true).toList();
        final List<int> selectedItemsIndex = selectedItems.map((e) => widget.choiceConfig!.items.indexOf(e)).toList();

        if (widget.choiceConfig!.isCheckBox) {
          _checkBoxValue = selectedItemsIndex.toSet();
        } else {
          if (selectedItemsIndex.isNotEmpty) {
            _groupValue = selectedItemsIndex.first;
          }
        }
      }

      /// 添加中间操作按钮
      if (widget.actions != null) {
        widget.actions!.forEach((action) {
          final index = widget.actions!.indexOf(action);
          widgets.add(Container(
            width: double.infinity,
            // color: Colors.redAccent,
            // splashColor: Colors.redAccent,
            // onTap: action.onPressed,
            child: InkWell(
              onTap: action.onPressed,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  action.title,
                  style: const TextStyle(
                    fontSize: 14,
                  ).merge(action.titleTextStyle),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ));
          if (index < widget.actions!.length - 1) {
            widgets.add(const Divider(
              height: 0,
            ));
          }
        });
      }

      if (widget.content != null) {
        widgets.add(widget.content!);
      }

      setState(() {});
    });
  }

  List<Widget> _buildChoiceItems() {
    final List<Widget> choiceItems = [];
    if (widget.choiceConfig != null) {
      widget.choiceConfig!.items.forEach((item) {
        final index = widget.choiceConfig!.items.indexOf(item);

        choiceItems.add(__ChoiceItemWidget<int>(
            value: index,
            groupValue: widget.choiceConfig!.isCheckBox ? (_checkBoxValue.contains(index) ? index : -1) : _groupValue,
            title: item.title,
            titleTextStyle: item.titleTextStyle,
            selectedIcon: widget.choiceConfig.selectedIcon,
            unselectedIcon: widget.choiceConfig.unselectedIcon,
            leftIcon: item.leftIcon,
            onPress: (dynamic idx) {
              if (widget.choiceConfig!.isCheckBox) {
                if (_checkBoxValue.contains(idx as int)) {
                  _checkBoxValue.remove(idx);
                } else {
                  _checkBoxValue.add(idx);
                }
              } else {
                _groupValue = idx as int;
              }

              setState(() {});
            }));
        if (index < widget.choiceConfig!.items.length - 1) {
          choiceItems.add(const Divider(
            height: 0,
          ));
        }
      });
    }
    return choiceItems;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight - (screenHeight / 10),
        ),
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 275),
          curve: Curves.easeOutQuad,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
            if (widget.topActionItem != null) ...{
              _TopActionItemWidget(
                topActionItem: widget.topActionItem!,
                onDonePress: () {
                  if (widget.topActionItem!.doneAction != null) {
                    if (widget.choiceConfig!.isCheckBox) {
                      widget.topActionItem!.doneAction!(_checkBoxValue.toList());
                    } else {
                      widget.topActionItem!.doneAction!([_groupValue]);
                    }
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            },
            Flexible(
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  ...widgets,
                  ..._buildChoiceItems(),
                ],
              )),
            ),
            if (widget.bottomActionItem != null) ...{_BottomActionItemWidget(widget.bottomActionItem!)}
          ]),
        ),
      ),
    );
  }
}

/// 选择组件
class __ChoiceItemWidget<T> extends StatefulWidget {
  final T value;
  final T groupValue;
  final String title;
  final TextStyle? titleTextStyle;
  final Widget? leftIcon;
  final Widget? selectedIcon;
  final Widget? unselectedIcon;
  final ValueChanged<dynamic> onPress;

  const __ChoiceItemWidget(
      {this.leftIcon,
      this.titleTextStyle,
      this.selectedIcon,
      this.unselectedIcon,
      required this.title,
      required this.onPress,
      required this.value,
      required this.groupValue});

  @override
  _ChoiceItemWidgetState createState() => _ChoiceItemWidgetState();
}

class _ChoiceItemWidgetState extends State<__ChoiceItemWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        widget.onPress(widget.value as int);
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.leftIcon != null)
              widget.leftIcon!
            else
              const SizedBox(
                height: 0,
                width: 0,
              ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 12,
                ).merge(widget.titleTextStyle),
              ),
            )),
            if (widget.selectedIcon != null)
              widget.value == widget.groupValue ? widget.selectedIcon! : widget.unselectedIcon!
            else
              Icon(
                Icons.check_box,
                color: widget.value == widget.groupValue ? Colors.blueAccent : Colors.transparent,
              )
          ],
        ),
      ),
    );
  }
}
