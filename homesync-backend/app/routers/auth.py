"""Auth: parent register/login plus PIN profile switching for shared devices."""

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..core.security import (
    create_access_token,
    get_current_user,
    get_password_hash,
    verify_password,
)
from ..models import Family, User
from ..schemas.auth import AuthResponse, RegisterRequest, SwitchProfileRequest, Token
from ..schemas.users import UserRead

router = APIRouter(prefix="/auth", tags=["auth"])


def _issue(user: User) -> AuthResponse:
    token = create_access_token(str(user.id))
    return AuthResponse(
        access_token=token, token_type="bearer", user=UserRead.model_validate(user)
    )


@router.post("/register", response_model=AuthResponse, status_code=201)
def register(payload: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == payload.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered.",
        )
    user = User(
        email=payload.email,
        hashed_password=get_password_hash(payload.password),
        display_name=payload.display_name,
        role="parent",
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return _issue(user)


@router.post("/login", response_model=Token)
def login(form: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == form.username).first()
    if not user or not user.hashed_password:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not verify_password(form.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return Token(access_token=create_access_token(str(user.id)))


@router.post("/switch-profile", response_model=AuthResponse)
def switch_profile(payload: SwitchProfileRequest, db: Session = Depends(get_db)):
    """Swap the shared-device session to another family profile.

    The caller sends the target profile id plus the family parent PIN.
    """
    user = db.get(User, payload.user_id)
    if user is None or user.family_id is None:
        raise HTTPException(status_code=404, detail="Profile not found.")
    family = db.get(Family, user.family_id)
    if family is None or not verify_password(payload.pin, family.parent_pin_hashed):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid PIN."
        )
    return _issue(user)


@router.get("/me", response_model=UserRead)
def me(current_user: User = Depends(get_current_user)):
    return current_user
