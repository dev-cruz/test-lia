require "rails_helper"

RSpec.describe HandEvaluator do
  describe "#check_combination" do
    context "when the hand is a royal flush" do
      it "returns 'royal_flush'" do
        cards = ["10H", "JH", "AH", "QH", "KH"]
        result = HandEvaluator.check_combination(cards)
        expect(result).to eq("royal_flush")
      end
    end

    context "when the hand is a straight flush" do
      it "returns 'straight_flush'" do
        cards = ["9H", "8H", "7H", "6H", "5H"]
        result = HandEvaluator.check_combination(cards)
        expect(result).to eq("straight_flush")
      end
    end

    context "when the hand is four of a kind" do
      it "returns 'four_of_a_kind'" do
        cards = ["7D", "7C", "7H", "7S", "5H"]
        result = HandEvaluator.check_combination(cards)
        expect(result).to eq("four_of_a_kind")
      end
    end

    context "when the hand is a full house" do
      it "returns 'full_house'" do
        cards = ["8D", "8C", "8H", "9S", "9H"]
        result = HandEvaluator.check_combination(cards)
        expect(result).to eq("full_house")
      end
    end

    context "when the hand is a flush" do
      it "returns 'flush'" do
        cards = ["KH", "10H", "7H", "6H", "2H"]
        result = HandEvaluator.check_combination(cards)
        expect(result).to eq("flush")
      end
    end

    context "when the hand is a straight" do
      it "returns 'straight'" do
        cards = ["9D", "8H", "7S", "6C", "5H"]
        result = HandEvaluator.check_combination(cards)
        expect(result).to eq("straight")
      end
    end

    context "when the hand is three of a kind" do
      it "returns 'three_of_a_kind'" do
        cards = ["4D", "4H", "4S", "9C", "2H"]
        result = HandEvaluator.check_combination(cards)
        expect(result).to eq("three_of_a_kind")
      end
    end

    context "when the hand is two pair" do
      it "returns 'two_pair'" do
        cards = ["6D", "6H", "3S", "3C", "8H"]
        result = HandEvaluator.check_combination(cards)
        expect(result).to eq("two_pair")
      end
    end

    context "when the hand is one pair" do
      it "returns 'one_pair'" do
        cards = ["10D", "10H", "5S", "2C", "8H"]
        result = HandEvaluator.check_combination(cards)
        expect(result).to eq("one_pair")
      end
    end

    context "when the hand is high card" do
      it "returns 'high_card'" do
        cards = ["KD", "10H", "7S", "6C", "2H"]
        result = HandEvaluator.check_combination(cards)
        expect(result).to eq("high_card")
      end
    end
  end
end
