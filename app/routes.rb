require 'mumukit/content_type'
require 'mumukit/service/routes'
require 'mumukit/service/routes/auth'

require_relative '../lib/bibliotheca'

configure do
  set :app_name, 'bibliotheca'
end


class Mumukit::Auth::Token
  def email
    jwt['email']
  end
end

helpers do
  def bot
    Bibliotheca::Bot.from_env
  end

  def subject
    Bibliotheca::Collection::Guides.find(params[:id])
  end

  def route_slug_parts
    [params[:organization], params[:repository]].compact
  end

  def upsert!(document_class, collection_class, export_classes=[])
    protect! :writer
    document = document_class.new(json_body)
    exporting export_classes, document: document, bot: bot, author_email: token.email do
      collection_class.upsert_by_slug(slug.to_s, document)
    end
  end

  def exporting(export_classes, options={}, &block)
    block.call.tap do
      export_classes.each do |export_class|
        export_class.new(options.merge(slug: slug)).run!
      end
    end
  end
end

error Bibliotheca::Collection::ExerciseNotFoundError do
  halt 404
end

error Bibliotheca::IO::OrganizationNotFoundError do
  halt 404
end

post '/markdown' do
  { markdown: Mumukit::ContentType::Markdown.to_html(json_body['markdown']) }
end

require_relative './routes/languages'
require_relative './routes/guides'
require_relative './routes/books'
require_relative './routes/topics'
