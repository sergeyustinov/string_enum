# frozen_string_literal: true

require 'active_model'

module StringEnumerate
  module Models
    extend ActiveSupport::Concern
 
    module ClassMethods
      def enumerate(*fields)
        set_enumerate_fields fields
        before_validation :set_enum_fields
      end

      def set_enumerate_fields(fields) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Naming/AccessorMethodName
        enumerate_fields = class_variable_get(:@@enumerate_fields) rescue nil # rubocop:disable Style/RescueModifier
        enumerate_fields ||= {}.with_indifferent_access

        enumerate_fields[name.underscore] ||= {}

        fields.each do |field|
          if field.is_a?(Hash)
            (prefix = field[:prefix]) || (suffix = field[:suffix])
            set_default = field[:set_default]
            field = field[:field]
          else
            prefix = nil
            suffix = nil
            set_default = nil
          end

          enumeration_labels(field).each_with_object(prepared_labels = {}) do |k|
            key = k.is_a?(Array) ? k.first : k
            prepared_labels[key] = key
          end

          enumerate_fields[name.underscore][field] = {
            field => prepared_labels,
            _prefix: prefix,
            _suffix: suffix
          }

          enum enumerate_fields[name.underscore][field]

          enumerate_fields[name.underscore][field][:set_default] = set_default
        end

        class_variable_set :@@enumerate_fields, enumerate_fields
      end

      def enumeration_labels(field)
        if (res = MODELS[name.underscore] && MODELS[name.underscore][field.to_s.pluralize])
          return res
        end

        raise(
          "Please set list of values in config/model.yml
          for model '#{name.underscore}' with key '#{field.to_s.pluralize}'"
        )
      end

      def enumeration_key_by_index(field, index)
        enumeration_labels(field).to_a[index.to_i].first
      end

      def enumeration_label_by_index(field, index)
        enumeration_labels(field).to_a[index.to_i].last
      end
    end

    protected

    def set_enum_changed_at(field) # rubocop:disable Naming/AccessorMethodName
      return if changes[field].blank? || !attribute_names.include?("#{field}_changed_at")

      send("#{field}_changed_at=", Time.zone.now)
    end

    def set_enum_default(field, values)
      return if enumerate_fields[self.class.name.underscore][field][:set_default] == false

      return if send(field).present?

      send("#{field}=", values.to_a.first.first)
    end

    def enumerate_fields
      self.class.class_variable_get(:@@enumerate_fields)
    rescue NameError
      Rails.logger 'no enumerate fields'
      nil
    end

    def set_enum_fields
      return unless enumerate_fields

      defined_enums.each do |field, values|
        set_enum_default(field, values)

        set_enum_changed_at(field)
      end
    end
  end
end
