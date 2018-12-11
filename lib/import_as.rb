require "import_as/version"
require "ripper"
require "tempfile"

module ImportAs
  class Error < StandardError; end

  class ConstRewriter
    def initialize(const_hash)
      @rewriter = Class.new(Ripper::Filter) {
        private

        define_method(:on_const) do |t, f|
          f << const_hash.fetch(t.to_sym, t).to_s
        end

        def on_default(_, t, f)
          f << t
        end
      }
    end

    def rewrite(ruby)
      @rewriter.new(ruby).parse('')
    end
  end

  class DSL
    def initialize(&block)
      @as = block
    end

    def from(path)
      Tempfile.open(["import_as", ".rb"]) do |tf|
        new_source = rewrite(File.read(path))

        tf.write(new_source)
        tf.flush
        tf.close

        load tf.path
      end
    end

    private

    using Module.new {
      refine(Symbol) do
        def const_id?
          id = self
          Module.new.module_eval { const_set(id, true) rescue false }
        end
      end

      refine(RubyVM::AbstractSyntaxTree::Node) do
        def array?
          type == "NODE_ARRAY"
        end

        def const?
          type == "NODE_CONST"
        end

        def fcall?
          type == "NODE_FCALL"
        end

        def scope?
          type == "NODE_SCOPE"
        end

        def const_pair
          original_const_id, args = children

          raise Error unless original_const_id.const_id?
          raise Error unless args.array?

          head, *rest = args.children

          raise Error unless rest.size == 1 && rest[0].nil?
          raise Error unless head.fcall?

          as, args2 = head.children

          raise Error unless as == :as

          head2, *rest2 = args2.children

          raise Error unless rest.size == 1 && rest[0].nil?
          raise Error unless head2.const?
          raise Error unless head2.children.size == 1

          new_const_id = head2.children[0]

          raise Error unless new_const_id.const_id?

          [original_const_id, new_const_id]
        end
      end
    }

    def const_hash
      root = RubyVM::AbstractSyntaxTree.of(@as)

      raise Error unless root.scope?

      _tbl, _args, body = root.children

      raise Error unless body.fcall?

      [body.const_pair].to_h
    end

    def rewrite(rb)
      ConstRewriter.new(const_hash).rewrite(rb)
    end
  end

  def import(&block)
    DSL.new(&block)
  end

  refine(Object) do
    include ImportAs
  end
end
