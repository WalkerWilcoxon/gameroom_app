import 'package:gameroom_app/utils/imports.dart';


/// Wrapper around [FutureBuilder] that displays a [CircularProgressIndicator] when waiting for the future to complete
class DownloadBuilder<T> extends StatelessWidget {
  final Widget Function(BuildContext, T) builder;
  final Future<T> future;
  final Key key;
  const DownloadBuilder({this.key, @required this.builder, @required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      key: key,
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        return snapshot.hasData
            ? builder(context, snapshot.data)
            : Center(child: CircularProgressIndicator());
      },
    );
  }
}
