NVNotify = {
    "rcarriga/nvim-notify",
    opts = {
        level = vim.log.levels.DEBUG,
        icons = {
            ERROR = NVIcons.error,
            WARN = NVIcons.warn,
            INFO = NVIcons.info,
            DEBUG = NVIcons.debug,
        },
    },
}

return { NVNotify }
