#= require jquery
#= require 'vendor/jquery.plugin'
#= require 'vendor/jquery.countdown'
#= require 'vendor/jquery.scroll_to'
#= require 'vendor/jquery.scrollspy'
#= require 'lib/lightbox'
#= require_self


$ ->
  headerHeight = 10 + ($('header').height() || 0)
  body = $('body')
  nav = body.find('nav')
  $(window)
    .on 'scroll', -> nav.toggleClass 'sticky', $(document).scrollTop() > headerHeight
    .trigger 'scroll'

  Lightbox.start()
