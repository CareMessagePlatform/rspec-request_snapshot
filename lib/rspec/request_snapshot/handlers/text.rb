# frozen_string_literal: true

class Rspec::RequestSnapshot::Handlers::Text < Rspec::RequestSnapshot::Handlers::Base
  def compare(actual, expected)
    actual == expected
  end

  def comparable(str)
    str
  end

  def writable(str)
    str
  end
end
