import 'package:breaking_bapp/data_source.dart';
import 'package:breaking_bapp/model/character_summary.dart';
import 'package:breaking_bapp/presentation/common/response_view.dart';
import 'package:breaking_bapp/presentation/route_name_builder.dart';
import 'package:breaking_bapp/presentation/scene/character/list/character_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Fetches and displays a list of characters' summarized info.
class CharacterListPage extends StatefulWidget {
  @override
  _CharacterListPageState createState() => _CharacterListPageState();
}

// We're using `setState` as the state management approach to keep it as
// basic as possible and avoid taking the focus off the routing/navigation,
// which is the purpose of this tutorial.
class _CharacterListPageState extends State<CharacterListPage> {
  /// An object that identifies the currently active Future call. Used to avoid
  /// calling setState under two conditions:
  /// 1 - If this state is already disposed, e.g. if the user left this page
  /// before the Future completion.
  /// 2 - From duplicated Future calls, if somehow we call
  /// _fetchCharacterSummaryList two times in a row.
  Object _activeCallbackIdentity;

  List<CharacterSummary> _characterSummaryList;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    _fetchCharacterSummaryList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Characters'),
        ),
        body: ResponseView(
          isLoading: _isLoading,
          hasError: _hasError,
          onTryAgainTap: _fetchCharacterSummaryList,
          contentWidgetBuilder: (context) => ListView.builder(
            itemCount: _characterSummaryList.length,
            itemBuilder: (context, index) {
              final character = _characterSummaryList[index];
              return CharacterListItem(
                character: character,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    RouteNameBuilder.characterById(
                      character.id,
                    ),
                  );
                },
              );
            },
          ),
        ),
      );

  @override
  void dispose() {
    _activeCallbackIdentity = null;
    super.dispose();
  }

  Future<void> _fetchCharacterSummaryList() async {
    setState(() {
      _isLoading = true;
    });

    final callbackIdentity = Object();
    _activeCallbackIdentity = callbackIdentity;

    try {
      final fetchedCharacterList = await DataSource.getCharacterList();
      if (callbackIdentity == _activeCallbackIdentity) {
        setState(() {
          _characterSummaryList = fetchedCharacterList;
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
