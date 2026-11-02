"""Model registry — importing this module registers all tables."""

from .event import Event
from .family import Family
from .reward import PointTransaction, Reward
from .submission import TaskSubmission
from .task import Task
from .user import User

__all__ = [
    "Event",
    "Family",
    "PointTransaction",
    "Reward",
    "Task",
    "TaskSubmission",
    "User",
]
