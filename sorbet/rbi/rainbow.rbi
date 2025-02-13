# typed: false

module Rainbow
  sig { returns(T::Boolean) }
  attr_accessor :enabled

  class Color
    sig { returns(Symbol) }
    attr_reader :ground

    sig do
      params(
        ground: Symbol,
        values: T.any([Integer], [Integer, Integer, Integer])
      ).returns(Color)
    end
    def self.build(ground, values); end

    sig { params(hex: String).returns([Integer, Integer, Integer]) }
    def self.parse_hex_color(hex); end

    class Indexed < Color
      sig { returns(Integer) }
      attr_reader :num

      sig { params(ground: Symbol, num: Integer).returns(Indexed) }
      def initialize(ground, num); end

      sig { returns(T::Array[Integer]) }
      def codes; end
    end

    class Named < Indexed
      NAMES = T.let(nil, T::Hash[Symbol, Integer])

      sig { returns(T::Array[Symbol]) }
      def self.color_names; end

      sig { returns(String) }
      def self.valid_names; end

      sig { params(ground: Symbol, name: Symbol).returns(Named) }
      def initialize(ground, name); end
    end

    class RGB < Indexed
      sig { returns(Integer) }
      attr_accessor :r, :g, :b

      sig { params(value: Numeric).returns(Integer) }
      def to_ansi_domain(value); end

      sig { params(ground: Symbol, values: Integer).returns(RGB) } 
      def initialize(ground, *values); end

      sig { returns(T::Array[Integer]) }
      def codes; end
    end

    class X11Named < RGB
      include X11ColorNames

      sig { returns(T::Array[Symbol]) }
      def self.color_names; end

      sig { returns(String) }
      def self.valid_names; end

      sig { params(ground: Symbol, name: Symbol).returns(X11Named) }
      def initialize(ground, name); end
    end
  end

  sig { returns(Wrapper) }
  def self.global; end

  sig { returns(T::Boolean) }
  def self.enabled; end

  sig { params(value: T::Boolean).returns(T::Boolean) }
  def self.enabled=(value); end

  sig { params(string: String).returns(String) }
  def self.uncolor(string); end

  class NullPresenter < String
    sig { params(values: T.any([Integer], [Integer, Integer, Integer])).returns(NullPresenter) }
    def color(*values); end

    sig { params(values: T.any([Integer], [Integer, Integer, Integer])).returns(NullPresenter) }
    def background(*values); end

    sig { returns(NullPresenter) }
    def reset; end

    sig { returns(NullPresenter) }
    def bright; end

    sig { returns(NullPresenter) }
    def faint; end

    sig { returns(NullPresenter) }
    def italic; end

    sig { returns(NullPresenter) }
    def underline; end

    sig { returns(NullPresenter) }
    def blink; end

    sig { returns(NullPresenter) }
    def inverse; end

    sig { returns(NullPresenter) }
    def hide; end

    sig { returns(NullPresenter) }
    def cross_out; end

    sig { returns(NullPresenter) }
    def black; end

    sig { returns(NullPresenter) }
    def red; end

    sig { returns(NullPresenter) }
    def green; end

    sig { returns(NullPresenter) }
    def yellow; end

    sig { returns(NullPresenter) }
    def blue; end

    sig { returns(NullPresenter) }
    def magenta; end

    sig { returns(NullPresenter) }
    def cyan; end

    sig { returns(NullPresenter) }
    def white; end

    alias foreground color
    alias fg color
    alias bg background
    alias bold bright
    alias dark faint
    alias strike cross_out
  end

  class Presenter < String
    TERM_EFFECTS = T.let(nil, T::Hash[Symbol, Integer])

    sig { params(values: T.any([Integer], [Integer, Integer, Integer])).returns(Presenter) }
    def color(*values); end

    sig { params(values: T.any([Integer], [Integer, Integer, Integer])).returns(Presenter) }
    def background(*values); end

    sig { returns(Presenter) }
    def reset; end

    sig { returns(Presenter) }
    def bright; end

    sig { returns(Presenter) }
    def faint; end

    sig { returns(Presenter) }
    def italic; end

    sig { returns(Presenter) }
    def underline; end

    sig { returns(Presenter) }
    def blink; end

    sig { returns(Presenter) }
    def inverse; end

    sig { returns(Presenter) }
    def hide; end

    sig { returns(Presenter) }
    def cross_out; end

    sig { returns(Presenter) }
    def black; end

    sig { returns(Presenter) }
    def red; end

    sig { returns(Presenter) }
    def green; end

    sig { returns(Presenter) }
    def yellow; end

    sig { returns(Presenter) }
    def blue; end

    sig { returns(Presenter) }
    def magenta; end

    sig { returns(Presenter) }
    def cyan; end

    sig { returns(Presenter) }
    def white; end

    alias foreground color
    alias fg color
    alias bg background
    alias bold bright
    alias dark faint
    alias strike cross_out
  end

  class StringUtils
    sig { params(string: String, codes: T::Array[Integer]).returns(String) }
    def self.wrap_with_sgr(string, codes); end

    sig { params(string: String).returns(String) }
    def uncolor(string); end
  end

  VERSION = T.let(nil, String)

  class Wrapper
    sig { returns(T::Boolean) }
    attr_accessor :enabled

    sig { params(enabled: T::Boolean).returns(Wrapper) }
    def initialize(enabled = true); end
  
    sig { params(string: String).returns(T.any(Rainbow::Presenter, Rainbow::NullPresenter)) }
    def wrap(string); end
  end

  module X11ColorNames
    NAMES = T.let(nil, T::Hash[Symbol, [Integer, Integer, Integer]])
  end
end

sig { params(string: String).returns(Rainbow::Presenter) }
def Rainbow(string); end