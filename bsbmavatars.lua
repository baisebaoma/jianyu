local extension = Package:new("bsbmavatars")
extension.extensionName = "BsbmAvatars"

Fk:loadTranslationTable {
     ["bsbmavatars"] = "监狱专属头像",
     ["ba"] = "监狱专属头像",
}

local jianzihao = General(extension, "jianzihao", "shu", 1, 1, General.Male)
jianzihao.hidden = true
local houguoyu = General(extension, "houguoyu", "shu", 1, 1, General.Male)
houguoyu.hidden = true

Fk:loadTranslationTable {
     ["jianzihao"] = "简自豪",
     ["houguoyu"] = "侯国玉",
}

return extension