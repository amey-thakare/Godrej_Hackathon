from typing import List, Optional
from pydantic import BaseModel


class ChatMessageItem(BaseModel):
    role: str  # "user" or "assistant"
    content: str


class ChatRequest(BaseModel):
    message: str
    plant_id: Optional[int] = None
    chat_history: Optional[List[ChatMessageItem]] = None


class ChatResponse(BaseModel):
    success: bool
    reply: str
    plant_id: Optional[int] = None
    plant_name: Optional[str] = None
