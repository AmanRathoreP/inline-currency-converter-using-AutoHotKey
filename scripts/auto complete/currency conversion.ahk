#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "..\..\global.ahk"
#Include "..\..\scripts\lib\_JXON.ahk"

json_text := FileRead("..\..\data\exchange_rates.json")

exchange_rates := Jxon_Load(&json_text)

convert_currencies(amount, from_currency, to_currency) {
    global exchange_rates

    from_currency := StrLower(from_currency)
    to_currency := StrLower(to_currency)

    from_value := exchange_rates[from_currency]["value"]
    to_value := exchange_rates[to_currency]["value"]

    converted_amount := (amount * to_value) / from_value

    from_unit := exchange_rates[from_currency]["unit"]
    to_unit := exchange_rates[to_currency]["unit"]

    amount_str := amount = Floor(amount) ? Format("{1}", amount) : Format("{1:.2f}", amount)
    converted_str := converted_amount = Floor(converted_amount) ? Format("{1}", converted_amount) : Format("{1:.2f}",
        converted_amount)

    result := Format("{1}{2} i.e. {3}{4}",
        from_unit, amount_str,
        to_unit, converted_str)

    return result
}

detect_and_convert(str) {
    global exchange_rates
    debug_currencies := ""
    for key in exchange_rates.OwnProps()
        debug_currencies .= key . ", "

    try {
        if (RegExMatch(str, "^(\d+\.?\d*)([a-zA-Z]+)to([a-zA-Z]+)$", &match)) {
            number := match[1]
            from_currency := StrLower(match[2])
            to_currency := StrLower(match[3])

            try {
                exchange_rates[from_currency]
                exchange_rates[to_currency]
                result := convert_currencies(number, from_currency, to_currency)
                return result
            }
        }
        ; Check for pattern with no target currency (10usdto) - use INR as default
        else if (RegExMatch(str, "^(\d+\.?\d*)([a-zA-Z]+)$", &match)) {
            number := match[1]
            from_currency := StrLower(match[2])
            to_currency := local_currency

            try {
                exchange_rates[from_currency]
                exchange_rates[to_currency]
                result := convert_currencies(number, from_currency, to_currency)
                return result
            }
        } else {
            return "str"
        }
    }

}
::ccc::
{
    template := Format("
(
{1}
)",
        convert_currencies(11.1, "usd", "inr"))
    currencies := []
    for currency, _ in exchange_rates
        currencies.Push(currency)

    ; Join with commas for display
    currencyList := ""
    for i, currency in currencies
        currencyList .= currency . (i < currencies.Length ? ", " : "")

    ; Display the list (for testing)
    paste(currencyList, 1)

    return
}


; Hotkey to convert selected currency text with Win+c
#o:: convert_selection()

; Function to handle the selected text conversion
convert_selection() {
    ; Save current clipboard content
    ClipSaved := ClipboardAll()

    ; Clear the clipboard and copy selected text
    A_Clipboard := ""
    Send "^c"
    if !ClipWait(0.5)
        return  ; No text was selected

    ; Get the selected text
    selectedText := A_Clipboard

    ; Process the conversion
    result := detect_and_convert(selectedText)

    ; Only replace text if conversion was successful
    if (result != "str") {
        ; Replace the selected text with conversion result
        A_Clipboard := result
        Send "^v"
    }

    ; Restore original clipboard after a short delay
    Sleep(100)
    A_Clipboard := ClipSaved

    return
}
