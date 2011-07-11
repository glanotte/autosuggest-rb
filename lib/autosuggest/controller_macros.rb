require 'yajl'

module Autosuggest
  module ControllerMacros
    # when called, you must add a custom route for action like this:
    # resources :products do
    #   get :autosuggest_context, :on => :collection
    # end
    def autosuggest(context, options={})
      options[:limit] ||= 10
      
      define_method "autosuggest_#{context}" do
        
        results = ActsAsTaggableOn::Tag.named_like_on_context(params[:query], context).limit(options[:limit])
        #results = Kernel.const_get(self.controller_name.singularize.camelize).tag_counts_on(context).named_like(params[:query]).limit(options[:limit])
        
        render :json => Yajl::Encoder.encode(results.map{|r| {:name => r.name, :value => r.name}})
        
      end
      
    end
  end
end
