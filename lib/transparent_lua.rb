require 'rlua'

class TransparentLua
  SUPPORTED_SIMPLE_DATATYPES = [
      NilClass,
      TrueClass,
      FalseClass,
      Fixnum,
      Bignum,
      Float,
      Proc,
      String,
      Hash,
      Array,
  ]

  attr_reader :sandbox, :state

  # @param [Object] sandbox The object which will be made visible to the lua script
  # @param [Hash] options
  # @option options [Lua::State] :state (Lua::State.new) a lua state to use
  # @option options [Boolean] :leak_globals When true, all locals from the lua scope are set in the sandbox.
  #   The sandbox must store the values itself or an error will be raised.
  #   When false the locals are not reflected in the sandbox
  def initialize(sandbox, options = {})
    @sandbox    = sandbox
    @state      = options.fetch(:state) { Lua::State.new }
    leak_locals = options.fetch(:leak_globals) { false }
    setup(leak_locals)
  end

  # @param [String] script a lua script
  # @param [String] script_name the name of the lua script (#see Lua::State.__eval)
  # @return [Object] the return value of the lua script
  def call(script, script_name = nil)
    v = state.__eval(script, script_name)
    lua2rb(v)
  end

  private
  def setup(leak_globals = false)
    state.__load_stdlib :all

    global_metatable               = {
        '__index' => index_table(sandbox)
    }
    global_metatable['__newindex'] = newindex_table(sandbox) if leak_globals

    state._G.__metatable = global_metatable

    state.package.loaders    = Lua::Table.new(state)
    state.package.loaders[1] = ->(modname) do
      return "\n\tno module '#{modname}' available in sandbox" unless can_require_module? modname

      loader = ->(modname) do
        source = require_module(modname)
        state.__eval(source, "=#{modname}")
        true
      end

      state.package.loaded[modname] = loader
      loader
    end
  end

  def can_require_module?(modname)
    return false unless sandbox.respond_to? :can_require_module?

    sandbox.can_require_module? modname
  end

  def require_module(modname)
    fail NoMethodError,
         "#{sandbox} must respond to #require_module because it responds to #can_require_module?" unless sandbox.respond_to? :require_module

    String(sandbox.require_module(modname))
  end

  def getter_table(object)
    if SUPPORTED_SIMPLE_DATATYPES.include? object.class
      return object
    end

    metatable = {
        '__index'    => index_table(object),
        '__newindex' => newindex_table(object),
    }
    delegation_table(object, metatable)
  end

  def newindex_table(object)
    ->(t, k, v) do
      getter_table(object.public_send(:"#{k}=", lua2rb(v)))
    end
  end

  def index_table(object)
    ->(t, k, *newindex_args) do
      method = get_method(object, k)

      case method
      when ->(m) { m.arity == 0 }
        # No or mandatory arguments
        getter_table(object.public_send(k.to_sym, *newindex_args))
        # when ->(m) { m.parameters == [[:rest]] }
        #   # Forced to be a method
        #   method_table(method)
        # when ->(m) { m.arity < 0 }
        #   warn "Method #{method} has optional parameters. We dont like that"
        #   method_table(method)
      else
        method_table(method)
      end
    end
  end

  def get_method(object, method_name)
    fail NoMethodError, "#{object}##{method_name.to_s} is not a method (but might be a valid message which is not supported)" unless object.methods.include? method_name.to_sym
    object.method(method_name.to_sym)
  end

  # @param [Method] method
  def method_table(method)
    delegation_table(
        '__call' => ->(t, *args) do
          converted_args = args.collect do |arg|
            lua2rb(arg)
          end

          getter_table(method.call(*converted_args))
        end
    )
  end

  def delegation_table(object = nil, hash)
    tab                = Lua::Table.new(@state)
    tab.__rb_object_id = -> { object.__id__ } if object
    tab.__metatable    = hash
    tab
  end

  def lua2rb(v)
    case v
    when ->(t) { has_rb_object_id?(t) }
      ObjectSpace._id2ref(Integer(v.__rb_object_id))
    when ->(t) { Lua::Table === t && t.to_hash.keys.all? { |k| k.is_a? Numeric } }
      v.to_hash.values
    when Lua::Table
      v.to_hash
    else
      v
    end
  end

  def has_rb_object_id?(o)
    o.__rb_object_id
    true
  rescue NoMethodError
    false
  end
end
