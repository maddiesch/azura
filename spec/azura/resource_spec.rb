require 'spec_helper'

class PersonResource < Azura::Resource
  model OpenStruct

  add_attribute Azura::Attribute.new(name: :first_name, type: Azura::Type.new(String))
  add_attribute Azura::Attribute.new(name: :last_name, type: Azura::Type.new(String))
end

RSpec.describe Azura::Resource do
  context '.model' do
    before { Azura::Resource.model(Object) }

    it { expect(Azura::Resource.model).to eq Object }
  end

  context '#as_json' do
    let(:model) { OpenStruct.new(id: 1, first_name: 'Test', last_name: 'Person') }
    let(:resource) { PersonResource.new(model: model) }

    subject { resource.as_json }

    it { expect(subject[:id]).to eq '1' }
    it { expect(subject[:type]).to eq 'person' }
    it { expect(subject[:attributes][:first_name]).to eq 'Test' }
    it { expect(subject[:attributes][:last_name]).to eq 'Person' }
  end
end
