# frozen_string_literal: true

require 'rack/test'
require 'json'
require_relative '../../app/api'

module ExpenseTracker
  RSpec.describe 'Expense Tracker API' do
    include Rack::Test::Methods

    def app
      ExpenseTracker::API.new
    end

    def post_expense(expense)
      post '/expenses', JSON.generate(expense)
      expect(last_response.status).to eq(200)

      parsed = JSON.parse(last_response.body)
      expect(parsed).to include('expense_id' => a_kind_of(Integer))
      expense.merge('id' => parsed['expense_id'])
    end

    it 'records submitted expenses' do
      pending 'Need to persist expenses'

      coffee = post_expense(
        'payee' => 'Starbucks',
        'amount' => 5.75,
        'date' => '2017-06-10'
      )

      zoo = post_expense(
        'payee' => 'Zoo',
        'amount' => 2,
        'date' => '2018-07-11'
      )

      groceries = post_expense(
        'payee' => 'Coles',
        'amount' => 40,
        'date' => '2019-08-21'
      )

      get '/expenses/2019-08-21'
      expect(last_response.status).to eq(200)

      expenses = JSON.parse(last_response.body)
      expect(expenses).to contain_exactly(groceries) # the returned parsed json (groceries) here is an array
    end
  end
end
