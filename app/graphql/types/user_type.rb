Types::UserType = GraphQL::ObjectType.define do
  name 'User'
  field :id, !types.ID
  field :ext_id, !types.ID
  field :source, !types.String
  field :first_name, !types.String
  field :last_name, types.String
  field :username, types.String
  field :language, types.String
end
