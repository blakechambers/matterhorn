require 'active_support/inflector'

# Taken from Remarkable 4.0.0 alpha
# https://github.com/remarkable/remarkable/blob/1e653044dfb9726034f600bae13d81e9986c44f6/remarkable_activerecord/spec/support/model_builder.rb
# and https://github.com/hosh/intermodal/blob/60966e52447430e048b546063deafa41bff7ed21/spec/support/app/class_builder.rb#L1
#
module ClassBuilder

  def unload_class(class_name)
    Object.send(:remove_const, class_name) if Object.const_defined?(class_name)
  end

  def define_class(class_name, base=nil, &block)
    class_name = class_name.to_s.camelize
    unload_class(class_name)

    base = base.nil? ? [] : [base]

    Class.new(*base).tap do |klass|
      Object.const_set(class_name, klass)
      klass.class_eval(&block) if block_given?
    end
  end

  def base_class
    @base_class ||= define_class(:BaseKlass) do
      include Mongoid::Document
      include Matterhorn::Links::LinkSupport
    end
  end

  def define_model(class_name, &block)
    define_class class_name, base_class, &block
  end
end
