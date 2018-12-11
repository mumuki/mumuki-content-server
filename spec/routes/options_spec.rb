require 'spec_helper'

describe 'routes' do
  def app
    Mumuki::Bibliotheca::App
  end

  describe 'options /' do
    before do
      options '/'
    end
    it { expect(last_response.headers['Allow']).to include 'DELETE' }
  end
end
