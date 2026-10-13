[![Maintainability](https://api.codeclimate.com/v1/badges/1be4d92a8f565b0f2e86/maintainability)](https://codeclimate.com/github/RStankov/ConferenceBox/maintainability)

# ConferenceBox

Multi-conference CMS. Update from [TourConf](https://github.com/RStankov/it-tour).

### Installation

```
./bin/dev/boot
```

### Running

```
./bin/dev/start
```

### Themes

Public pages are rendered by one of three themes (`it_tour`, `not_a_conf`, `plain`), picked per conference. All of them share the design tokens in `app/assets/stylesheets/shared/_tokens.scss` and the components in `_components.scss`. The event color becomes the `--cb-accent` custom property on the `<html>` element, so a single value in the admin recolors the whole theme.

Theme JavaScript lives in `app/assets/javascripts/shared/` as small dependency-free modules (navigation, countdown, lightbox, cookie notice) that every theme manifest requires. The admin still uses jQuery and Backbone.
