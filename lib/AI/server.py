# app/server.py

from flask import Flask, request, jsonify
from phase10_ai import Phase10AI

app = Flask(__name__)
ai_players = {}

@app.route("/take_turn", methods=["POST"])
def take_turn():
    data = request.get_json()
    player_id = data.get("playerId")
    hand = data.get("hand", [])
    draw_pile = data.get("drawPile", [])
    discard_pile = data.get("discardPile", [])

    if player_id not in ai_players:
        ai_players[player_id] = Phase10AI(player_id)

    ai = ai_players[player_id]
    result = ai.take_turn(hand, draw_pile, discard_pile)
    return jsonify(result)

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
