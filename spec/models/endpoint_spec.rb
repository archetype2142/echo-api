require 'rails_helper'

RSpec.describe Endpoint, type: :model do
  describe 'validations' do
    let(:endpoint) { build(:endpoint) }

    describe 'path validation' do
      it 'is valid with a properly formatted path' do
        valid_paths = [
          '/valid/path',
          '/path-with-hyphens',
          '/path_with_underscore',
          '/path/with/multiple/segments',
          '/123/numeric'
        ]

        valid_paths.each do |path|
          endpoint.path = path
          expect(endpoint).to be_valid
        end
      end

      it 'is invalid with improperly formatted paths' do
        invalid_paths = [
          'path-without-slash',
          '/path with spaces',
          '/path$special@chars',
          nil,
          ''
        ]

        invalid_paths.each do |path|
          endpoint.path = path
          expect(endpoint).not_to be_valid
          expect(endpoint.errors[:path]).to be_present
        end
      end
    end

    describe 'verb validation' do
      it 'is valid with proper HTTP methods' do
        %w[GET POST PUT PATCH DELETE].each do |method|
          endpoint.verb = method
          expect(endpoint).to be_valid
        end
      end

      it 'is invalid with improper HTTP methods' do
        [ 'INVALID', '', nil ].each do |method|
          endpoint.verb = method
          expect(endpoint).not_to be_valid
          expect(endpoint.errors[:verb]).to be_present
        end
      end
    end

    describe 'response validation' do
      it 'requires response_code' do
        endpoint.response_code = nil
        expect(endpoint).not_to be_valid
        expect(endpoint.errors[:response_code]).to be_present
      end

      it 'validates response_code range' do
        invalid_codes = [ 99, 600, 1000, -1 ]
        valid_codes = [ 100, 200, 404, 500, 599 ]

        invalid_codes.each do |code|
          endpoint.response_code = code
          expect(endpoint).not_to be_valid
          expect(endpoint.errors[:response_code]).to be_present
        end

        valid_codes.each do |code|
          endpoint.response_code = code
          expect(endpoint).to be_valid
        end
      end
    end

    describe 'uniqueness validation' do
      it 'enforces unique path and verb combination' do
        existing_endpoint = create(:endpoint, path: '/test', verb: 'GET')
        new_endpoint = build(:endpoint, path: '/test', verb: 'GET')

        expect(new_endpoint).not_to be_valid
        expect(new_endpoint.errors[:path]).to include('and verb combination must be unique')

        # Should be valid with different verb
        new_endpoint.verb = 'POST'
        expect(new_endpoint).to be_valid
      end
    end

    describe 'reserved paths validation' do
      it 'rejects reserved paths' do
        Endpoint::RESERVED_PATHS.each do |path|
          endpoint.path = path
          expect(endpoint).not_to be_valid
          expect(endpoint.errors[:path]).to include("cannot use reserved path #{path}")
        end
      end

      it 'allows paths that start with reserved paths' do
        endpoint.path = '/endpoints-test'
        expect(endpoint).to be_valid
      end
    end
  end

  describe '#response' do
    let(:endpoint) { build(:endpoint) }

    it 'returns a hash with code, headers, and body' do
      endpoint.response_code = 200
      endpoint.response_headers = { 'Content-Type' => 'application/json' }
      endpoint.response_body = { message: 'test' }.to_json

      expect(endpoint.response).to eq(
        code: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: { "message" => 'test' }
      )
    end

    it 'returns empty hash for headers when nil' do
      endpoint.response_headers = nil
      expect(endpoint.response[:headers]).to eq({})
    end
  end

  describe '#response=' do
    let(:endpoint) { build(:endpoint) }

    it 'sets response attributes from a hash with symbol keys' do
      endpoint.response = {
        code: 201,
        headers: { 'X-Custom' => 'value' },
        body: { status: 'created' }
      }

      expect(endpoint.response_code).to eq(201)
      expect(endpoint.response_headers).to eq({ 'X-Custom' => 'value' })
      expect(JSON.parse(endpoint.response_body)).to eq({ 'status' => 'created' })
    end

    it 'sets response attributes from a hash with string keys' do
      endpoint.response = {
        'code' => 404,
        'headers' => { 'X-Error' => 'true' },
        'body' => { 'error' => 'not found' }
      }

      expect(endpoint.response_code).to eq(404)
      expect(endpoint.response_headers).to eq({ 'X-Error' => 'true' })
      expect(JSON.parse(endpoint.response_body)).to eq({ 'error' => 'not found' })
    end

    it 'sets default empty hash for headers when nil' do
      endpoint.response = {
        code: 200,
        body: { message: 'test' }
      }
      expect(endpoint.response_headers).to eq({})
    end
  end
end
