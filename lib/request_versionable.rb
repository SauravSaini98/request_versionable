require 'active_record' unless defined? ActiveRecord
require "request_store"

module RequestVersionable

  def self.included(klazz)
    klazz.extend ClassMethods
    after_save_commit :save_associated_version_record
  end

  module ClassMethods
    def save_version(name, scope = nil, **options, &extension)
      @version_association_name = name
      has_many name, scope, **options, &extension
    end
  end
end

ActiveSupport.on_load(:active_record) do
  class ActiveRecord::Base
    def self.save_as_versions(association_name, scope = nil, **options, &extension)
      if included_modules.include?(RequestVersionable)
        puts "[WARN] #{self.name} is calling save_as_versions more than once!"
        return
      end

      raise ArgumentError, "Required option association_name is missing" unless association_name.present?

      include RequestVersionable
      save_version(association_name, scope, **options, &extension)
      class_attribute :version_association_name
      self.version_association_name = (association_name).to_s
    end

    private

    def save_associated_version_record
      return unless previous_changes.present?

      keys = (self.class.attribute_names - %w[id created_at updated_at]).map(&:to_sym)
      attributes = keys.map { |key| [key, self[key]] }.to_h
      attributes[:user_able] = RequestStore.store[:user_able]

      # Use the options from version_options to create the associated record
      association = self.send(version_association_name)
      association.create(attributes)
    end

    def version_association_name
      self.class.version_association_name
    end
  end
end

require 'request_versionable/rspec' if defined? RSpec
