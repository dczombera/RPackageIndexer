class PackagesController < ApplicationController
  def index
    @packages = Package.all.includes(:authors, :maintainers)
  end
end
