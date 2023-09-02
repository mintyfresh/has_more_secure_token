# frozen_string_literal: true

require_relative 'has_more_secure_token/version'

require 'active_record'

module HasMoreSecureToken
  MINIMUM_TOKEN_LENGTH = ActiveRecord::SecureToken::MINIMUM_TOKEN_LENGTH

  module ClassMethods
    # @param attribute [Symbol]
    # @param length [Integer]
    # @param find_by_digest [String, nil]
    # @return [void]
    def has_secure_token(attribute = :token, length: MINIMUM_TOKEN_LENGTH, find_by_digest: nil) # rubocop:disable Naming/PredicateName
      finds_secure_token_by_digest(attribute, length: length, digest: find_by_digest) if find_by_digest

      super(attribute, length: length)
    end

    # @param attribute [Symbol]
    # @param length [Integer]
    # @param digest [String]
    # @return [void]
    def finds_secure_token_by_digest(attribute, length: MINIMUM_TOKEN_LENGTH, digest: 'sha256')
      # The digest must be a valid algorithm.
      openssl_digest = OpenSSL::Digest.new(digest)

      # An arel node that matches the format of the digest in the index.
      token_arel = arel_token_digest(attribute, digest)

      define_singleton_method(:"find_by_#{attribute}") do |token|
        # Short-circuit to avoid the database query if the token is obviously invalid.
        return if token.blank? || (token = token.to_s).length != length

        # A bound parameter that matches the format of the digest in the index.
        token_hash = bind_token_param(attribute.to_s, openssl_digest.digest(token))

        # Produces:
        #   digest("table_name"."attribute", 'SHA256') = $1
        find_by(token_arel.eq(token_hash))
      end

      define_singleton_method(:"find_by_#{attribute}!") do |token|
        send(:"find_by_#{attribute}", token) or raise_record_not_find_by_token!
      end
    end

  private

    # @param attribute [Symbol]
    # @param digest [String]
    # @return [Arel::Nodes::Node]
    def arel_token_digest(attribute, digest)
      Arel::Nodes::NamedFunction.new('digest', [arel_table[attribute], Arel::Nodes.build_quoted(digest)])
    end

    # @param attribute [String]
    # @param value [String]
    # @return [Arel::Nodes::BindParam]
    def bind_token_param(attribute, value)
      Arel::Nodes::BindParam.new(ActiveRecord::Relation::QueryAttribute.new(attribute, value, secure_token_type))
    end

    # @return [ActiveModel::Type::Value]
    def secure_token_type
      @secure_token_type ||= ActiveRecord::Type.lookup(:binary)
    end

    # @return [void]
    def raise_record_not_find_by_token!
      none.raise_record_not_found_exception!
    end
  end

  # @private
  def self.included(base)
    super(base)
    base.extend(ClassMethods)
  end
end
