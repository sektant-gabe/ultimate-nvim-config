-- ~/.config/nvim/lua/kickstart/plugins/dap_extra.lua

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'mfussenegger/nvim-dap',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
  },
  config = function()
    local dap = require 'dap'

    -- ========================
    -- C / C++ (codelldb)
    -- ========================
    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = vim.fn.stdpath 'data' .. '/mason/bin/codelldb',
        args = { '--port', '${port}' },
      },
    }
    dap.configurations.c = {
      {
        name = 'Launch C program',
        type = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }
    dap.configurations.cpp = dap.configurations.c

    -- ========================
    -- Rust (codelldb)
    -- ========================
    dap.configurations.rust = dap.configurations.c

    -- ========================
    -- Go (dlv)
    -- ========================
    dap.adapters.go = function(callback, _)
      local stdout = vim.loop.new_pipe(false)
      local handle
      local port = 38697
      handle = vim.loop.spawn('dlv', {
        stdio = { nil, stdout },
        args = { 'dap', '-l', '127.0.0.1:' .. port },
        detached = true,
      }, function(code)
        stdout:close()
        handle:close()
        print('Delve exited with exit code: ' .. code)
      end)
      vim.defer_fn(function()
        callback { type = 'server', host = '127.0.0.1', port = port }
      end, 100)
    end
    dap.configurations.go = {
      {
        type = 'go',
        name = 'Debug Go file',
        request = 'launch',
        program = '${file}',
      },
    }

    -- ========================
    -- Java (java-debug)
    -- ========================
    dap.adapters.java = function(callback, _)
      callback {
        type = 'server',
        host = '127.0.0.1',
        port = 5005,
      }
    end
    dap.configurations.java = {
      {
        type = 'java',
        name = 'Attach to Java process',
        request = 'attach',
        hostName = '127.0.0.1',
        port = 5005,
      },
    }

    -- ========================
    -- JavaScript & TypeScript (vscode-js-debug)
    -- ========================
    dap.adapters['pwa-node'] = {
      type = 'server',
      host = 'localhost',
      port = '${port}',
      executable = {
        command = 'node',
        args = { vim.fn.stdpath 'data' .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js', '${port}' },
      },
    }
    dap.configurations.javascript = {
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch JS file',
        program = '${file}',
        cwd = '${workspaceFolder}',
      },
    }
    dap.configurations.typescript = dap.configurations.javascript

    -- ========================
    -- R (vscDebugger)
    -- ========================
    dap.adapters.r = {
      type = 'executable',
      command = 'R',
      args = { '--slave', '-e', 'vscDebugger:::.vsc.launch()' },
    }
    dap.configurations.r = {
      {
        type = 'r',
        name = 'R Debugger',
        request = 'launch',
        program = '${file}',
      },
    }

    -- ========================
    -- SQL (no direct DAP — use terminal-based debug/logging)
    -- ========================
    -- SQL doesn't have a mainstream DAP adapter, so debugging is usually done
    -- via queries/logging, not breakpoints. Leaving this as a placeholder.
  end,
}
