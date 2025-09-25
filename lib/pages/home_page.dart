import "package:flutter/material.dart";

enum SampleItem { itemOne, itemTwo, itemThree }

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    SampleItem? selectedItem;
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Home"),),
      body: Center(
        child: PopupMenuButton<SampleItem>(
          initialValue: selectedItem,

          itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
            const PopupMenuItem<SampleItem>(value: SampleItem.itemOne, child: Text('Item 1')),
            const PopupMenuItem<SampleItem>(value: SampleItem.itemTwo, child: Text('Item 2')),
            const PopupMenuItem<SampleItem>(value: SampleItem.itemThree, child: Text('Item 3')),
          ],
        ),
      ),
    );
  }
}
