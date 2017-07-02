RootQuery = GraphQL::ObjectType.define do
  name 'RootQuery'
  description 'The query root of this schema'

  field :games do
    type !types[Types::GameType]
    argument :id, types.ID
    argument :creator, types.String
    description 'Find games'
    resolve ->(obj, args, ctx) {
      games = Game.order(created_at: :desc)
      games = games.where(id: args['id']) if args['id'].present?
      games = games.includes(:creator).where(users: { username: args['creator'] }) if args['creator'].present?

      games.limit(5)
    }
  end
end
