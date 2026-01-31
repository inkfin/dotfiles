return {
    {
        "JoosepAlviste/nvim-ts-context-commentstring",
        opts = {
            -- change the comment string here
            config = {
                c = "/* %s */",
                cpp = "// %s",
                -- shader stuff
                glsl = "// %s",
                vert = "// %s",
                tesc = "// %s",
                tese = "// %s",
                frag = "// %s",
                geom = "// %s",
                comp = "// %s",
                wgsl = "// %s",
                nu = "# %s",
            },
        },
    },
}
