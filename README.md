# animated_drag_gridview

该插件的灵感来源于DragableGridview 和 reorderable_grid_view， DragableGridview 已经很久没有更新了也不支持空安全版本，DragableGridview 使用 transform 来控制拖拽，拖拽的是本身自己，由于Gridview 渲染层级的原因，前面的item拖向后面的item 会被后面的item覆盖掉。而reorderable_grid_view 解决了这个层级的问题，但作者使用的是OverlayEntry，这将导致拖拽的小部件悬浮于一切之上，包括tabbar,使用时感觉很不舒服。
所以 animated_drag_gridview 使用的Stack + Positioned，这样可以避免这些问题。

[DragableGridview](https://github.com/baoolong/DragableGridview)

[reorderable_grid_view](https://github.com/huhuang03/reorderable_grid_view)


## Usage

Add this to your package's pubspec.yaml file:

	dependencies:
	  
    animated_drag_gridview:
      git:
        url: https://github.com/zhou-Flutter/animated_drag_gridview.git
        ref: master

## Import it

	import 'package:animated_drag_gridview/animated_drag_gridview.dart';

## Example
<div>
    <img width="28%" height="28%" src="https://raw.githubusercontent.com/zhou-Flutter/animated_drag_gridview/master/example/assets/example_01.jpg"/>
    <img width="28%" height="28%" src="https://raw.githubusercontent.com/zhou-Flutter/animated_drag_gridview/master/example/assets/example_02.gif"/>
</div>


    import 'package:flutter/material.dart';
    import 'package:animated_drag_gridview/animated_drag_gridview.dart';

    class DragGridView extends StatefulWidget {
    DragGridView({Key? key}) : super(key: key);

    @override
    State<DragGridView> createState() => _DragGridViewState();
    }

    class _DragGridViewState extends State<DragGridView> {
    bool isActive = false;
    @override
    void initState() {
        super.initState();
    }

    List items = [
        "张飞",
        '关羽',
        '李白',
        '刘备',
        '周瑜',
        '扁鹊',
        '上官',
        '苏烈',
        '元哥',
        '曹操',
        '廉颇',
        '夏侯',
        '梦琪',
    ];
    @override
    Widget build(BuildContext context) {
        return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: Text("频道设置", style: TextStyle(color: Colors.black)),
        ),
        body: Column(
            children: [
            topEdit(),
            AnimateDragGridView(
                crossAxisCount: 4,
                childAspectRatio: 2.2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                isOpenDragAble: true,
                isActive: isActive,
                fixedNum: 3,
                animationDuration: 350, //milliseconds
                longPressDuration: 600, //milliseconds
                padding: const EdgeInsets.symmetric(horizontal: 15),
                physics: const NeverScrollableScrollPhysics(),
                children: items.map((e) => buildItem(e)).toList(),
                tRWidget: tRWidget(),
                onReorder: (oldIndex, newIndex) {
                var removeItem = items.removeAt(oldIndex);
                items.insert(newIndex, removeItem);
                setState(() {});
                },
                onDeleteItem: (index) {
                items.removeAt(index);
                setState(() {});
                },
                onActive: (isActive) {
                this.isActive = isActive;
                setState(() {});
                },
                onTapItem: (index) {
                print("点击的item");
                print(index);
                },
            ),
            ],
        ),
        );
    }

    Widget tRWidget() {
        return Container(
        height: 15,
        width: 15,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 208, 208, 220),
            borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
            Icons.remove,
            color: Colors.white,
            size: 13,
        ),
        );
    }

    Widget buildItem(e) {
        return Container(
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 231, 236, 245),
            borderRadius: BorderRadius.circular(2),
        ),
        alignment: Alignment.center,
        child: Text(
            e.toString(),
            style: TextStyle(
            color: Color.fromARGB(255, 86, 86, 90),
            ),
        ),
        );
    }

    Widget topEdit() {
        return Container(
        padding: EdgeInsets.all(15),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
            Text(
                "我的频道",
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            SizedBox(width: 5),
            Text(
                isActive ? "长按可拖拽排序" : "点击进入频道",
                style: TextStyle(fontSize: 15, color: Colors.black26),
            ),
            Spacer(),
            InkWell(
                child: Text(
                isActive ? "完成" : "编辑",
                style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
                onTap: () {
                isActive = !isActive;
                setState(() {});
                },
            ),
            ],
        ),
        );
    }
    }

