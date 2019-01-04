# JekyllIncludeWithFrontmatterTag

Jekyll's `include` and `include_relative` tags are straight includes -- they don't deal with files that have frontmatter.

When working with a Jekyll site that uses Netlify CMS, though, one may want to be able to edit the includes via Netlify CMS. Netlify writes Markdown with frontmatter, though. The solution is to create a couple new tags, `includefm` and `includefm_relative`, which inherit from the Jekyll include tags, and add handling of frontmatter.

Frontmatter gets treated as params passed into the include. If there is an include param with the same key as a frontmatter param, the include param takes precedence. Thus, frontmatter params can be thought of as defaults param values for the include.

In all other ways, `includefm` and `includefm_relative` should work the same as `include` and `include_relative`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jekyll-include-with-frontmatter'
```

Also add a corresponding line to your Jekyll `config.yml`:

```yaml
plugins:
  - jekyll-include-with-frontmatter

```

## Usage

Files which are to be included can include frontmatter:

```yaml
---
title: Documents
---
<div id="documents-column">
  <div class="bg-blue">{{ include.title }}</div>
  <div class="bg-grey"><a href="/media/pdfs/doc1.pdf" target="_blank">Document 1</a></div>
  <div class="bg-grey"><a href="/media/pdfs/doc2.pdf" target="_blank">Document 2</a></div>
  <div class="bg-grey"><a href="/media/pdfs/doc3.pdf" target="_blank">Document 3</a></div>
</div>

```

In your post, page, or layout, you include with frontmatter like this:

```liquid
{% includefm documents.html %}
```

These tags should work just like the standard Jekyll include tags on files that do not include frontmatter, as well.

## TODO

There are, effectively, no tests. Tests are needed.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wyhaines/jekyll-include-with-frontmatter.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
