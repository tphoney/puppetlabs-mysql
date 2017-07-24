# frozen_string_literal: true
require 'pry'
module RuboCop
  module Cop
    module Lint
      class DecorateFunctionMessage < Cop

        def on_send(node)
          method_name = node.loc.selector.source
          return if !/raise|fail/.match(method_name)
          if method_name == "raise"
            receiver_node, method_name, *arg_nodes = *node
            if !arg_nodes.empty? && arg_nodes[0].type == :const && arg_nodes[1]
              how_bad_is_it(method_name, arg_nodes[1])
            end
          elsif method_name == "fail"
            receiver_node, method_name, *arg_nodes = *node
            if !arg_nodes.empty?
              how_bad_is_it(method_name, arg_nodes[0])
            end
          end
        end

        private

        def how_bad_is_it(method_name, message)
          case message.type
          when :begin, :str
            add_offense(message, :expression, "'#{method_name}' should have a decorator around the message")
          when :dstr
            add_offense(message, :expression, "'#{method_name}' interpolation is a sin")
          when :send
            if message.children[1] == :+
              add_offense(message, :expression, "'#{method_name}' should not use a multi-line string")
            end
          end
        end

        def autocorrect(node)
          ->(corrector) { corrector.insert_before(node.source_range , "_(")
          corrector.insert_after(node.source_range , ")") }
        end
      end
    end
  end
end
