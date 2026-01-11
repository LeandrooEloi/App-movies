# MoviesPlus

App mobile feito em Flutter para explorar filmes usando a API do TMDB: listas (Populares, Bem avaliados, Em cartaz), detalhes do filme e ações como Favoritos e Assistir depois.

## Preview

##Tela Home
<img src="assets/screenshots/home.jpg" height="420" alt="Home"/>
##Tela Favoritos
<img src="assets/screenshots/favoritos.jpg" height="420" alt="Detalhes"/>
##Tela Assistir Depois
<img src="assets/screenshots/assistir_depois.jpg" height="420" alt="Detalhes"/>


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

## Build (APK release)
flutter build apk --release --dart-define=TMDB_KEY=SUA_CHAVE_AQUI

##Segurança da chave
A chave do TMDB não está versionada no repositório. Ela deve ser passada via --dart-define (recomendado) para evitar expor credenciais no GitHub.

##Estrutura (resumo)

lib/views/ → telas (UI)
lib/viewmodels/ → regras da tela/estado
lib/services/ ou lib/data/ → chamadas HTTP e integração com API

Autor
Leandro Oliveira
GitHub: https://github.com/LeandrooEloi



