# frozen_string_literal: true

require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker

  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }
    let(:parsed) { JSON.parse(last_response.body) }

    describe 'GET/expenses/:date' do
      context 'when expenses exist on a given date' do
        let(:date) { '2017-06-12' }

        before do
          allow(ledger).to receive(:expenses_on).with(date).and_return(
            RecordResult.new(true, 417, nil) # last_response
          )
        end

        it 'returns the expense records as JSON' do
          get '/expenses/2017-06-12'

          expect(parsed).to include('expense_id' => 417)
        end

        it 'responds with 200(OK)' do
          get '/expenses/2017-06-12'

          expect(last_response.status).to eq(200)
        end
      end

      context 'when there are no expenses on the given date' do
        let(:date) { '2017-06-12' }

        before do
          allow(ledger).to receive(:expenses_on).with(date).and_return(
            RecordResult.new(true, [], 'no record found for this date') # last_response
          )
        end

        it 'returns an empty array as JSON' do
          get '/expenses/2017-06-12'

          expect(parsed).to include('expense_id' => [])
        end

        it 'responds with a 200(OK)' do
          get '/expenses/2017-06-12'

          expect(last_response.status).to eq(200)
        end
      end
    end

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
