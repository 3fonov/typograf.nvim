# typograf.nvim

🔠 Типограф Артемия Лебедева прямо в Neovim!

Выдели текст → нажми `<leader>t` → получи красивый, типографически выверенный текст.

## 🔧 Установка

### lazy.nvim

```lua
return {
	"3fonov/typograf.nvim",
	config = function()
		vim.keymap.set("v", "<leader>ty", ":<C-u>lua require('typograf').typograf()<CR>", { desc = "Типографировать текст" })
	end
}
```


## 📦 Зависимости

- [luasocket](https://github.com/diegonehab/luasocket)

```bash
luarocks install luasocket
```

## 📄 Лицензия

MIT

