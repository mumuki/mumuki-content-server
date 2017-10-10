get '/guides' do
  Bibliotheca::Collection::Guides.all.as_json
end

get '/guides/writable' do
  Bibliotheca::Collection::Guides.allowed(current_user.permissions).as_json
end

get '/guides/:id/raw' do
  Bibliotheca::Collection::Guides.find!(params['id']).raw
end

get '/guides/:id' do
  Bibliotheca::Collection::Guides.find!(params['id']).as_json
end

post '/guides/:guide_id/exercises/:exercise_id/test' do
  Bibliotheca::Collection::Languages.find_by!(name: json_body['language']).run_tests!(json_body['solution'])
end

delete '/guides/:id' do
  authorize! :editor
  Bibliotheca::Collection::Guides.delete!(params['id'])
  {}
end

get '/guides/:organization/:repository/raw' do
  Bibliotheca::Collection::Guides.find_by_slug!(slug.to_s).raw
end

get '/guides/:organization/:repository/markdown' do
  Bibliotheca::Collection::Guides.find_by_slug!(slug.to_s).markdownified.as_json
end

get '/guides/:organization/:repository' do
  Bibliotheca::Collection::Guides.find_by_slug!(slug.to_s).as_json
end

post '/guides' do
  upsert! Bibliotheca::Guide, Bibliotheca::Collection::Guides, Bibliotheca::IO::GuideExport
end

post '/guides/import/:organization/:repository' do
  Bibliotheca::IO::GuideImport.new(bot: bot, repo: slug).run!
  Mumukit::Nuntius.notify_content_change_event! Bibliotheca::Guide, slug
end

post '/upload' do
  body = OpenStruct.new json_body
  token = bot.token
  data = {
    path: "images/#{body.filename}",
    branch: 'master',
    message: 'Upload new image',
    content: body.content,
    commiter: {
      name: bot.name,
      email: bot.email
    }
  }

  body.filename = body.filename.gsub(/\.(.*){2,4}/) { |it| "_#{(Time.now.to_f * 1000).to_i}#{it}" }

  response = RestClient.put("https://api.github.com/repos/#{body.organization}/#{body.repository}/contents/images/#{body.filename}",
                            data.to_json,
                            {
                              accept: 'application/vnd.github.v3+json',
                              content_type: :json,
                              user_agent: headers['user_agent'],
                              authorization: "token #{token}"
                            }
  )
  JSON.parse(response)
end
