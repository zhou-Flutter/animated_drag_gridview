import 'dart:ffi';

import 'package:animated_drag_gridview/drag_gridview_mixin.dart';
import 'package:animated_drag_gridview/drag_info.dart';
import 'package:animated_drag_gridview/drag_item.dart';
import 'package:animated_drag_gridview/single_touch_recognizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

typedef ReorderCallback = void Function(int oldIndex, int newIndex);

typedef DeleteItemCallback = void Function(int currentIndex);

typedef ActiveCallback = void Function(bool isActive);

typedef OnTapItemCallback = void Function(int index);

class AnimateDragGridView extends StatefulWidget {
  int crossAxisCount;
  double mainAxisSpacing;
  double crossAxisSpacing;
  double childAspectRatio;
  ScrollPhysics? physics;

  ///动画时长 milliseconds
  final int animationDuration;

  ///长安时长 milliseconds
  final int longPressDuration;

  //item
  List<Widget> children = const <Widget>[];

  //GridView 的padding
  EdgeInsetsGeometry padding;

  ///是否可以拖拽
  final bool isOpenDragAble;

  ///是否激活
  final bool isActive;

  ///固定前几个标签
  final int fixedNum;

  ///激活item 时右上角 显示的 小部件
  Widget tRWidget;

  //编辑回调
  ActiveCallback? onActive;

  ///重新排序 回调
  final ReorderCallback onReorder;

  ///删除item 回调
  final DeleteItemCallback? onDeleteItem;

  /// 未激活时 点击item 的回调 可做跳转处理
  final OnTapItemCallback? onTapItem;

  AnimateDragGridView({
    this.physics,
    required this.children,
    this.onActive,
    required this.onReorder,
    this.onDeleteItem,
    this.onTapItem,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.childAspectRatio = 1.0,
    this.crossAxisCount = 3,
    this.padding = const EdgeInsets.all(0),
    this.isOpenDragAble = false,
    this.isActive = false,
    this.fixedNum = 0,
    this.tRWidget = const SizedBox(),
    this.animationDuration = 350,
    this.longPressDuration = 600,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimateDragGridView> createState() => _AnimateDragGridViewState();
}

class _AnimateDragGridViewState extends State<AnimateDragGridView>
    with DragGridViewMixin
    implements GestureCallback {
  @override
  void onPanEnd(int oldIndex, int newIndex) {
    // TODO: implement onPanEnd
    widget.onReorder(oldIndex, newIndex);
  }

  @override
  void onTapDelete(int currentIndex) {
    // TODO: implement onTapDelete
    if (widget.onDeleteItem == null) return;
    widget.onDeleteItem!(currentIndex);
  }

  @override
  void onActive(bool isActive) {
    // TODO: implement onTapDown
    if (widget.onActive == null) return;
    widget.onActive!(isActive);
  }

  @override
  void onTapItem(int index) {
    // TODO: implement onTapItem
    if (widget.onTapItem == null) return;
    widget.onTapItem!(index);
  }

  @override
  Widget build(BuildContext context) {
    return SingleTouchRecognizerWidget(
      child: Padding(
        padding: widget.padding,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GridView.builder(
              clipBehavior: Clip.none,
              shrinkWrap: true,
              physics: widget.physics,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.crossAxisCount,
                crossAxisSpacing: widget.crossAxisSpacing,
                mainAxisSpacing: widget.mainAxisSpacing,
                childAspectRatio: widget.childAspectRatio,
              ),
              itemCount: widget.children.length,
              itemBuilder: (BuildContext context, int index) {
                return item(index);
              },
            ),
            DragInfo(animationDuration: widget.animationDuration)
          ],
        ),
      ),
    );
  }

  Widget item(int index) {
    if (index >= widget.fixedNum) {
      return DragItem(
        key: GlobalKey(),
        index: index,
        itemChild: widget.children[index],
        gestureCallback: this,
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
        isOpenDragAble: widget.isOpenDragAble,
        isActive: widget.isActive,
        fixedNum: widget.fixedNum,
        tRWidget: widget.tRWidget,
        animationDuration: widget.animationDuration,
        longPressDuration: widget.longPressDuration,
      );
    }

    return GestureDetector(
      onTap: widget.isActive
          ? null
          : () {
              if (widget.onTapItem == null) return;
              widget.onTapItem!(index);
            },
      child: Opacity(
        opacity: widget.isActive ? 0.5 : 1,
        child: widget.children[index],
      ),
    );
  }
}

//手势回调
abstract class GestureCallback {
  void onTapDelete(int index);
  void onActive(bool isActive);
  void onPanEnd(int dragIndex, int toIndex);
  void onTapItem(int index);
}
