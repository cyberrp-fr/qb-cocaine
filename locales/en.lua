local Translations = {
    info = {
        ["pick_coca_leaves"] = "Press <b style=\"color: limegreen;\">[E]</b> to pick Coca leaves",
        ["process_coca"] = "Press <b style=\"color: limegreen;\">[E]</b> to process your Coca leaves",
        ["press_sell_cocaine"] = "Press ~b~[E]~w~ to sell Cocaine",
    },
    error = {
        ["not_enough_coca_leaves"] = "You don't have enough Coca leaves",
        ["has_no_cocaine"] = "You don't have any Cocaine on you",
        ["not_enough_cocaine"] = "You don't have enough Cocaine on you",
    },
    success = {
        ["sold_amount"] = "You've sold %{amount}x Cocaine bags for: $%{reward}",
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
