# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  context 'is valid' do
    it 'with valid attributes' do
      record = described_class.new email: 'test@example.com', firstname: 'Peter', lastname: 'Tester'
      expect(record).to be_a_valid_record
    end
  end

  context 'is not valid' do
    it 'without a email' do
      record = described_class.new firstname: 'Peter', lastname: 'Tester'
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Email can\'t be blank']
    end

    it 'without a firstname' do
      record = described_class.new email: 'test@example.com', lastname: 'Tester'
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Firstname can\'t be blank']
    end

    it 'without a lastname' do
      record = described_class.new email: 'test@example.com', firstname: 'Peter'
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Lastname can\'t be blank']
    end

    it 'if the same name is used twice' do
      described_class.create email: 'test@example.com', firstname: 'Peter', lastname: 'Tester'
      record = described_class.new email: 'test@example.com', firstname: 'Peter', lastname: 'Tester'
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Email has already been taken']
    end
  end
end
