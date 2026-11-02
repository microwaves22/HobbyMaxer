"""Auth schemas: register, login, PIN profile switching."""

from pydantic import BaseModel, EmailStr, Field

from .users import UserRead


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=6, max_length=128)
    display_name: str = Field(min_length=1, max_length=255)


class SwitchProfileRequest(BaseModel):
    user_id: int
    pin: str = Field(min_length=4, max_length=16)


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class AuthResponse(Token):
    user: UserRead
