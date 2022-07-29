import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_player/model/media.dart';
import 'package:media_player/model/media_repository.dart';
import 'package:media_player/view/video_player_widget.dart';
import 'package:provider/provider.dart';
import 'package:media_player/view_model/media_manager.dart';

class ListMediaView extends StatefulWidget {
  const ListMediaView({Key? key}) : super(key: key);

  @override
  State<ListMediaView> createState() => _ListMediaViewState();
}

class _ListMediaViewState extends State<ListMediaView> {
  late Future<List<Media>> _futureMedias;
  final mediaRepository = MediaRepository();
  final _formKey = GlobalKey<FormState>();
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureMedias = MediaRepository().fetchMedias();

  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: (kIsWeb) ? 0.0 : kTextTabBarHeight,
        title: const Text('Media List'),
      ),
      body: FutureBuilder<List<Media>>(
        future: _futureMedias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Stack(
                children: [
                  ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 500.0,
                      ),
                      child: buildListView(snapshot.data!)),
                  if (context.watch<MediaManager>().isVideoPlayerVisible)
                    VideoPlayerWidget(
                      videoId: context.read<MediaManager>().selectedVideoId,
                    ),
                  if (context.watch<MediaManager>().isEditorVisible)
                    buildEditor(
                      currentTitle: context.read<MediaManager>().currentTitle,
                      id: context.read<MediaManager>().selectedId,
                    ),
                ],
              );
            }
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget buildListView(List<Media> medias) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 100),
      opacity: context.read<MediaManager>().opacity,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            if (kIsWeb)
              Text(
                'Media List',
                style: Theme.of(context).textTheme.headline4,
              ),
            ListView.separated(
              shrinkWrap: true,
              itemCount: medias.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(
                height: 5.0,
              ),
              itemBuilder: (BuildContext context, int index) {
                return buildDismissible(medias: medias, index: index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDismissible({required List<Media> medias, required int index}) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
          color: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: AlignmentDirectional.centerStart,
          child: IconTheme(
            data: Theme.of(context).primaryIconTheme,
            child: const Icon(
              Icons.delete_forever,
            ),
          )),
      secondaryBackground: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: AlignmentDirectional.centerEnd,
        child: IconTheme(
          data: Theme.of(context).primaryIconTheme,
          child: const Icon(
            Icons.delete_forever,
          ),
        ),
      ),
      onDismissed: (DismissDirection direction) {
        handleOnDismissed(medias: medias, index: index);

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('video is deleted')));
      },
      confirmDismiss: (DismissDirection direction) {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content:
                  const Text("Are you sure you want to delete this video?"),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("Yes")),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("No"),
                ),
              ],
            );
          },
        );
      },
      child: buildTitleCard(medias: medias, index: index),
    );
  }

  Widget buildTitleCard({required List<Media> medias, required int index}) {
    return GestureDetector(
      onTap: () {
        context.read<MediaManager>().setVideoId(medias[index].videoId);
        context.read<MediaManager>().setIsIsVideoPlayerVisible(true);
        context.read<MediaManager>().setOpacity(0.2);
      },
      onLongPress: () {
        context.read<MediaManager>().setCurrentTitle(medias[index].title);
        context.read<MediaManager>().setId(medias[index].id);
        context.read<MediaManager>().setIsEditorVisible(true);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Container(
          alignment: Alignment.center,
          height: 60.0,
          child: Text(medias[index].title,
              style: Theme.of(context).textTheme.titleLarge),
        ),
      ),
    );
  }

  void handleOnDismissed({
    required List<Media> medias,
    required int index,
  }) async {
    await mediaRepository.deleteMedia(medias[index].id);
  }

  Widget buildEditor({
    required String currentTitle,
    required int id,
  }) {
    controller.text = currentTitle;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 200,
        maxWidth: 600,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              TextFormField(
                minLines: 1,
                maxLines: 10,
                controller: controller,
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('video title'),
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<MediaManager>().setIsEditorVisible(false);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      handleOnSaveButton(id, controller.text);

                    },
                    child: const Text('Save'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleOnSaveButton(int id, String newTitle) async {
    await mediaRepository.updateMedia(id, newTitle);
    setState(() {
      _futureMedias = MediaRepository().fetchMedias();
      context.read<MediaManager>().setIsEditorVisible(false);
    });

  }
}
