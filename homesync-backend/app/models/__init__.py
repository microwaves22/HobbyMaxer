"""Model registry — importing this module registers all tables."""

from .event import Event
from .family import Family
from .invite import FamilyInvite
from .notification import Notification
from .reward import PointTransaction, Reward
from .submission import TaskSubmission
from .task import Task
from .user import User

__all__ = [
    "Event",
    "Family",
    "FamilyInvite",
    "Notification",
    "PointTransaction",
    "Reward",
    "Task",
    "TaskSubmission",
    "User",
]
