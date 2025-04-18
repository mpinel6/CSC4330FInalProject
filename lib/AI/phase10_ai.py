# app/phase10_ai.py

import random
import numpy as np
from typing import List, Dict

class Phase10AI:
    def __init__(self, player_id: str, num_states=1000, num_actions=10):
        self.player_id = player_id
        self.current_phase = 1
        self.hand = []
        self.has_laid_down = False

        self.q_table = np.zeros((num_states, num_actions))
        self.learning_rate = 0.1
        self.discount_factor = 0.95
        self.exploration_rate = 1.0
        self.exploration_decay = 0.995
        self.min_exploration_rate = 0.01
        self.num_actions = num_actions
        self.num_states = num_states

    def encode_state(self, hand: List[int], draw_pile: List[int], discard_pile: List[int]) -> int:
        return (sum(hand) + len(draw_pile) * 10 + len(discard_pile)) % self.num_states

    def get_action(self, state: int) -> int:
        if random.random() < self.exploration_rate:
            return random.randint(0, self.num_actions - 1)
        return int(np.argmax(self.q_table[state]))

    def take_turn(self, hand: List[int], draw_pile: List[int], discard_pile: List[int]) -> Dict:
        self.hand = hand + [draw_pile[0]] if draw_pile else hand
        state = self.encode_state(self.hand, draw_pile, discard_pile)
        action = self.get_action(state)

        discard_card = self.select_discard(action)
        if discard_card in self.hand:
            self.hand.remove(discard_card)
        lay_down = self.check_lay_down()

        reward = 10 if lay_down else -1
        next_state = self.encode_state(self.hand, draw_pile, discard_pile)
        self.update_q_table(state, action, reward, next_state)

        return {
            "drawSource": "draw",
            "discardCard": discard_card,
            "layDownPhase": lay_down
        }

    def update_q_table(self, state: int, action: int, reward: float, next_state: int):
        best_next_action = np.max(self.q_table[next_state])
        td_target = reward + self.discount_factor * best_next_action
        td_error = td_target - self.q_table[state][action]
        self.q_table[state][action] += self.learning_rate * td_error
        self.exploration_rate = max(self.min_exploration_rate, self.exploration_rate * self.exploration_decay)

    def check_lay_down(self) -> bool:
        return random.random() > 0.8

    def select_discard(self, action_idx: int) -> int:
        if not self.hand:
            return -1
        return self.hand[action_idx % len(self.hand)]