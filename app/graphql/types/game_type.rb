Types::GameType = GraphQL::ObjectType.define do
  name 'Game'
  description 'Bulls & Cows game'
  field :id, !types.ID
  field :secret, !types.String
  field :channel, !types.String
  field :creator, !Types::UserType
  field :winner, Types::UserType
end
