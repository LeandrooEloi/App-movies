# MoviesPlus

App mobile feito em Flutter para explorar filmes usando a API do TMDB: listas (Populares, Bem avaliados, Em cartaz), detalhes do filme e ações como Favoritos e Assistir depois.

## Preview
> Coloque prints em `assets/screenshots/` e referencie aqui.

<img src="assets/screenshots/home.jpg" height="420" alt="Home"/>
<img src="assets/screenshots/details.jpg" height="420" alt="Detalhes"/>


## Funcionalidades
- Listas: Populares, Bem avaliados e Em cartaz
- Tela de detalhes com sinopse e gêneros
- Favoritar e Assistir depois (salvos localmente)
- Cache de imagens (posters/backdrops) via `cached_network_image`

## Tecnologias
- Flutter / Dart
- Provider (gerenciamento de estado)
- TMDB API
- CachedNetworkImage (cache de imagens)

## Como rodar (desenvolvimento)
### Pré-requisitos
- Flutter instalado
- Uma chave da API do TMDB

### Rodando o app
```bash
flutter pub get
flutter run --dart-define=TMDB_KEY=SUA_CHAVE_AQUI

