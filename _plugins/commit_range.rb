# A plugin that will do a treeless clone of the branch of the specified repository and render the first and last commit dates for those.

module Jekyll
  class RenderTimeTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      parameters = text.split(" ")
      @repo = parameters[0]
      @branch = parameters[1]
    end

    def render(context)
      result = system("git clone --filter=tree:0 --no-checkout --single-branch --branch #{@branch} #{@repo} temp_clone/")

      # Detect if running on Windows, and run versions compatible with cmd.exe
      if RUBY_PLATFORM =~ /mingw|mswin/ then
        first_date = DateTime.parse(`cd temp_clone && git log --reverse --format="%ad" --date=short`.split("\n")[0])
        latest_date = DateTime.parse(`cd temp_clone && git log -1 --format="%ad" --date=short`)
        `rmdir /s /q temp_clone`
      else
        first_date = DateTime.parse(`cd temp_clone && git log --reverse --format="%ad" --date=short | head -n 1`)
        latest_date = DateTime.parse(`cd temp_clone && git log -1 --format="%ad" --date=short`)
        `rm -r temp-clone`
      end

      "#{first_date.strftime("%b %Y")} - #{latest_date.strftime("%b %Y")}"
    end
  end
end

Liquid::Template.register_tag('commit_range', Jekyll::RenderTimeTag)