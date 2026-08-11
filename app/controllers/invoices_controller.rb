class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[show destroy issue mark_paid void pdf]

  def index
    @invoices = Invoice.includes(:project).order(created_at: :desc)
  end

  def new
    @projects = Project.active.order(:name)
    month = params[:period] == "last_month" ? Date.current.last_month : Date.current
    @invoice = Invoice.new(period_start: month.beginning_of_month, period_end: month.end_of_month, due_on: Date.current + 14.days)
  end

  def create
    project = Project.find(invoice_params[:project_id])
    invoice = Invoice.build_draft!(project:, period_start: Date.parse(invoice_params[:period_start]), period_end: Date.parse(invoice_params[:period_end]), due_on: Date.parse(invoice_params[:due_on]))
    redirect_to invoice, notice: "Draft invoice ready for review."
  rescue StandardError => error
    @projects = Project.active.order(:name)
    @invoice = Invoice.new(invoice_params)
    flash.now[:alert] = error.message
    render :new, status: :unprocessable_entity
  end

  def show
    @invoice_lines = @invoice.invoice_lines.order(:entry_date, :id)
  end

  def issue
    @invoice.issue!
    redirect_to @invoice, notice: "Invoice #{@invoice.number} issued; its entries are now pending."
  rescue StandardError => error
    redirect_to @invoice, alert: error.message
  end

  def mark_paid
    @invoice.mark_paid!
    redirect_to @invoice, notice: "Invoice marked paid; its entries are now paid."
  rescue StandardError => error
    redirect_to @invoice, alert: error.message
  end

  def void
    @invoice.void!
    redirect_to @invoice, notice: "Invoice voided; its entries are available to invoice again."
  rescue StandardError => error
    redirect_to @invoice, alert: error.message
  end

  def destroy
    if @invoice.draft?
      @invoice.destroy
      redirect_to invoices_path, notice: "Draft invoice deleted."
    else
      redirect_to @invoice, alert: "Only draft invoices can be deleted."
    end
  end

  def pdf
    unless @invoice.issued? || @invoice.paid? || @invoice.voided?
      redirect_to @invoice, alert: "Issue the invoice before downloading its PDF."
      return
    end

    send_data InvoicePdf.new(@invoice).render, filename: "#{@invoice.number}.pdf", type: "application/pdf", disposition: "attachment"
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:project_id, :period_start, :period_end, :due_on)
  end
end
