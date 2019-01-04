# frozen_string_literal: true

require 'jekyll_include_with_frontmatter/version'
require 'jekyll'
require 'jekyll/tags/include'
require 'yaml'

# Implement includes that can handle frontmatter.
class JekyllIncludeWithFrontmatter < Jekyll::Tags::IncludeTag
  def render(context)
    site = context.registers[:site]

    file = render_variable(context) || @file
    validate_file_name(file)

    path = locate_include_file(context, file, site.safe)
    return unless path

    add_include_to_dependency(site, path, context)

    partial, include_params = load_cached_partial(path, context)

    context.stack do
      parsed_params = @params ? parse_params(context) : nil

      context['include'] = parsed_params ? include_params.merge(parsed_params) : include_params
      begin
        partial.render!(context)
      rescue Liquid::Error => e
        e.template_name = path
        e.markup_context = 'included ' if e.markup_context.nil?
        raise e
      end
    end
  end

  def load_cached_partial(path, context)
    context.registers[:cached_partials] ||= {}
    cached_partial = context.registers[:cached_partials]

    unless cached_partial.key?(path)
      unparsed_file = context.registers[:site]
                             .liquid_renderer
                             .file(path)
      begin
        file_data = read_file(path, context)
        if (matchdata = file_data.match(/(---\n.*---\n)(.*)/m))
          params = YAML.safe_load(matchdata[0])
          cached_partial[path] = [unparsed_file.parse(matchdata[1]), params]
        else
          cached_partial[path] = [unparsed_file.parse(file_data), {}]
        end
      rescue Liquid::Error => e
        e.template_name = path
        e.markup_context = 'included ' if e.markup_context.nil?
        raise e
      end
    end

    cached_partial[path]
  end
end

# Include relative to the source file. Blatantly stolen from Jekyll itself.
class JekyllIncludeRelativeWithFrontmatter < JekyllIncludeWithFrontmatter
  def tag_includes_dirs(context)
    Array(page_path(context)).freeze
  end

  def page_path(context)
    if context.registers[:page].nil?
      context.registers[:site].source
    else
      site = context.registers[:site]
      page_payload  = context.registers[:page]
      resource_path = \
        if page_payload['collection'].nil?
          page_payload['path']
        else
          File.join(site.config['collections_dir'], page_payload['path'])
        end
      site.in_source_dir File.dirname(resource_path)
    end
  end
end

Liquid::Template.register_tag('includefm', JekyllIncludeWithFrontmatter)
Liquid::Template.register_tag('includefm_relative', JekyllIncludeRelativeWithFrontmatter)
