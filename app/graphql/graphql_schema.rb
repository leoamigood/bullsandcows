GraphqlSchema = GraphQL::Schema.define do
  query RootQuery
  max_depth 5
end
