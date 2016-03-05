require 'spec_helper'

describe 'read-write' do
  let(:haskell) do
    {'test_framework' => {
        'name' => 'rspec',
        'version' => '2.13',
        'test_extension' => '.rb'
    }}
  end

  before do
    allow_any_instance_of(Mumukit::Bridge::Thesaurus).to receive(:language).
                                                             with('haskell').
                                                             and_return(haskell)
  end

  let(:repo) { Mumukit::Service::Slug.new('mumuki', 'functional-haskell-guide-1') }
  let(:export_log) { Bibliotheca::IO::Log.new }
  let(:import_log) { Bibliotheca::IO::Log.new }
  let(:guide) { Bibliotheca::Guide.new(
      description: 'Baz',
      slug: 'flbulgarelli/never-existent-repo',
      language: haskell.name,
      locale: 'en',
      id_format: '%05d',
      exercises: [
          {type: 'problem',
           name: 'Bar',
           description: 'a description',
           test: 'foo bar',
           default_content: '--type here',
           tag_list: %w(baz bar),
           layout: 'no_editor',
           id: 1},

          {type: 'problem',
           name: 'Foo',
           tag_list: %w(foo bar),
           id: 4},

          {name: 'Baz',
           tag_list: %w(baz bar),
           layout: 'editor_bottom',
           type: 'problem',
           id: 2}]) }

  let(:dir) { 'spec/data/import-export' }

  let(:imported_guide) do
    FileUtils.mkdir_p dir
    Bibliotheca::IO::GuideWriter.new(dir, export_log).write_guide! guide
    Bibliotheca::IO::GuideReader.new(dir, repo, import_log).read_guide!
  end

  after do
    FileUtils.rm_rf dir
  end

  it { expect(import_log.to_s).to eq '' }
  it { expect(export_log.to_s).to eq '' }

  it { expect(imported_guide.exercises.length).to eq 3 }
  it { expect(imported_guide.exercises.first.name).to eq 'Bar' }
  it { expect(imported_guide.exercises.second.name).to eq 'Foo' }
  it { expect(imported_guide.exercises.third.name).to eq 'Baz' }
  it { expect(imported_guide.exercises.first.default_content).to eq '--type here' }
  it { expect(imported_guide.exercises.first.layout).to eq 'no_editor' }
  it { expect(imported_guide.exercises.second.layout).to eq 'editor_right' }

  it { expect(imported_guide.language).to eq haskell }
  it { expect(imported_guide.locale).to eq 'en' }
  it { expect(imported_guide.description).to eq 'Baz' }


end
