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

Protocol.derive(Jason.Encoder, Kujira.Fin.Book, only: [:asks, :bids])

Protocol.derive(Jason.Encoder, Kujira.Fin.Book.Price, only: [:price, :total, :side])
