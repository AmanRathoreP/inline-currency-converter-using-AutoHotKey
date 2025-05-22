#Requires AutoHotkey v2.0

base_path := "C:\Users\Aman Rathore\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\AutoHotKey\"
user_name := "Aman Rathore"
copyright_name := "Aman Rathore"
contact_info := "amanr.me | amanrathore9753 <at> gmail <dot> com"
contact_info_unprotected := "amanr.me | amanrathore9753@gmail.com"
local_currency := "inr" ; Local currency code in lower case for example: "inr", "usd", "eur"
    
    
; Function to convert currency
paste(content, clipboard_delay) {
    backup := ClipboardAll()

    A_Clipboard := content
    ClipWait(clipboard_delay)
    Send("^v")
    Sleep(100)
    A_Clipboard := backup
    return
}