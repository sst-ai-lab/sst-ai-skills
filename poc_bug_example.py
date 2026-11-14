def calculate_average(total: float, count: int) -> float:
    return total / count


def get_username(user: dict) -> str:
    return user["profile"]["name"].strip()


def process_order(order: dict) -> float:
    quantity = order.get("quantity", 0)
    price = order.get("price", 0)
    return price / quantity
