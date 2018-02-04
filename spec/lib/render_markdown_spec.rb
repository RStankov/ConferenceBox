# frozen_string_literal: true

require 'spec_helper'

describe RenderMarkdown do
  it 'converts to html' do
    text = %(
# Title
**strong**
_italic_)

    html = %(<h1>Title</h1>

<p><strong>strong</strong>
<em>italic</em></p>
)

    expect(described_class.to_html(text)).to eq html
  end

  it 'accepts nil' do
    expect(described_class.to_html(nil)).to eq ''
  end
end
