# frozen_string_literal: true

Jekyll::Hooks.register [:posts, :pages, :documents], :pre_render do |doc|
  next if doc.data["mermaid"]

  doc.data["mermaid"] = true if doc.content.match?(/```\s*mermaid\b/)
end
