import 'package:breaking_bapp/data_source.dart';
import 'package:breaking_bapp/model/character_detail.dart';
import 'package:breaking_bapp/presentation/common/labeled_text.dart';
import 'package:breaking_bapp/presentation/common/response_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Page that fetches and displays a character's detailed info based on the
/// received id.
class CharacterDetailPage extends StatefulWidget {
  const CharacterDetailPage({
    this.id,
    this.name,
    Key key,
  })  : assert(id != null || name != null),
        super(key: key);

  final int id;
  final String name;

  @override
  _CharacterDetailPageState createState() => _CharacterDetailPageState();
}

// We're using `setState` as the state management approach to keep it as
// basic as possible and avoid taking the focus off the routing/navigation,
// which is the purpose of this tutorial.
class _CharacterDetailPageState extends State<CharacterDetailPage> {
  /// An object that identifies the currently active Future call. Used to avoid
  /// calling setState under two conditions:
  /// 1 - If this state is already disposed, e.g. if the user left this page
  /// before the Future completion.
  /// 2 - From duplicated Future calls, if somehow we call _fetchCharacter
  /// two times in a row.
  Object _activeCallbackIdentity;

  bool _isLoading = true;
  bool _hasError = false;
  CharacterDetail _character;
  static const _bodyItemsSpacing = 8.0;

  @override
  void initState() {
    _fetchCharacter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(_character?.name ?? ''),
        ),
        body: _buildScaffoldBody(context),
      );

  Widget _buildScaffoldBody(BuildContext context) => ResponseView(
        hasError: _hasError,
        isLoading: _isLoading,
        onTryAgainTap: _fetchCharacter,
        contentWidgetBuilder: (context) => Padding(
          padding: const EdgeInsets.all(
            _bodyItemsSpacing,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(_character.pictureUrl),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              LabeledText(
                label: 'Name',
                description: _character.name,
                horizontalAndBottomPadding: _bodyItemsSpacing,
              ),
              LabeledText(
                label: 'Nickname',
                description: _character.nickname,
                horizontalAndBottomPadding: _bodyItemsSpacing,
              ),
              LabeledText(
                label: 'Actor Name',
                description: _character.actorName,
                horizontalAndBottomPadding: _bodyItemsSpacing,
              ),
              LabeledText(
                label: 'Vital Status',
                description: _character.vitalStatus,
                horizontalAndBottomPadding: _bodyItemsSpacing,
              ),
              LabeledText(
                label: 'Occupations',
                description: _character.occupations.join(', '),
                horizontalAndBottomPadding: _bodyItemsSpacing,
              ),
              LabeledText(
                label: 'Seasons',
                description: _character.seasons.join(', '),
                horizontalAndBottomPadding: _bodyItemsSpacing,
              ),
            ],
          ),
        ),
      );

  @override
  void dispose() {
    _activeCallbackIdentity = null;
    super.dispose();
  }

  Future<void> _fetchCharacter() async {
    setState(() {
      _isLoading = true;
    });

    final callbackIdentity = Object();
    _activeCallbackIdentity = callbackIdentity;

    try {
      final fetchedCharacter =
          await DataSource.getCharacterDetail(id: widget.id, name: widget.name);
      if (callbackIdentity == _activeCallbackIdentity) {
        setState(() {
          _character = fetchedCharacter;
          _isLoading = false;
          _hasError = false;
        });
      }
    } on Exception {
      if (callbackIdentity == _activeCallbackIdentity) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }
}
