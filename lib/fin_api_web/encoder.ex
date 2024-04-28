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

Protocol.derive(Jason.Encoder, Kujira.Token, only: [:denom, :meta, :trace])

Protocol.derive(Jason.Encoder, Kujira.Token.Meta,
  only: [:name, :decimals, :symbol, :coingecko_id, :png, :svg]
)

Protocol.derive(Jason.Encoder, Kujira.Token.Trace, only: [:path, :base_denom])

Protocol.derive(Jason.Encoder, Kujira.Token.Meta.Error, only: [:message])

Protocol.derive(Jason.Encoder, Kujira.Fin.Book, only: [:asks, :bids])

Protocol.derive(Jason.Encoder, Kujira.Fin.Book.Price, only: [:price, :total, :side])
