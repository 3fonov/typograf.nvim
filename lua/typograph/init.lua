local M = {}

local function get_visual_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  if #lines == 0 then return "" end

  lines[1] = string.sub(lines[1], start_pos[3], -1)
  if #lines > 1 then
    lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  end

  return table.concat(lines, "\n"), start_pos, end_pos
end

local function set_visual_selection(text, start_pos, end_pos)
  local lines = vim.split(text, "\n")
  vim.api.nvim_buf_set_lines(0, start_pos[2]-1, end_pos[2], false, lines)
end

local function escape_xml(str)
  return str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

local function unescape_xml(str)
  return str:gsub("&amp;", "&"):gsub("&lt;", "<"):gsub("&gt;", ">")
end

local function build_soap_body(text)
  text = escape_xml(text)
  return table.concat({
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"',
    'xmlns:xsd="http://www.w3.org/2001/XMLSchema"',
    'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">',
    '<soap:Body>',
    '<ProcessText xmlns="http://typograf.artlebedev.ru/webservices/">',
    '<text>' .. text .. '</text>',
    '<entityType>1</entityType>',
    '<useBr>0</useBr>',
    '<useP>1</useP>',
    '<maxNobr>3</maxNobr>',
    '</ProcessText>',
    '</soap:Body>',
    '</soap:Envelope>'
  }, "\n")
end

local function send_soap_request(text)
  local socket = require("socket")
  local host = "typograf.artlebedev.ru"
  local port = 80

  local body = build_soap_body(text)
  local request = table.concat({
    "POST /webservices/typograf.asmx HTTP/1.1",
    "Host: " .. host,
    "Content-Type: text/xml",
    "Content-Length: " .. tostring(#body),
    'SOAPAction: "http://typograf.artlebedev.ru/webservices/ProcessText"',
    "",
    body
  }, "\r\n")

  local client = assert(socket.tcp())
  assert(client:connect(host, port))
  client:send(request)

  local response = {}
  while true do
    local chunk, err = client:receive("*l")
    if not chunk then break end
    table.insert(response, chunk)
  end

  client:close()
  local full = table.concat(response, "\n")
  local result = full:match("<ProcessTextResult>(.-)</ProcessTextResult>")
  if result then
    return unescape_xml(result)
  else
    return nil, "Не удалось извлечь результат"
  end
end

function M.typograf()
  local text, start_pos, end_pos = get_visual_selection()
  if not text or text == "" then
    print("Нет текста для типографа")
    return
  end

  local ok, result_or_err = pcall(send_soap_request, text)
  if not ok then
    print("Ошибка отправки запроса: " .. result_or_err)
    return
  end

  local result = result_or_err
  if not result then
    print("Не удалось получить отформатированный текст")
    return
  end

  set_visual_selection(result, start_pos, end_pos)
  print("✓ Текст оттипографирован!")
end

return M
