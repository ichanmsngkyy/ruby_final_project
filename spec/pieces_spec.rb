# frozen_string_literal: true

require_relative '../lib/pieces/piece'

# Piece Rspec class
describe Piece do
  describe '#initialize' do
    it 'initialize with position, color, and icon' do
      piece = Piece.new([0, 0], true, '♗')
      expect(piece.position).to eq([0, 0])
      expect(piece.color).to eq('white')
      expect(piece.icon).to eq('♗')
      expect(piece.has_moved).to be false
    end
  end

  describe '#mark_moved' do
    it 'checks if the piece has been moved' do
      piece = Piece.new([0, 0], true, '♗')
      piece.mark_moved!
      expect(piece.mark_moved!).to be true
    end
  end

  describe '#on_board' do
    it 'returns true for a valid board position' do
      piece = Piece.new([0, 0], true, '♗')
      expect(piece.on_board?([3, 4])).to be true
    end

    it 'returns false for an invalid board position' do
      piece = Piece.new([0, 0], true, '♗')
      expect(piece.on_board?([0, 8])).to be false
    end
  end

  describe '#clear_path?' do
    it 'return true if path to end_pos is clear' do
      board = Hash.new(nil)
      piece = Piece.new([0, 0], true, '♗')
      expect(piece.clear_path?([1, 1], board)).to be true
    end

    it 'return false if path is not clear' do
      board = Hash.new(nil)
      board[[1, 1]] = double('Piece')
      piece = Piece.new([0, 0], true, '♗')
      expect(piece.clear_path?([2, 2], board)).to be false
    end
  end

  describe '#destination_valid?' do
    it 'return true if destination is empty' do
      board = {}
      piece = Piece.new([0, 0], true, '♗')
      expect(piece.destination_valid?([1, 1], board)).to be true
    end

    it 'returns true if destination has enemy piece' do
      enemy_piece = Piece.new([0, 0], false, '♗')
      board = { [3, 3] => enemy_piece }
      piece = Piece.new([0, 0], true, '♗')
      expect(piece.destination_valid?([3, 3], board)).to be true
    end

    it 'returns false if destination has friendly piece' do
      friendly_piece = Piece.new([0, 0], true, '♖')
      board = { [3, 3] => friendly_piece }
      piece = Piece.new([0, 0], true, '♗')
      expect(piece.destination_valid?([3, 3], board)).to be false
    end
  end
end
