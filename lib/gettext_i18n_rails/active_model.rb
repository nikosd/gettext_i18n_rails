module ActiveModel

  class GettextName < Name
    def initialize(klass)
      super(klass)

      parts = @i18n_key.to_s.split('.')
      parts.pop
      parts.map! {|k| k.camelize }
      parts << @human

      @i18n_key = parts.join("|").freeze
    end

    # Namespace::CarDealer -> s_('Namespace|Car dealer') -> 'Car dealer' if no translation was found
    def human(options={})

      # NOTE : Rethink about possibly re-integrating this for compliance with
      # ActiveModel::Name#human functionality where lookup_ancestors is also included
      # in the "context"/"scope" when looking for a translation
#      return _(@i18n_key) unless @klass.respond_to?(:lookup_ancestors) &&
#                                 @klass.respond_to?(:i18n_scope)
#
#      context = @klass.lookup_ancestors.map do |klass|
#        klass.model_name.i18n_key
#      end
#      context.shift
#      context << @i18n_key

      s_(@i18n_key)
    end
  end

  module Naming
    # Returns an ActiveModel::Name object for module. It can be
    # used to retrieve all kinds of naming-related information.
    def model_name
      @_model_name ||= ActiveModel::GettextName.new(self)
    end
  end

  module Translation
    # CarDealer.sales_count -> s_('CarDealer|Sales count') -> 'Sales count' if no translation was found
    def human_attribute_name(attribute, *args)
      s_(gettext_translation_for_attribute_name(attribute))
    end

    private

    def gettext_translation_for_attribute_name(attribute)
      "#{self}|#{attribute.to_s.split('.').map! {|a| a.gsub('_',' ').capitalize }.join('|')}"
    end
  end
end
