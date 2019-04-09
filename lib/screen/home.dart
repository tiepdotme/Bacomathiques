import 'package:bacomathiques/app/app.dart';
import 'package:bacomathiques/app/lesson.dart';
import 'package:bacomathiques/util/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transparent_image/transparent_image.dart';

/// The home screen, where previews are shown.
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

/// The home screen state.
class _HomeScreenState extends State<HomeScreen> {
  /// A list of downloaded previews.
  List<Preview> _previews;

  /// Whether the screen is currently loading.
  bool _loading;

  /// Creates a new home screen state instance.
  _HomeScreenState()
      : this._previews = [],
        this._loading = true;

  @override
  void initState() {
    super.initState();
    Preview.request().then((previews) {
      if (previews != null) {
        _updatePreviews(previews);
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text('Impossible de charger la liste des cours et aucune sauvegarde n\'est disponible.\nVeuillez vérifier votre connexion internet et réessayer.'),
              actions: [
                FlatButton(
                  child: Text('Ok'.toUpperCase()),
                  onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                ),
              ],
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = _loading ? CenteredCircularProgressIndicator() : _PreviewsList(_previews);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _createLogoWidget(),
            _createTitleWidget(),
          ],
        ),
      ),
      body: body,
    );
  }

  /// Updates the list of previews.
  void _updatePreviews(List<Preview> previews) => setState(() {
        this._previews = previews;
        this._loading = false;
      });

  /// Creates the logo widget.
  Widget _createLogoWidget() => SvgPicture.asset(
        'assets/images/logo.svg',
        width: 30,
        semanticsLabel: 'Logo',
      );

  /// Creates the title widget.
  Widget _createTitleWidget() => Padding(
        padding: EdgeInsets.only(top: 5, left: 7),
        child: Text(
          App.APP_NAME,
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'handlee-regular',
          ),
        ),
      );
}

/// A widget to show a list of previews.
class _PreviewsList extends StatelessWidget {
  /// The previews.
  final List<Preview> _previews;

  /// Creates a new previews list widget instance.
  _PreviewsList(this._previews);

  @override
  Widget build(BuildContext context) {
    int columnCount = _getColumnCount(context);
    if (columnCount > 1) {
      return GridView.count(
        crossAxisCount: columnCount,
        childAspectRatio: 0.6,
        children: _previews.map((preview) => _PreviewWidget(preview, true)).toList(),
        semanticChildCount: _previews.length,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      semanticChildCount: _previews.length,
      scrollDirection: Axis.vertical,
      itemCount: _previews.length,
      itemBuilder: (context, position) => _PreviewWidget(_previews[position]),
    );
  }

  int _getColumnCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 1;
    }

    if (width < 800) {
      return 2;
    }

    return 3;
  }
}

/// A widget which shows a lesson preview.
class _PreviewWidget extends StatefulWidget {
  /// The preview.
  final Preview _preview;

  /// Whether it's tablet.
  final bool _tablet;

  /// Creates a new preview widget instance.
  _PreviewWidget(this._preview, [this._tablet = false]);

  @override
  State<StatefulWidget> createState() => _PreviewWidgetState();
}

/// The state of preview widgets.
class _PreviewWidgetState extends State<_PreviewWidget> {
  /// Whether this state is currently showing a caption.
  bool _showCaption;

  /// Creates a new preview widget state instance.
  _PreviewWidgetState() : this._showCaption = false;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.all(10),
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(App.CARD_BORDER_RADIUS),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _createTitleWidget(),
                _createPreviewWidget(),
                _createDescriptionWidget(widget._tablet),
                _createActionsWidget(widget._tablet),
              ],
            )),
      );

  /// Toggles the current caption.
  void _toggleCaption() => setState(() {
        _showCaption = !_showCaption;
      });

  /// Creates a new title widget.
  Widget _createTitleWidget() => Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Text(
          widget._preview.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontFamily: 'handlee-regular',
            color: Colors.white,
          ),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(App.CARD_BORDER_RADIUS),
            topRight: Radius.circular(App.CARD_BORDER_RADIUS),
          ),
          color: widget._preview.title.endsWith('(Spécialité)') ? App.SPECIALITY_COLOR : App.PRIMARY_COLOR,
        ),
      );

  /// Creates a new preview widget.
  Widget _createPreviewWidget() => GestureDetector(
        onTap: _toggleCaption,
        child: Stack(
          children: [
            FadeInImage.memoryNetwork(
              image: APIObject.WEBSITE + widget._preview.previewImage,
              placeholder: kTransparentImage,
              height: 100,
              fit: BoxFit.cover,
            ),
            Positioned.fill(
                child: AnimatedOpacity(
              opacity: _showCaption ? 1 : 0,
              duration: Duration(milliseconds: 200),
              child: Container(
                alignment: Alignment(0, 0),
                decoration: BoxDecoration(color: Color(0xB3000000)),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  widget._preview.caption,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ))
          ],
        ),
      );

  /// Creates a new description widget.
  Widget _createDescriptionWidget(bool tablet) {
    Widget description = Padding(
      padding: EdgeInsets.all(12),
      child: Html(
        data: widget._preview.content,
        useRichText: true,
        defaultTextStyle: Theme.of(context).textTheme.body1.copyWith(
              fontSize: 14,
            ),
      ),
    );

    return tablet
        ? Expanded(
            child: SingleChildScrollView(
              child: description,
            ),
          )
        : description;
  }

  /// Creates a new preview actions widget.
  Widget _createActionsWidget(bool tablet) {
    BoxDecoration decoration = tablet
        ? BoxDecoration(
            border: Border(
              top: BorderSide(
                color: App.ACCENT_COLOR.withAlpha(100),
              ),
            ),
          )
        : null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: decoration,
      child: Wrap(
        alignment: WrapAlignment.end,
        children: [
          FlatButton.icon(
            icon: Icon(
              Icons.assignment,
              color: App.ACCENT_COLOR,
            ),
            label: Text(
              'Lire le résumé'.toUpperCase(),
              style: Theme.of(context).textTheme.button.copyWith(fontSize: 14),
            ),
            onPressed: () => Navigator.pushNamed(
                  context,
                  '/html',
                  arguments: {
                    'relativeURL': widget._preview.summaryURL,
                    'requestObjectFunction': Summary.request,
                  },
                ),
            padding: EdgeInsets.symmetric(horizontal: 5),
          ),
          FlatButton.icon(
            icon: Icon(
              Icons.book,
              color: App.ACCENT_COLOR,
            ),
            label: Text(
              'Lire le cours'.toUpperCase(),
              style: Theme.of(context).textTheme.button.copyWith(fontSize: 14),
            ),
            onPressed: () => Navigator.pushNamed(
                  context,
                  '/html',
                  arguments: {
                    'relativeURL': widget._preview.contentURL,
                    'requestObjectFunction': Lesson.request,
                  },
                ),
            padding: EdgeInsets.symmetric(horizontal: 5),
          )
        ],
      ),
    );
  }
}