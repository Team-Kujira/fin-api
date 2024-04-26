require Protocol

Protocol.derive(Jason.Encoder, Kujira.Fin.Pair,
  only: [
    :address,
    :owner,
    :token_base,
    :token_quote,
    :price_precision,
    :decimal_delta,
    :is_bootstrapping,
    :fee_taker,
    :fee_maker,
    :book
  ]
)

Protocol.derive(Jason.Encoder, Kujira.Token, only: [:decimals, :denom])
