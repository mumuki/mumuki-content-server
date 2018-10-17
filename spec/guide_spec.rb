require 'spec_helper'

describe Bibliotheca::Guide do
  let(:bot) { Bibliotheca::Bot.from_env }

  let!(:haskell) { create(:haskell) }

  let(:json) {
    {name: 'my guide',
     description: 'Baz',
     slug: 'flbulgarelli/never-existent-repo',
     language: 'haskell',
     locale: 'en',
     exercises: [
       {name: 'Bar',
        description: 'a description',
        test: 'foo bar',
        layout: 'input_bottom',
        id: 1},

       {type: 'problem',
        name: 'Foo',
        tag_list: %w(foo bar),
        id: 4},

       {type: 'playground',
        name: 'Baz',
        tag_list: %w(baz bar),
        layout: 'input_bottom',
        id: 2}]} }


  context 'stringified keys' do
    let(:stringified) { json.stringify_keys }
    let(:guide) { Bibliotheca::Guide.new stringified }

    it { expect(guide.name).to eq 'my guide' }
    it { expect(guide.exercises.first.name).to eq 'Bar' }
    it { expect(guide.exercises.first.type).to eq 'problem' }
  end

  context 'symbolized keys' do
    let(:guide) { Bibliotheca::Guide.new json }

    it { expect(guide.name).to eq 'my guide' }
    it { expect(guide.exercises.first.name).to eq 'Bar' }
    it { expect(guide.exercises.first.type).to eq 'problem' }
    it { expect(guide.exercises.second.type).to eq 'problem' }
    it { expect(guide.exercises.third.type).to eq 'playground' }
    it { expect(guide.exercises.first.tag_list).to eq [] }
    it { expect(guide.id_format).to eq '%05d' }
    it { expect(guide.expectations).to eq [] }

    describe 'as_json' do
      let(:exported) { guide.as_json }

      it { expect(exported['name']).to eq 'my guide' }
      it { expect(exported['beta']).to eq false }
      it { expect(exported['exercises'][0]['type']).to eq 'problem' }
    end
  end

  describe 'validations' do
    context 'no name' do
      let(:guide) { build(:guide, name: nil) }

      it { expect(guide.errors).to include 'Name must be present' }
      it { expect(guide.errors.size).to eq 1 }
    end

    context 'bad type' do
      let(:guide) { build(:guide, type: 'fdfd') }

      it { expect(guide.errors).to include 'Unrecognized guide type fdfd' }
      it { expect(guide.errors.size).to eq 1 }

    end

    context 'bad beta' do
      let(:guide) { build(:guide, beta: 'true') }

      it { expect(guide.errors).to include 'Beta flag must be boolean' }
      it { expect(guide.errors.size).to eq 1 }
    end

    context 'no language' do
      let(:guide) { build(:guide, language: nil) }

      it { expect(guide.errors).to include 'Language must be present' }
      it { expect(guide.errors.size).to eq 1 }
    end
  end

  describe 'markdownified' do
    context 'description' do
      let(:guide) { build(:guide, description: '`foo = (+)`') }
      it { expect(guide.markdownified.description).to eq("<p><code>foo = (+)</code></p>\n") }
    end
    context 'corollary' do
      let(:guide) { build(:guide, corollary: '[Google](https://google.com)') }
      it { expect(guide.markdownified.corollary).to eq("<p><a title=\"\" href=\"https://google.com\" target=\"_blank\">Google</a></p>\n") }
    end
    context 'teacher_info' do
      let(:guide) { build(:guide, teacher_info: '**foo**') }
      it { expect(guide.markdownified.teacher_info).to eq("<p><strong>foo</strong></p>\n") }
    end
    context 'exercises' do
      let(:guide) { build(:guide, exercises: [{description: '**foo**'}]) }
      it { expect(guide.markdownified.exercises.first.description).to eq("<p><strong>foo</strong></p>\n") }
    end
  end

  describe 'fork' do

    let(:guide_from) { build :guide, slug: 'foo/bar' }
    let(:slug_from) { guide_from.slug }
    let(:slug_to) { 'baz/bar'.to_mumukit_slug }
    let(:guide_to) { Bibliotheca::Collection::Guides.find_by_slug! slug_to.to_s }

    before { Bibliotheca::Collection::Guides.insert! guide_from }
    before { Bibliotheca::Collection::Guides.insert! build(:guide, slug: 'test/bar') }

    context 'fork works' do
      before { expect_any_instance_of(Bibliotheca::Bot).to receive(:fork!).with(slug_from, slug_to.organization) }
      before { Bibliotheca::Collection::Guides.find_by_slug!(slug_from).fork_to! 'baz', bot }
      it { expect(guide_from.as_json).to json_like guide_to.as_json, {except: [:slug, :id]} }
    end

    context 'fork does not work if guide already exists' do
      before { expect_any_instance_of(Bibliotheca::Bot).to_not receive(:fork!).with(slug_from, 'test') }
      it { expect { Bibliotheca::Collection::Guides.find_by_slug!(slug_from).fork_to! 'test', bot }.to raise_error Bibliotheca::Collection::GuideAlreadyExists }
    end

  end

end
