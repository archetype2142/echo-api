FactoryBot.define do
  factory :endpoint do
    sequence(:path) { |n| "/test#{n}" }
    verb { "GET" }
    response {
      {
        code: 200,
        body: { message: "test response" },
        headers: { "Content-Type" => "application/vnd.api+json" }
      }
    }
  end
end
