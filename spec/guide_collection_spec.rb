require 'spec_helper'

describe GuideCollection do

  let(:id) { GuideCollection.insert({name: 'foo', language: 'haskell', exercises: []})[:id] }
  let(:inserted) { GuideCollection.find(id) }

  it { expect(id).to_not be nil }
  it { expect(inserted).to_not be nil }
  it { expect(inserted.raw).to_not be_empty }
  it { expect(inserted.id).to eq id }
  it { expect(inserted.name).to eq 'foo' }
  it { expect(inserted.exercises).to eq [] }

  it { expect(inserted.to_json).to eq %Q{{"beta":false,"learning":false,"original_id_format":"%05d","name":"foo","language":"haskell","exercises":[],"id":"#{id}"}} }

  it { expect(inserted.raw.to_json).to eq %Q{{"name":"foo","language":"haskell","exercises":[],"id":"#{id}"}} }

  describe '#update' do
    before { GuideCollection.update(id, {name: 'bar', language: 'haskell', exercises: [{name: 'e1'}]}) }
    let(:updated) { GuideCollection.find(id) }

    it { expect(updated.raw).to_not be_empty }
    it { expect(updated.exercises.count).to eq 1 }
    it { expect(updated.name).to eq 'bar' }
    it { expect(updated.name).to eq 'haskell' }
  end


  describe '#find_by_slug' do
    let(:id) { GuideCollection.insert({name: 'baz', githb_repository: 'foo/goo', language: 'haskell', exercises: []})[:id] }
    let(:guide) { GuideCollection.find_by_slug('foo', 'foo') }

    it { expect(guide.raw).to_not be_empty }
    it { expect(guide.exercises.count).to eq 1 }
    it { expect(guide.baz).to eq 'bar' }
  end
end