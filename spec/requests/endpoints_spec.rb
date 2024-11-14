require "rails_helper"

RSpec.describe "Endpoints", type: :request do
  let(:headers) do
    {
      "Authorization" => "Bearer test-token",
      "Content-Type" => "application/vnd.api+json",
      "Accept" => "application/vnd.api+json"
    }
  end

  let(:valid_attributes) do
    {
      data: {
        type: "endpoints",
        attributes: {
          verb: "GET",
          path: "/test",
          response: {
            code: 200,
            headers: { "Content-Type" => "application/vnd.api+json" },
            body: { message: "Hello, World!" }
          }
        }
      }
    }
  end

  describe "GET /endpoints" do
    it "returns a list of endpoints" do
      endpoint = create(:endpoint)
      get endpoints_path, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response["data"]).to be_an(Array)
      expect(json_response["data"].first["type"]).to eq("endpoints")
      expect(json_response["data"].first["id"]).to eq(endpoint.id)
    end
  end

  describe "GET /endpoints/:id" do
    it "returns the requested endpoint" do
      endpoint = create(:endpoint)
      get endpoint_path(endpoint), headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response["data"]["type"]).to eq("endpoints")
      expect(json_response["data"]["id"]).to eq(endpoint.id)
    end

    it "returns not found for non-existent endpoint" do
      get endpoint_path("non-existent"), headers: headers

      expect(response).to have_http_status(:not_found)
      expect(json_response["errors"]).to be_present
      expect(json_response["errors"].first["code"]).to eq("not_found")
    end
  end

  describe "POST /endpoints" do
    it "creates a new endpoint" do
      puts "\nPOST Request:"
      puts "Headers: #{headers.inspect}"
      puts "Params: #{valid_attributes.to_json}"

      expect {
        post endpoints_path, params: valid_attributes.to_json, headers: headers
      }.to change(Endpoint, :count).by(1)

      puts "Response: #{response.body}"
      puts "Status: #{response.status}"
      expect(response).to have_http_status(:created)
      expect(response.headers["Location"]).to be_present
      expect(json_response["data"]["type"]).to eq("endpoints")
      expect(json_response["data"]["attributes"]["path"]).to eq("/test")
    end

    it "returns validation errors for invalid data" do
      post endpoints_path,
           params: { data: { type: "endpoints", attributes: { verb: "INVALID" } } }.to_json,
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["errors"]).to be_present
      expect(json_response["errors"].first["code"]).to eq("validation_error")
    end

    it "returns error for wrong content type" do
      headers["Content-Type"] = "application/json"
      post endpoints_path, params: valid_attributes.to_json, headers: headers

      expect(response).to have_http_status(:unsupported_media_type)
      expect(json_response["errors"].first["code"]).to eq("unsupported_media_type")
    end
  end

  describe "PATCH /endpoints/:id" do
    let(:endpoint) { create(:endpoint) }

    it "updates the endpoint" do
      update_params = {
        data: {
          type: "endpoints",
          id: endpoint.id,
          attributes: {
            response: {
              code: 200,
              headers: { "Content-Type" => "application/vnd.api+json" },
              body: { status: "updated" }
            }
          }
        }
      }

      puts "\nPATCH Request:"
      puts "Headers: #{headers.inspect}"
      puts "Params: #{update_params.to_json}"

      patch endpoint_path(endpoint),
            params: update_params.to_json,
            headers: headers

      puts "Response: #{response.body}"
      puts "Status: #{response.status}"
      expect(response).to have_http_status(:ok)
      expect(json_response["data"]["attributes"]["response"]["code"]).to eq(200)
      expect(json_response["data"]["attributes"]["response"]["body"]).to eq("status" => "updated")
    end

    it "returns validation errors for invalid data" do
      patch endpoint_path(endpoint),
            params: { data: { type: "endpoints", attributes: { verb: "INVALID" } } }.to_json,
            headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["errors"]).to be_present
      expect(json_response["errors"].first["code"]).to eq("validation_error")
    end

    it "returns error for wrong content type" do
      headers["Content-Type"] = "application/json"
      patch endpoint_path(endpoint), params: valid_attributes.to_json, headers: headers

      expect(response).to have_http_status(:unsupported_media_type)
      expect(json_response["errors"].first["code"]).to eq("unsupported_media_type")
    end
  end

  describe "DELETE /endpoints/:id" do
    it "deletes the endpoint" do
      endpoint = create(:endpoint)

      expect {
        delete endpoint_path(endpoint), headers: headers
      }.to change(Endpoint, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns not found for non-existent endpoint" do
      delete endpoint_path("non-existent"), headers: headers

      expect(response).to have_http_status(:not_found)
      expect(json_response["errors"]).to be_present
      expect(json_response["errors"].first["code"]).to eq("not_found")
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
