# frozen_string_literal: true

require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }

    describe 'POST/expenses' do
      context 'when expense is successfully recorded' do
        let(:expense) { { 'some' => 'data' } }

        before do
          allow(ledger).to receive(:record).with(expense).and_return(
            RecordResult.new(true, 417, nil) # last_response
          )
        end

        it 'returns the expense_id' do
          expense = { 'some' => 'data' }

          post '/expenses', JSON.generate(expense)

          parsed = JSON.parse(last_response.body)

          expect(parsed).to include('expense_id' => 417)
        end

        it 'responds with a 200 (OK)' do
          expense = { 'some' => 'data' }

          post '/expenses', JSON.generate(expense)

          expect(last_response.status).to eq(200)
        end
      end

      context 'when expense fails validation' do
        let(:expense) { { 'some' => 'data' } }

        before do
          allow(ledger).to receive(:record).with(expense).and_return(
            RecordResult.new(false, 417, 'Expense incomplete') # last_response
          )
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)

          parsed = JSON.parse(last_response.body)

          expect(parsed).to include('error' => 'Expense incomplete')
        end

        it 'responds with a 422(Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)

          expect(last_response.status).to eq(422)
        end
      end
    end
  end
end
