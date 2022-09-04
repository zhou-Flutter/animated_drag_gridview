import 'package:animated_drag_gridview/animated_drag_gridview.dart';
import 'package:animated_drag_gridview/drag_gridview_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DragInfo extends StatefulWidget {
  int animationDuration;
  DragInfo({
    required this.animationDuration,
    Key? key,
  }) : super(key: key);

  @override
  State<DragInfo> createState() => DragInfoState();
}

class DragInfoState extends State<DragInfo> with TickerProviderStateMixin {
  Offset updateOffset = Offset(0, 0); //移动的位置
  Offset dragInfoHome = Offset(0, 0); //目标位置

  bool isOnPaning = false;
  late DragGridViewMixin _listState;

  AnimationController? _dragInfoAnimation; //动画控制

  AnimationController? _controller; //size 大小动画

  Widget itemChild = const SizedBox();
  Widget tRWidget = const SizedBox(); //右上角 小组件
  double itemWidth = 0;
  double itemHeight = 0;

  @override
  void initState() {
    super.initState();
    _listState = DragGridViewMixin.of(context);
    _listState.dragInfo(this);
  }

  dragInfoStart(
    Offset updateOffset,
    Widget itemChild,
    Widget tRWidget,
    double itemWidth,
    double itemHeight,
  ) {
    this.itemChild = itemChild;
    this.updateOffset = updateOffset;
    this.itemWidth = itemWidth;
    this.itemHeight = itemHeight;
    this.tRWidget = tRWidget;
    isOnPaning = true;
    _controller = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this)
      ..forward();

    setState(() {});
  }

  dragInfoUpdate(Offset offset) {
    updateOffset = offset;
    setState(() {});
  }

  dragInfoCancel(currentIndex, toIndex, dragInfoOffset) {
    _controller!.reset();
    _controller!.dispose();
    //计算 dragInfo 落脚点
    dragInfoHome = dragInfoOffset;

    //动画控制器

    _dragInfoAnimation = AnimationController(vsync: this)
      ..duration = Duration(milliseconds: widget.animationDuration)
      ..addListener(rebuild)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _dragInfoAnimation?.dispose();
          _dragInfoAnimation = null;
          //重置当前状态
          updateOffset = Offset.zero;
          isOnPaning = false;
          _listState.dragCancalBack();
          setState(() {});
        }
      })
      ..forward(from: 0.0);
  }

  Offset get dragInfoOffset {
    if (_dragInfoAnimation != null) {
      return Offset.lerp(
        updateOffset,
        dragInfoHome,
        Curves.easeInOut.transform(_dragInfoAnimation!.value),
      )!;
    }
    return updateOffset;
  }

  @override
  Widget build(BuildContext context) {
    return isOnPaning == false
        ? const SizedBox()
        : Positioned(
            top: updateOffset.dy,
            left: updateOffset.dx,
            child: ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.1).animate(_controller!),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: itemWidth,
                    height: itemHeight,
                    child: itemChild,
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: tRWidget,
                  )
                ],
              ),
            ),
          );
  }

  //重新 build
  void rebuild() {
    if (mounted) {
      updateOffset = dragInfoOffset;
      setState(() {});
    }
  }
}
