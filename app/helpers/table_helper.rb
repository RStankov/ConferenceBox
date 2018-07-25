# frozen_string_literal: true

module TableHelper
  def table_for(records)
    table = TableBuilder.new
    yield table
    render 'admin/shared/table', table: table, records: records
  end

  class TableBuilder
    attr_reader :columns

    def initialize
      @columns = []
    end

    def column(name, options = {}, &block)
      @columns << TableColumn.new(name, options, &block)
    end

    def actions(&block)
      column '', class: 'table-actions', &block
    end

    def number(name, &block)
      column name, class: 'number', header_class: 'number', &block
    end

    def boolean(name, label: name)
      column label, class: 'number', header_class: 'boolean' do |record|
        record.public_send(name) ? '✅' : '❌'
      end
    end
  end

  class TableColumn
    def initialize(name, options, &block)
      @name = name
      @options = options || {}
      @block = block
    end

    def render_header(template)
      template.content_tag :th, display_name, class: @options[:header_class]
    end

    def render_column(template, record)
      content = @block ? template.capture { @block.call(record) } : record.public_send(@name)
      template.content_tag :td, content, class: @options[:class]
    end

    private

    def display_name
      if @name.is_a? Symbol
        @name.to_s.humanize
      else
        @name
      end
    end
  end
end
