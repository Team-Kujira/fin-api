defmodule FinApi.Node do
  use Kujira.Node,
    otp_app: :fin_api,
    pubsub: FinApi.PubSub,
    subscriptions: ["wasm-trade._contract_address EXISTS"]
end
