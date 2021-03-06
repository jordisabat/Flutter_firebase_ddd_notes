import 'package:auto_route/auto_route.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_ddd_notes/application/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_ddd_notes/application/notes/note_actor/note_actor_bloc.dart';
import 'package:flutter_firebase_ddd_notes/application/notes/note_watcher/note_watcher_bloc.dart';
import 'package:flutter_firebase_ddd_notes/injection.dart';
import 'package:flutter_firebase_ddd_notes/presentation/notes/notes_overview/widgets/notes_overview_body_widget.dart';
import 'package:flutter_firebase_ddd_notes/presentation/routes/router.gr.dart'
    as r;

class NotesOverviewPage extends StatelessWidget {
  const NotesOverviewPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NoteWatcherBloc>(
          create: (context) => getIt<NoteWatcherBloc>()
            ..add(const NoteWatcherEvent.watchAllStarted()),
        ),
        BlocProvider<NoteActorBloc>(
          create: (context) => getIt<NoteActorBloc>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(listener: (context, state) {
            state.maybeMap(
              unauthenticated: (_) =>
                  ExtendedNavigator.of(context).replace(r.Routes.signInPage),
              orElse: () {},
            );
          }),
          BlocListener<NoteActorBloc, NoteActorState>(
            listener: (context, state) {
              state.maybeMap(
                deleteFailure: (state) {
                  FlushbarHelper.createError(
                    duration: const Duration(seconds: 5),
                    message: state.noteFailure.map(
                      unexpected: (_) =>
                          'Unexpected error occured with deleting.',
                      insufficientPermission: (_) =>
                          'Insufficient Permissions.',
                      unableToUpdate: (_) => 'Unable to update',
                    ),
                  ).show(context);
                },
                orElse: () {},
              );
            },
          )
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Notes'),
            leading: IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                context.bloc<AuthBloc>().add(const AuthEvent.signedOut());
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.indeterminate_check_box),
                onPressed: () {},
              )
            ],
          ),
          body: NotesOverviewBody(),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                // TODO: Navigate to NoteFormPage
              },
              child: const Icon(Icons.add)),
        ),
      ),
    );
  }
}
