local Translations = {
    info = {
        ["pick_coca_leaves"] = "Appuyez <b style=\"color: limegreen;\">[E]</b> pour ramasser feuilles de Coca",
        ["process_coca"] = "Appuyez <b style=\"color: limegreen;\">[E]</b> pour traiter Coca",
        ["press_sell_cocaine"] = "~b~[E]~w~ vendre Cocaine",
    },
    error = {
        ["not_enough_coca_leaves"] = "Vous n'avez pas assez de feuilles de Coca",
        ["has_no_cocaine"] = "Vous n'avez pas de Cocaine sur vous",
        ["not_enough_cocaine"] = "Vous n'avez pas assez de Cocaine sur vous",
    },
    success = {
        ["sold_amount"] = "Vous avez vendu %{amount} pochons de Cocaine pour: %{reward}€"
    }
}

if GetConvar("qb_locale", "en") == "fr" then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end