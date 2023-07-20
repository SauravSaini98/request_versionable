require 'active_record' unless defined? ActiveRecord
require "request_store"

module RequestVersionable

  def self.included(klazz)
    klazz.extend ClassMethods
    # after_save_commit :save_associated_version_record
  end

  module ClassMethods
    private
    def save_version(name, scope = nil, **options, &extension)
      @version_association_name = name
      has_many name, scope, **options, &extension
    end
  end
end

ActiveSupport.on_load(:active_record) do
  class ActiveRecord::Base
    def self.save_record_histories(association_name, scope = nil, **options, &extension)
      if included_modules.include?(RequestVersionable)
        puts "[WARN] #{self.name} is calling save_record_histories more than once!"
        return
      end
      raise ArgumentError, "Required option association_name is missing" unless association_name.present?
      reject_keys = [:current_user_attribute]
      filtered_options = options.reject { |key, _| reject_keys.include?(key) }
      include RequestVersionable

      class_attribute :version_association_name
      class_attribute :current_user_attribute
      self.version_association_name = (association_name).to_s
      self.current_user_attribute = (options[:current_user_attribute] || :user_able).to_sym
      self.send(:save_version,association_name, scope, **filtered_options, &extension)
      after_save_commit :save_associated_version_record
    end

    private

    def save_associated_version_record
      return unless previous_changes.present?
      association = self.send(version_association_name)
      keys = (self.class.attribute_names - %w[id created_at updated_at]).map(&:to_sym)
      keys = keys & (association.klass.attribute_names - %w[id created_at updated_at]).map(&:to_sym)
      attributes = keys.map { |key| [key, self[key]] }.to_h
      attributes[current_user_attribute] = RequestStore.store[:user_able]

      # Use the options from version_options to create the associated record
      association.create(attributes)
    end

    def version_association_name
      self.class.version_association_name
    end

    def current_user_attribute
      self.class.current_user_attribute
    end
  end
end

module RequestVersionableControllerExtension
  extend ActiveSupport::Concern

  private

  def set_current_user_store!(model)
    record = self.send(model)
    RequestStore.store[:user_able] = record
  rescue
    nil
  end
end

# config/initializers/action_controller_extension.rb
ActiveSupport.on_load(:action_controller) do
  include RequestVersionableControllerExtension
end


require 'request_versionable/rspec' if defined? RSpec
