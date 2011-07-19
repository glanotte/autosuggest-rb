require 'yajl'

module Autosuggest
  module ControllerMacros
    # when called, you must add a custom route for action like this:
    # resources :products do
    #   get :autosuggest_context, :on => :collection
    # end
    def autosuggest_tag(context, options={})
      options[:limit] ||= 10
      
      define_method "autosuggest_#{context}" do
        results = ActsAsTaggableOn::Tag.named_like_on_context(params[:query], context).limit(options[:limit])
        #results = Kernel.const_get(self.controller_name.singularize.camelize).tag_counts_on(context).named_like(params[:query]).limit(options[:limit])
        render :json => Yajl::Encoder.encode(results.map{|r| {:name => r.name, :value => r.name}})
      end
   
    end
    
    # when called, you must add a custom route for action like this:
    # resources :products do
    #   get :autosuggest_object_name, :on => :collection
    # end
    def autosuggest(object, name, options={})
      options[:display]     ||= name
      options[:limit]       ||= 10
      options[:name]          = name
      options[:search_in]   ||= [name]
      options[:order]       ||= "#{options[:search_in].first} ASC"

      define_method "autosuggest_#{object}_#{name}" do
        options.merge!(:query => params[:query], :object => object.to_s.camelize.constantize)
        query = ''
        values = []

        for column in options[:search_in]
          query += "#{column} ILIKE ? OR "
          values.push("#{options[:query]}%")
        end
        results = options[:object].where(query[0..-4], *values).order(options[:order]).limit(options[:limit])
        render :json => Yajl::Encoder.encode(results.map{|r| {:name => r.send(options[:display]), :value => r.id.to_s}})
      end
    end
    
  end
end
