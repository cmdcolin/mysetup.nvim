# mysetup.nvim

cmdcolin's setup for nvim

based on kickstart.nvim

I didn't make it a proper github fork because the github UI for forks is weird

rest of dotfiles here https://github.com/cmdcolin/dotfiles

## LaTeX

Open a `.tex` file. The PDF opens in Papers and stays current. That's it —
there is nothing to press.

Under the hood it runs `latexmk -pvc`, which watches the file on disk, so
edits from Claude or any other tool rebuild the PDF too, not just `:w` here.

If something won't compile the PDF stops updating and the error list opens;
`\le` reopens it, `\ll` stops/restarts the compiler. `./install-lsp.sh`
pulls in latexmk, chktex, biber, texlab and tex-fmt.

Papers 50.x dropped SyncTeX upstream, so there is no jump-to-cursor between
source and PDF. Installing `zathura` and setting `vimtex_view_method` to
`'zathura'` would restore it.
