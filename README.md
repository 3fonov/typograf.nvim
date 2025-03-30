# typograf.nvim

🔠 Типограф Артемия Лебедева прямо в Neovim!

Выдели текст → нажми `<leader>t` → получи красивый, типографически выверенный текст.

## 🔧 Установка

### lazy.nvim

```lua
{
  "3fonov/typograf.nvim",
  config = function()
    vim.keymap.set("v", "<leader>t", function()
      require("typograf").typograf()
    end, { desc = "Типографировать текст" })
  end,
}
```

### packer.nvim

```lua
use {
  "3fonov/typograf.nvim",
  config = function()
    vim.keymap.set("v", "<leader>t", function()
      require("typograf").typograf()
    end, { desc = "Типографировать текст" })
  end,
}
```

## 📦 Зависимости

- [luasocket](https://github.com/diegonehab/luasocket)

```bash
luarocks install luasocket
```

## 📄 Лицензия

MIT

