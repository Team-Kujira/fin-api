defmodule FinApi.Node do
  use Kujira.Node,
    otp_app: :fin_api,
    pubsub: FinApi.PubSub,
    subscriptions: ["message.action='/cosmwasm.wasm.v1.MsgExecuteContract'"]
end
