# frozen_string_literal: true

module BreadcrumbHelper
  def breadcrumbs(*args)
    @_breadcrumbs ||= []
    @_breadcrumbs += args
    @_breadcrumbs
  end
end
