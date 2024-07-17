local handler = require("gx.handlers.tf")

describe("Terraform handler", function()
  it("should return correct URL for a module", function()
    vim.cmd("edit test/fixtures/test.tf")
    vim.api.nvim_win_set_cursor(0, { 16, 0 })
    local url = handler.handle()
    assert.equal("https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest", url)
  end)
  it("should return correct URL for a data source", function()
    vim.cmd("edit test/fixtures/test.tf")
    vim.api.nvim_win_set_cursor(0, { 11, 0 })
    local url = handler.handle()
    assert.equal("https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket", url)
  end)
  it("should return correct URL for a resource", function()
    vim.cmd("edit test/fixtures/test.tf")
    vim.api.nvim_win_set_cursor(0, { 4, 0 })
    local url = handler.handle()
    assert.equal(
      "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket",
      url
    )
  end)
end)
