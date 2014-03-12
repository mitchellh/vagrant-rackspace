require 'spec_helper'
require "vagrant-rackspace/action/list_flavors"

describe VagrantPlugins::Rackspace::Action::ListFlavors do
  let(:app) { lambda { |env| } }
  let(:ui) { Vagrant::UI::Silent.new }
  let(:flavors) {
    Fog.mock!
    Fog::Compute.new({
      :provider => :rackspace,
      :rackspace_region => :dfw,
      :rackspace_api_key => 'anything',
      :rackspace_username => 'anything',
    }).flavors
  }
  let(:compute_connection) { double('fog connection') }
  let(:env) do
    {
      :rackspace_compute => compute_connection,
      :ui => ui
    }
  end

  subject(:action) { described_class.new(app, env) }

  before do
    allow(compute_connection).to receive(:flavors).and_return flavors
  end

  it 'get flavors from Fog' do
    expect(compute_connection).to receive(:flavors).and_return flavors
    action.call(env)
  end

  it 'writes a sorted, formatted flavor table to Vagrant::UI' do
    header_line = '%-36s %s' % ['Flavor ID', 'Flavor Name']
    expect(ui).to receive(:info).with(header_line)
    flavors.sort_by(&:id).each do |flavor|
      formatted_line = '%-36s %s' % [flavor.id, flavor.name]
      expect(ui).to receive(:info).with formatted_line
    end
    action.call(env)
  end

  it 'continues the middleware chain' do
    expect(app).to receive(:call).with(env)
    action.call(env)
  end
end
