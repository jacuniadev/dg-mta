local settings = {
    ["mysql"] = {
        enabled = true,
        config = {
            host = "localhost",
            port = 3306,
            username = "root",
            database = "database",
            password = ""
        }
    }
}

function get(setting)
    return (settings[setting] and settings[setting].enabled) and settings[setting].config or false
end