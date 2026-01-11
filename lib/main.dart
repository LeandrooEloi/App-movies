import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/rotas.dart';
import 'core/tema.dart';

import 'dados/local/favoritos_dao.dart';
import 'dados/local/historico_busca_dao.dart';
import 'dados/local/local_cache_filme_dao.dart';

import 'dados/tmdb/cliente_tmdb.dart';
import 'dados/tmdb/filmes_tmdb_datasource.dart';

import 'repositorios/filmes_repositorio.dart';
import 'repositorios/filmes_repositorio_impl.dart';

import 'viewmodels/busca_viewmodel.dart';
import 'viewmodels/detalhes_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/minha_lista_viewmodel.dart';

import 'views/busca_view.dart';
import 'views/detalhes_view.dart';
import 'views/home_view.dart';
import 'views/minha_lista_view.dart';

void main() {
  const tmdbKey = String.fromEnvironment('TMDB_KEY');
  if (tmdbKey.isEmpty) {
    // ignore: avoid_print
    print('TMDB_KEY vazio. Rode com --dart-define=TMDB_KEY=SEU_TOKEN');
  }

  runApp(App(tmdbKey: tmdbKey));
}

class App extends StatelessWidget {
  final String tmdbKey;
  const App({super.key, required this.tmdbKey});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Infra TMDb
        Provider<ClienteTmdb>(
          create: (_) => ClienteTmdb(apiKey: tmdbKey),
        ),
        Provider<FilmesTmdbDatasource>(
          create: (context) => FilmesTmdbDatasource(context.read<ClienteTmdb>().dio),
        ),

        // DAOs locais
        Provider<HistoricoBuscaDao>(create: (_) => HistoricoBuscaDao()),
        Provider<FavoritosDao>(create: (_) => FavoritosDao()),
        Provider<LocalCacheFilmeDao>(create: (_) => LocalCacheFilmeDao()),

        // Repositório (agora com cache do MVP4)
        Provider<FilmesRepositorio>(
          create: (context) => FilmesRepositorioImpl(
            context.read<FilmesTmdbDatasource>(),
            context.read<LocalCacheFilmeDao>(),
          ),
        ),

        // ViewModels
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(context.read<FilmesRepositorio>()),
        ),
        ChangeNotifierProvider(
          create: (context) => BuscaViewModel(
            context.read<FilmesRepositorio>(),
            context.read<HistoricoBuscaDao>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DetalhesViewModel(
            context.read<FilmesRepositorio>(),
            context.read<FavoritosDao>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => MinhaListaViewModel(
            context.read<FilmesRepositorio>(),
            context.read<FavoritosDao>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: temaApp(),
        initialRoute: Rotas.home,
        routes: {
          Rotas.home: (_) => const HomeView(),
          Rotas.busca: (_) => const BuscaView(),
          Rotas.minhaLista: (_) => const MinhaListaView(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == Rotas.detalhes) {
            final id = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => DetalhesView(idFilme: id),
            );
          }
          return null;
        },
      ),
    );
  }
}
