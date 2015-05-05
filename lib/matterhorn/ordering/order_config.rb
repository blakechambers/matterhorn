module Matterhorn
  module Ordering
    class InvalidDefaultOrder < Exception;end;
    class InvalidOrder < Exception;end;
    class OrderConfig

      attr_accessor :allowed_orders, :default_order, :order_param

      def initialize(options={})
        @allowed_orders = options.fetch(:allowed_orders, {})
        @order_param    = options.fetch(:order_param, :order)
        @default_order  = options[:default_order]
      end

      def add_order(name, *order)
        allowed_orders[name] = order
      end

      def order_for(name)
        name = name.to_sym
        if name.in? allowed_orders.keys
          allowed_orders[name]
        else
          raise InvalidOrder
        end
      end
      
      def set_default_order(name)
        if name.in? allowed_orders.keys
          @default_order = name
        else
          raise InvalidDefaultOrder.new(name)
        end
      end

      def ==(other)
        allowed_orders == other.allowed_orders
      end

      def link_configs
        hsh = {}
        allowed_orders.each_pair do |k,v|
          hsh[k] = Links::LinkConfig.new(nil, :ordering, type: :ordering, order_params: { order: k })
        end
        hsh
      end

      def links(link_set_options)
        Links::LinkSet.new(link_configs, link_set_options)
      end

    end
  end
end
