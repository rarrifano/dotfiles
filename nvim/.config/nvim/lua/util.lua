-- util

local M = {}

function M.gh(repo)
  return "https://github.com/" .. repo
end

function M.spec(repo, version)
  return { src = M.gh(repo), version = version }
end

return M
