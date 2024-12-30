class HandEvaluator
  @@ranks_order = {
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "10" => 10,
    "J" => 11,
    "Q" => 12,
    "K" => 13,
    "A" => 14
  }

  @@combinations_rank = [
    "royal_flush",
    "straight_flush",
    "four_of_a_kind",
    "full_house",
    "flush",
    "straight",
    "three_of_a_kind",
    "two_pair",
    "one_pair"
  ]

  def self.check_combination(cards)
    sorted_hand = cards.sort_by do |card|
      rank = card[0..-2]
      @@ranks_order[rank]
    end

    @@combinations_rank.find(proc {"high_card"}) do |combination|
      self.send("is_#{combination}", sorted_hand)
    end
  end

  private

  def self.is_royal_flush(cards)
    grouped_by_suits = cards.group_by { |card| card[-1] }

    grouped_by_suits.any? do |suit, suit_cards|
      ranks = get_ranks(suit_cards)
      is_subarray(ranks, [10, 11, 12, 13, 14])
    end
  end

  def self.is_straight_flush(cards)
    grouped_by_suits = cards.group_by { |card| card[-1] }

    grouped_by_suits.any? do |suit, suit_cards|
      is_straight(suit_cards)
    end
  end

  def self.is_four_of_a_kind(cards)
    rank_groups = group_by_rank(cards)
    rank_groups.values.any? { |count| count == 4 }
  end

  def self.is_full_house(cards)
    ranks = cards.map { |card|  card[0..-2] }
    rank_groups = ranks.group_by { |rank| rank }
    combinations_count = rank_groups.values.map { |rank_group| rank_group.count }
    is_subarray(combinations_count, [2, 3])
  end

  def self.is_flush(cards)
    suits = cards.group_by { |card| card[-1] }
    suits.any? { |suit, suit_cards| suit_cards.count == 5 }
  end

  def self.is_straight(cards)
    ranks = get_ranks(cards).uniq

    ace_low_straight = [2, 3, 4, 5, 14]
    return true if (ace_low_straight - ranks).empty?

    possible_sequences = (2..14).each_cons(5).to_a
    possible_sequences.any? { |possible_sequence| is_subarray(ranks, possible_sequence) }
  end

  def self.is_three_of_a_kind(cards)
    rank_groups = group_by_rank(cards)
    rank_groups.values.any? { |count| count == 3 }
  end

  def self.is_two_pair(cards)
    rank_groups = group_by_rank(cards)
    rank_groups.values.count { |count| count == 2 } >= 2
  end

  def self.is_one_pair(cards)
    rank_groups = group_by_rank(cards)
    rank_groups.values.any? { |count| count == 2 }
  end

  def self.group_by_rank(cards)
    ranks = cards.map { |card|  card[0..-2] }
    rank_groups = ranks.group_by { |rank| rank }.transform_values(&:count)
  end

  def self.get_ranks(cards)
    cards.map { |card|  @@ranks_order[card[0..-2]] }
  end

  def self.get_suits(cards)
    cards.map { |card| card[-1] }
  end

  def self.is_subarray(main_array, sub_array)
    (sub_array - main_array).empty?
  end
end