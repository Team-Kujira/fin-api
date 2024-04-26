defmodule FinApi.Node do
  use Kujira.Node,
    otp_app: :fin_api,
    pubsub: FinApi.PubSub,
    subscriptions: ["instantiate.code_id EXISTS"]
end
