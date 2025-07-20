NVTinyCodeAction = {
    "rachartier/tiny-code-action.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    event = "LspAttach",
    opts = {
        picker = {
            "snacks",
            opts = {
                layout = NVSPickerVerticalLayout.build(),
            },
        },
    },
}

function NVTinyCodeAction.show()
    require("tiny-code-action").code_action({})
end

return { NVTinyCodeAction }
