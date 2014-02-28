require 'spec_helper'
require "vagrant-rackspace/action/list_images"

describe VagrantPlugins::Rackspace::Action::ListImages do
  let(:app) { lambda { |env| } }
  let(:ui) { Vagrant::UI::Silent.new }
  let(:images) {
    Fog.mock!
    Fog::Compute.new({
      :provider => :rackspace,
      :rackspace_region => :dfw,
      :rackspace_api_key => 'anything',
      :rackspace_username => 'anything',
    }).images
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
    allow(compute_connection).to receive(:images).and_return images
  end

  it 'get images from Fog' do
    expect(compute_connection).to receive(:images).and_return images
    action.call(env)
  end

  it 'writes a sorted, formatted image table to Vagrant::UI' do
    header_line = '%-36s %s' % ['Image ID', 'Image Name']
    expect(ui).to receive(:info).with(header_line)
    images.sort_by(&:name).each do |image|
      formatted_line = '%-36s %s' % [image.id.to_s, image.name]
      expect(ui).to receive(:info).with formatted_line
    end
    action.call(env)
  end

  it 'continues the middleware chain' do
    expect(app).to receive(:call).with(env)
    action.call(env)
  end
end
