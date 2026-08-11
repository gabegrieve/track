module ApplicationHelper
  def money(cents)
    number_to_currency(cents.to_i / 100.0, unit: "$", precision: 2)
  end

  def duration(minutes)
    return "—" if minutes.blank?

    "#{minutes / 60}h #{minutes % 60}m"
  end

  def status_label(status)
    status.to_s.humanize
  end

  def page_title(title)
    content_for(:title, "#{title} · Track")
  end

  def button_class(variant = :default)
    base = "inline-flex min-h-9 items-center justify-center rounded-md border px-3 text-sm font-medium transition focus:outline-none focus:ring-2 focus:ring-zinc-900 focus:ring-offset-2"
    case variant
    when :dark then "#{base} border-zinc-900 bg-zinc-900 text-white hover:bg-zinc-700"
    when :secondary then "#{base} border-zinc-200 bg-white text-zinc-600 hover:bg-zinc-100"
    else "#{base} border-zinc-200 bg-white text-zinc-900 hover:bg-zinc-100"
    end
  end

  def status_class(status)
    colors = {
      "uninvoiced" => "bg-zinc-100 text-zinc-600 before:bg-zinc-500",
      "draft" => "bg-zinc-100 text-zinc-600 before:bg-zinc-500",
      "pending" => "bg-amber-50 text-amber-800 before:bg-amber-500",
      "issued" => "bg-amber-50 text-amber-800 before:bg-amber-500",
      "paid" => "bg-green-50 text-green-800 before:bg-green-600",
      "active" => "bg-green-50 text-green-800 before:bg-green-600",
      "voided" => "bg-zinc-100 text-zinc-500 before:bg-zinc-400",
      "archived" => "bg-zinc-100 text-zinc-500 before:bg-zinc-400"
    }
    "inline-flex items-center gap-1.5 rounded-full px-2 py-1 text-xs font-medium before:size-1.5 before:rounded-full #{colors.fetch(status.to_s, colors["draft"])}"
  end
end
