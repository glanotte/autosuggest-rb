require 'simple_form'

module ActionView
  module Helpers
    module FormHelper
      def autosuggest_field(object_name, method, source, options={})
        text_field_class = "autosuggest_#{object_name}_#{method}"
        options[:class] = "#{options[:class].to_s} #{text_field_class}"
        autosuggest_options = options.delete(:autosuggest_options) || {}
        autosuggest_options.reverse_merge!("queryParam" => "query", "selectedItemProp" => "name", "searchObjProps" => "name", "neverSubmit" => "true", "asHtmlName" => "#{object_name}[set_#{method}]")
        autosuggest_options[:startText] = I18n.t("autosuggest.startText")
        autosuggest_options[:emptyText] = I18n.t("autosuggest.emptyText")
        autosuggest_options[:limitText] = I18n.t("autosuggest.limitText")
        autosuggest_options[:addNew] = I18n.t("autosuggest.addNew")
        
        _out = text_field(object_name, method, options)

        # removing name attribute since values will be returned in #{object_name}[set_#{method}]
        _out << raw(%{
          <script type="text/javascript">
            jQuery(document).ready(function(){jQuery('.#{text_field_class}').autoSuggest('#{source}', #{autosuggest_options.to_json}).removeAttr('name');});
          </script>
        })
        _out
      end
    end

    module FormTagHelper
      def autosuggest_field_tag(name, value, source, options={})
        text_field_class = "autosuggest_#{name}"
        options[:class] = "#{options[:class].to_s} #{text_field_class}"
        autosuggest_options = options.delete(:autosuggest_options) || {}
        autosuggest_options.reverse_merge!("queryParam" => "query", "selectedItemProp" => "name", "searchObjProps" => "name", "neverSubmit" => "true", "asHtmlName" => "#{name}")

        _out = text_field_tag(name, value, options)
        _out << raw(%{
          <script type="text/javascript">
            jQuery(document).ready(function(){
              jQuery('.#{text_field_class}').autoSuggest('#{source}', #{autosuggest_options.to_json});
            });
          </script>
        })
        _out
      end
    end
  end
end

class ActionView::Helpers::FormBuilder #:nodoc:
  def autosuggest_field(method, source, options = {})
    @template.autosuggest_field(@object_name, method, source, objectify_options(options))
  end
end

# simple form plugin
module SimpleForm
  module Inputs
    class AutosuggestInput < Base
      def input
        @builder.autosuggest_field(attribute_name, options[:url], input_html_options)
      end

    protected

      def limit
        column && column.limit
      end

      def has_placeholder?
        placeholder_present?
      end
    end
  end
end

module SimpleForm
  class FormBuilder
    map_type :autosuggest, :to => SimpleForm::Inputs::AutosuggestInput
  end
end
