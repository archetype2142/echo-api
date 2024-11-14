require 'rails_helper'

RSpec.describe "Mock Endpoints", type: :request do
  describe "Handling mock endpoints" do
    let!(:mock_endpoint) do
      Endpoint.create!(
        verb: "GET",
        path: "/test/mock",
        response: {
          code: 200,
          headers: { "X-Test" => "test-value" },
          body: { message: "Hello from mock!" }
        }
      )
    end

    context "when the endpoint exists" do
      it "returns the configured response" do
        get "/test/mock"
        expect(response).to have_http_status(200)
        expect(response.headers["X-Test"]).to eq("test-value")
        expect(JSON.parse(response.body)).to eq({ "message" => "Hello from mock!" })
      end

      it "handles custom response headers" do
        mock_endpoint.update!(
          response: {
            code: 201,
            headers: { "X-Custom-Header" => "custom-value" },
            body: { status: "created" }
          }
        )

        get "/test/mock"
        expect(response).to have_http_status(201)
        expect(response.headers["X-Custom-Header"]).to eq("custom-value")
        expect(JSON.parse(response.body)).to eq({ "status" => "created" })
      end
    end

    context "when the endpoint doesn't exist" do
      it "returns 404 for non-existent paths" do
        get "/non/existent/path"
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include("errors" => [ { "code"=>"not_found", "detail"=>"Requested page /non/existent/path does not exist" } ])
      end

      it "returns 404 for wrong HTTP method" do
        post "/test/mock"
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include("errors" => [ { "code"=>"not_found", "detail"=>"Requested page /test/mock does not exist" } ])
      end
    end

    context "with different HTTP methods" do
      let!(:post_endpoint) do
        Endpoint.create!(
          verb: "POST",
          path: "/test/post",
          response: {
            code: 201,
            headers: { "X-Test" => "test-value" },
            body: { status: "created" }
          }
        )
      end

      let!(:put_endpoint) do
        Endpoint.create!(
          verb: "PUT",
          path: "/test/put",
          response: {
            code: 200,
            headers: { "X-Test" => "test-value" },
            body: { status: "updated" }
          }
        )
      end

      it "handles POST requests" do
        post "/test/post"
        expect(response).to have_http_status(201)
        expect(JSON.parse(response.body)).to eq({ "status" => "created" })
      end

      it "handles PUT requests" do
        put "/test/put"
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to eq({ "status" => "updated" })
      end
    end

    context "with request bodies" do
      let!(:post_with_body) do
        Endpoint.create!(
          verb: "POST",
          path: "/test/with-body",
          response: {
            code: 201,
            headers: { "X-Test" => "test-value" },
            body: { received: true }
          }
        )
      end

      it "accepts requests with bodies" do
        post "/test/with-body", params: { data: "test" }.to_json
        expect(response).to have_http_status(201)
        expect(JSON.parse(response.body)).to eq({ "received" => true })
      end
    end
  end
end
