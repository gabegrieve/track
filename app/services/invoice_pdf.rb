class InvoicePdf
  def initialize(invoice)
    @invoice = invoice
  end

  def render
    Prawn::Document.new(page_size: "A4", margin: 48) do |pdf|
      pdf.font_size 24
      pdf.text "INVOICE", style: :bold
      pdf.move_down 8
      pdf.font_size 10
      pdf.text @invoice.number
      pdf.text "Issued #{format_date(@invoice.issued_at)}"
      pdf.text "Due #{format_date(@invoice.due_on)}"
      pdf.move_down 28

      pdf.bounding_box([0, pdf.cursor], width: 230) do
        pdf.text "FROM", style: :bold, size: 8
        pdf.move_down 4
        pdf.text @invoice.sender_name.to_s, style: :bold
        pdf.text @invoice.sender_address.to_s
        pdf.text "ABN #{@invoice.sender_abn}" if @invoice.sender_abn.present?
        pdf.text @invoice.sender_email.to_s
      end
      pdf.bounding_box([270, pdf.cursor + 58], width: 230) do
        pdf.text "BILL TO", style: :bold, size: 8
        pdf.move_down 4
        pdf.text @invoice.client_name.to_s, style: :bold
        pdf.text @invoice.client_address.to_s
      end
      pdf.move_down 36

      pdf.font_size 8
      pdf.text "DATE                                      DESCRIPTION                                  TIME            RATE         AMOUNT", style: :bold
      pdf.stroke_horizontal_rule
      pdf.move_down 4
      @invoice.invoice_lines.order(:entry_date, :id).each do |line|
        pdf.text "#{line.entry_date.strftime("%-d %b %Y").ljust(18)}#{line.description.to_s.truncate(42).ljust(44)}#{duration(line.duration_minutes).rjust(8)}#{(money(line.hourly_rate_cents) + "/hr").rjust(14)}#{money(line.amount_cents).rjust(14)}"
        pdf.move_down 6
      end
      pdf.stroke_horizontal_rule
      pdf.move_down 20
      pdf.bounding_box([310, pdf.cursor], width: 190) do
        pdf.text "Subtotal  #{money(@invoice.subtotal_cents)}", align: :right
        pdf.move_down 6
        pdf.text "GST (#{@invoice.gst_rate.to_f}% )  #{money(@invoice.tax_cents)}", align: :right
        pdf.move_down 8
        pdf.text "Total  #{money(@invoice.total_cents)}", align: :right, style: :bold, size: 13
      end
      pdf.move_down 36
      render_budget_summaries(pdf)
      pdf.move_down 28
      pdf.text "PAYMENT INSTRUCTIONS", style: :bold, size: 8
      pdf.move_down 4
      pdf.text @invoice.payment_instructions.to_s, size: 10
    end.render
  end

  private

  def money(cents)
    format("$%.2f", cents.to_i / 100.0)
  end

  def duration(minutes)
    "#{minutes / 60}h #{minutes % 60}m"
  end

  def format_date(date)
    date&.to_date&.strftime("%-d %B %Y")
  end

  def render_budget_summaries(pdf)
    return if @invoice.budget_summaries.empty?

    pdf.start_new_page if pdf.cursor < 160
    pdf.text "SERVICE BUDGET UTILISATION", style: :bold, size: 8
    pdf.move_down 5
    pdf.font_size 7
    pdf.text "SERVICE                                  PERIOD               BUDGET       USED        REMAINING", style: :bold
    pdf.stroke_horizontal_rule
    pdf.move_down 4
    @invoice.budget_summaries.each do |summary|
      remaining = summary.remaining_minutes
      remaining_text = remaining.negative? ? "Over #{duration(-remaining)}" : duration(remaining)
      pdf.text "#{summary.name.to_s.truncate(38).ljust(41)}#{summary.period_label.ljust(20)}#{duration(summary.budget_minutes).rjust(10)}#{duration(summary.used_minutes).rjust(11)}#{remaining_text.rjust(14)}"
      pdf.move_down 5
    end
    pdf.font_size 10
  end
end
